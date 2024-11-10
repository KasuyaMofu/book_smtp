# SMTP本(仮称)

## 初期設定

### ネットワークの指定

compose.yaml は、 `/16` のネットワークを作成します。対象のネットワークを、 `.env` ファイルで指定してください。デフォルトでは、 `10.255.0.0/16` を示す `NETWORK=10.255` が設定されています。

尚、 `.env` ファイルを更新した場合は、後述の `make build` を再度行ってください。

### イメージのビルド

イメージの作成のため、一度だけ、以下のコマンドを実行してください。

```
make build
```

## 起動方法

以下のコマンドを実行すると、全てのコンテナが起動します。

```
make up
```

## ネットワーク構成

make up を実行すると、以下の図のネットワークが構成されます。この環境を元に、 a.test から b.test へのメール送信を行います。

```mermaid
graph LR
    a-client[client.a.test<br>10.255.1.10]
    a-smtp-plain[plain.smtp.a.test<br>10.255.1.20]
    a-smtp-dkim[dkim.smtp.a.test<br>10.255.1.21]

    b-mx-plain[plain.mx.b.test<br>10.255.2.30]
    b-mx-spf[spf.mx.b.test<br>10.255.2.31]
    b-mx-dkim[dkim.mx.b.test<br>10.255.2.32]
    b-mx-dmarc[dmarc.mx.b.test<br>10.255.2.33]
    b-imap[imap.b.test<br>10.255.2.40]

    a-client --> a-smtp
    a-smtp   --> b-mx
    b-mx     --> b-imap

    subgraph a[a.test 10.255.1.0/24]
        a-client
        a-smtp
    end

    subgraph a-smtp[*.smtp.a.test]
        direction LR
        a-smtp-plain
        a-smtp-dkim
    end

    subgraph b[b.test 10.255.2.0/24]
        b-mx
        b-imap
    end

    subgraph b-mx[*.mx.b.test]
        direction LR
        b-mx-plain
        b-mx-spf
        b-mx-dkim
        b-mx-dmarc
    end
```

### a.test



サーバ名 | IP | 備考
-: | :- | :-
client.a.test     | .1.10  | メール送信テスト用のスクリプトが配置されています。
plain.smtp.a.test | .1.20 | 署名を行わないSMTPサーバ。
dkim.smtp.a.test  | .1.21 | DKIM署名を行うSMTPサーバ。セレクタは `smtpbook`。

また、以下のTXTレコードを設定しています。

ドメイン | レコード 
-: | :- | :-
a.test                     |  `"v=spf1 ip4:_NETWORK.1.30/31 -all"` 
fail.a.test                |  `"v=spf1 ip4:_NETWORK.255.30/31 -all"` 
smtpbook._domainkey.a.test |  `"v=DKIM1; k=rsa; " "p=MIIBIjAN(省略)QIDAQAB"`
_dmarc.a.test              |  `"v=DMARC1; p=quarantine; pct=100"`


### b.test

サーバ名 | IP | 備考
-: | :- | :-
plain.mx.b.test  | .1.30 | 検証を行わない
spf.mx.b.test    | .1.31 | SPFの検証を行う
dkim.mx.b.test   | .1.32 | DKIM署名の検証を行う
dmarc.mx.b.test  | .1.33 | SPF/DKIM/DMARCの検証を行う
imap.b.test      | .1.40 | *.mx.b.test へのメールは、全てこのサーバにリレーされる

## 実行例

以下のようなコマンドを実行すると、それぞれのメール送信の様子を見ることができます。

```bash
make build
make up
make scenario6/send
make view
```

### 実行ログの例

`make scenario[1-9]/send` を実行すると、 `a-client` コンテナに設置されている `/example/send.sh` が実行され、指定したFrom、Toを元に、SMTPサーバに `telnet` コマンドでSMTP通信を行う様子が確認できます。 

```
$ make scenario6/send 
docker compose exec a-client     /send.sh user1@a.test user1@dmarc.b.test scenario6 dkim.smtp.a.test
# telnet dkim.smtp.a.test 25
--------------------------
Trying 10.255.1.31...
Connected to dkim.smtp.a.test.
Escape character is '^]'.
220 dkim.smtp.a.test ESMTP Postfix
HELO a.test
250 dkim.smtp.a.test
MAIL FROM: user1@a.test
250 2.1.0 Ok
RCPT TO:   user1@dmarc.b.test
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
Message-ID: <20241110102109.21196@a.test>
Date: Sun, 10 Nov 2024 10:21:09 +0900
From: user1@a.test
To:   user1@dmarc.b.test
Subject: scenario6 (mail from user1@a.test)

Hello user1@dmarc.b.test!
.
250 2.0.0 Ok: queued as 54A75383EDB
QUIT
221 2.0.0 Bye
Connection closed by foreign host.
--------------------------
```

`make view` を実行すると、 `user1@b.test` へ送信された最新のメールを確認することができます。

※ POP3 接続や IMAP 接続は行わないため、表示した対象のメールは `cur/` への移動は行われません。

```
$ make view
docker compose exec b-imap /view.sh user1
--------------------------
Return-Path: <user1@a.test>
X-Original-To: user1@dmarc.b.test
Delivered-To: user1@dmarc.b.test
Received: from dmarc.mx.b.test (dmarc.mx.b.test [10.255.2.23])
        by imap.b.test (Postfix) with ESMTPS id 85782383EDB
        for <user1@dmarc.b.test>; Sun, 10 Nov 2024 10:21:10 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.31])
        by dmarc.mx.b.test (Postfix) with ESMTPS id 67106383F0C
        for <user1@dmarc.b.test>; Sun, 10 Nov 2024 10:21:10 +0900 (JST)
Authentication-Results: dmarc.mx.b.test;
        dkim=pass header.d=a.test header.s=smtpbook header.b=dKW1yg9G;
        dmarc=pass (policy=quarantine) header.from=a.test;
        spf=pass (dmarc.mx.b.test: domain of user1@a.test designates 10.255.1.31 as permitted sender) smtp.mailfrom=user1@a.test
Received: from a.test (client.a.test [10.255.1.1])
        by dkim.smtp.a.test (Postfix) with SMTP id 54A75383EDB
        for <user1@dmarc.b.test>; Sun, 10 Nov 2024 10:21:09 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=a.test; s=smtpbook;
        t=1731201670;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=dKW1yg9Gn1Z+3bOVDJxNaMgaXW0Vlx7zeWl6BKljDj3NGXXgO2v1RjuXYr7uBTEnzpcfSq
        Tomb7l4PB+CESru4B3lmCxg13digQD8jYZtEKWjisrm5K/ysE0hvQ477DR2tz/DYEauEcT
        t0VcYDsxYLpjZkY+Fi7HYxVwqzhIgiRjEsOd3n/TkMnKZ8FW0X7oqUhkgl1/Oq7aq5I0Au
        WWoYui38Tmz+uR1HqjERy8CvHSveOdbC/w67XA8kJk3umN5YTbOGXdYBka7SRoPX4zv5p3
        +n/9wGxrdM3z8KPtTjx+ohsAHBt5vzrJLTVyLu/trQlLUBwveOgBpj0LNEfjtg==
Message-ID: <20241110102109.21196@a.test>
Date: Sun, 10 Nov 2024 10:21:09 +0900
From: user1@a.test
To:   user1@dmarc.b.test
Subject: scenario6 (mail from user1@a.test)

Hello user1@dmarc.b.test!
--------------------------
```

## 補足: docker compose の出力について

`make scenario[1-9]/send` を実行すると、 `docker compose` の標準出力からDNSの問い合わせやpostfixのログを確認することができます。（※例示のグは順番を整形済み）

メールのヘッダーだけでなく、DNSへの問い合わせ、postfixのログから、さらに理解を深められるようにできています。

```
dns           | Nov 10 10:21:09 unbound[7:0] info: 10.255.1.1 dkim.smtp.a.test. AAAA IN
dns           | Nov 10 10:21:09 unbound[7:0] info: 10.255.1.1 dkim.smtp.a.test. A IN
dns           | Nov 10 10:21:09 unbound[7:0] info: 10.255.1.31 1.1.255.10.in-addr.arpa. PTR IN
dns           | Nov 10 10:21:09 unbound[7:0] info: 10.255.1.31 client.a.test. A IN
dns           | Nov 10 10:21:09 unbound[7:0] info: 10.255.1.31 localhost. A IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.1.31 dmarc.b.test. MX IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.1.31 dmarc.mx.b.test. A IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.23 31.1.255.10.in-addr.arpa. PTR IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.23 dkim.smtp.a.test. A IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.23 localhost. A IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.23 _dmarc.a.test. TXT IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.23 imap.b.test. MX IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.23 imap.b.test. A IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.10 23.2.255.10.in-addr.arpa. PTR IN
dns           | Nov 10 10:21:10 unbound[7:0] info: 10.255.2.10 dmarc.mx.b.test. A IN
a-smtp-dkim   | Nov 10 10:21:09 dkim postfix/smtpd[122]: connect from client.a.test[10.255.1.1]
a-smtp-dkim   | Nov 10 10:21:09 dkim postfix/smtpd[122]: 54A75383EDB: client=client.a.test[10.255.1.1]
a-smtp-dkim   | Nov 10 10:21:10 dkim postfix/cleanup[126]: 54A75383EDB: message-id=<20241110102109.21196@a.test>
a-smtp-dkim   | Nov 10 10:21:10 dkim postfix/qmgr[114]: 54A75383EDB: from=<user1@a.test>, size=411, nrcpt=1 (queue active)
a-smtp-dkim   | Nov 10 10:21:10 dkim postfix/smtpd[122]: disconnect from client.a.test[10.255.1.1] helo=1 mail=1 rcpt=1 data=1 quit=1 commands=5
a-smtp-dkim   | Nov 10 10:21:10 dkim postfix/smtp[127]: 54A75383EDB: to=<user1@dmarc.b.test>, relay=dmarc.mx.b.test[10.255.2.23]:25, delay=1.2, delays=1.1/0.02/0.08/0.07, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 67106383F0C)
a-smtp-dkim   | Nov 10 10:21:10 dkim postfix/qmgr[114]: 54A75383EDB: removed
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/smtpd[122]: connect from dkim.smtp.a.test[10.255.1.31]
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/smtpd[122]: 67106383F0C: client=dkim.smtp.a.test[10.255.1.31]
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/cleanup[126]: 67106383F0C: message-id=<20241110102109.21196@a.test>
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/smtpd[122]: disconnect from dkim.smtp.a.test[10.255.1.31] ehlo=2 starttls=1 mail=1 rcpt=1 data=1 quit=1 commands=7
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/qmgr[113]: 67106383F0C: from=<user1@a.test>, size=1189, nrcpt=1 (queue active)
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/smtp[127]: 67106383F0C: to=<user1@dmarc.b.test>, relay=imap.b.test[10.255.2.10]:25, delay=0.14, delays=0.06/0.02/0.04/0.02, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 85782383EDB)
b-mx-dmarc    | Nov 10 10:21:10 dmarc postfix/qmgr[113]: 67106383F0C: removed
b-imap        | Nov 10 10:21:10 imap postfix/smtpd[123]: connect from dmarc.mx.b.test[10.255.2.23]
b-imap        | Nov 10 10:21:10 imap postfix/smtpd[123]: 85782383EDB: client=dmarc.mx.b.test[10.255.2.23]
b-imap        | Nov 10 10:21:10 imap postfix/cleanup[127]: 85782383EDB: message-id=<20241110102109.21196@a.test>
b-imap        | Nov 10 10:21:10 imap postfix/smtpd[123]: disconnect from dmarc.mx.b.test[10.255.2.23] ehlo=2 starttls=1 mail=1 rcpt=1 data=1 quit=1 commands=7
b-imap        | Nov 10 10:21:10 imap postfix/qmgr[104]: 85782383EDB: from=<user1@a.test>, size=1622, nrcpt=1 (queue active)
b-imap        | Nov 10 10:21:10 imap postfix/local[128]: 85782383EDB: to=<user1@dmarc.b.test>, relay=local, delay=0.02, delays=0.01/0.01/0/0, dsn=2.0.0, status=sent (delivered to maildir)
b-imap        | Nov 10 10:21:10 imap postfix/qmgr[104]: 85782383EDB: removed
```
