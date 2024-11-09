# SMTP本(仮称)

## 初期設定

### ネットワークの指定

compose.yaml は、 `/16` のネットワークを作成します。対象のネットワークを、 `.env` ファイルで指定してください。デフォルトでは、 `10.255.0.0/16` を示す `NETWORK=10.255` が設定されています。

尚、 `.env` ファイルを更新した場合は、後述の make build を再度行ってください。

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

## サーバ構成

`a.test` から `b.test` へのメール送信を行い、 `b.test` から `c.test` への転送を行う環境です。


### `a.test`

サーバ名 | 備考
-: | :-
plain.smtp.a.test | -
dkim.smtp.a.test  | DKIM署名を行います。セレクタは `smtpbook` です。
client.a.test     | メール送信テスト用のスクリプトが配置されています。

### `b.test`

以下の受信サーバを宛先として指定すると、それぞれの検証が行われます。
※ APEX ドメイン ( `b.test` )を指定した場合、 `imap.b.test` に送信されるようにMXレコードが設定されています。 

サーバ名 | 備考
-: | :-
imap.b.test  | `b.test` に所属するメールは、このサーバにリレーされます。
spf.b.test   | SPFの検証を行うリレーサーバ
dkim.b.test  | DKIM署名の検証を行うリレーサーバ
dmarc.b.test | DMARCの検証を行うリレーサーバ

## 実行例

以下のようなコマンドを実行すると、それぞれのメール送信の様子を見ることができます。

```bash
make build
make up
make scenario6/send
make view
```

### 実行ログの例

`make scenario[1-9]/send` を地sこうすると、 `a-client` コンテナに設置されている `/example/send.sh` が実行され、指定したFrom、Toを元に、SMTPサーバに `telnet` コマンドでSMTP通信を行う様子が確認できます。 

```
$ make scenario6/send 
docker compose exec a-client     /example/send.sh user1@a.test user1@dmarc.b.test dkim.smtp.a.test
# telnet dkim.smtp.a.test 25
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
Message-ID: <20241110051450.11619@a.test>
Date: Sun, 10 Nov 2024 05:14:51 +0900
From: user1@a.test
To:   user1@dmarc.b.test
Subject: test mail from user1@a.test!

Hello user1@dmarc.b.test!
.
QUIT
Connection closed by foreign host.
```

`make view` を実行すると、 `user1@b.test` へ送信された最新のメールを確認することができます。

※ POP3 接続や IMAP 接続は行わないため、表示した対象のメールは `cur/` への移動は行われません。

```
$ make view 
docker compose exec b-imap /example/receive.sh user1
Return-Path: <user1@a.test>
X-Original-To: user1@dmarc.b.test
Delivered-To: user1@dmarc.b.test
Received: from dmarc.mx.b.test (unknown [10.255.2.23])
        by imap.b.test (Postfix) with ESMTPS id 29048383DFC
        for <user1@dmarc.b.test>; Sun, 10 Nov 2024 05:14:52 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.31])
        by dmarc.mx.b.test (Postfix) with ESMTPS id E1E2C383DEE
        for <user1@dmarc.b.test>; Sun, 10 Nov 2024 05:14:51 +0900 (JST)
Authentication-Results: dmarc.mx.b.test;
        dkim=pass header.d=a.test header.s=smtpbook header.b=uBxVJpWx;
        spf=pass (dmarc.mx.b.test: domain of user1@a.test designates 10.255.1.31 as permitted sender) smtp.mailfrom=user1@a.test;
        dmarc=pass (policy=quarantine) header.from=a.test
Received: from a.test (client.a.test [10.255.1.1])
        by dkim.smtp.a.test (Postfix) with SMTP id B58F3383DDA
        for <user1@dmarc.b.test>; Sun, 10 Nov 2024 05:14:50 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=a.test; s=smtpbook;
        t=1731183291;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=uBxVJpWxez5YORyOAyDt2pJmpCyhDwlu5FwssT2JB0YdqRM0NhJVJrXHXz5PLuGvVY718k
        yt/y85xZssufb3Ys/4JQgofeGOteCIm9XEcWtgaxrGBeqJWRUdqQspDQZFUcPEj8rt8/Xk
        JRX7IXUxF+LTPB0bqMtak8REq2svbh8VYPk/ilcgMYfk3nPPLCGh7OodCoI4pcUTj4BMbX
        YTvDV53q0ZylwqdBJnEKX7Op0CGrGAN6Jf7Fnz3SGd8Wc5T3+FLQbpkN4Gh26PmNHxIbOH
        OFqD4TPDkQbfiLaLuYpCsqEKd7JR5d6NVbFw1SQQQjzybwviT3T5TIWskhow8A==
Message-ID: <20241110051450.11619@a.test>
Date: Sun, 10 Nov 2024 05:14:51 +0900
From: user1@a.test
To:   user1@dmarc.b.test
Subject: test mail from user1@a.test!

Hello user1@dmarc.b.test!
```

## 補足: docker compose の出力について

`make scenario[1-9]/send` を実行すると、 `docker compose` の標準出力からDNSの問い合わせやpostfixのログを確認することができます。（※例示のグは順番を整形済み）

メールのヘッダーだけでなく、DNSへの問い合わせ、postfixのログから、さらに理解を深められるようにできています。

```
dns           | Nov 10 05:14:50 unbound[7:0] info: 10.255.1.1 dkim.smtp.a.test. AAAA IN
dns           | Nov 10 05:14:50 unbound[7:0] info: 10.255.1.1 dkim.smtp.a.test. A IN
dns           | Nov 10 05:14:50 unbound[7:0] info: 10.255.1.31 1.1.255.10.in-addr.arpa. PTR IN
dns           | Nov 10 05:14:50 unbound[7:0] info: 10.255.1.31 client.a.test. A IN
dns           | Nov 10 05:14:50 unbound[7:0] info: 10.255.1.31 localhost. A IN
dns           | Nov 10 05:14:51 unbound[7:0] info: 10.255.1.31 dmarc.b.test. MX IN
dns           | Nov 10 05:14:51 unbound[7:0] info: 10.255.1.31 dmarc.mx.b.test. A IN
dns           | Nov 10 05:14:51 unbound[7:0] info: 10.255.2.23 31.1.255.10.in-addr.arpa. PTR IN
dns           | Nov 10 05:14:51 unbound[7:0] info: 10.255.2.23 dkim.smtp.a.test. A IN
dns           | Nov 10 05:14:51 unbound[7:0] info: 10.255.2.23 localhost. A IN
dns           | Nov 10 05:14:52 unbound[7:0] info: 10.255.2.23 smtpbook._domainkey.a.test. TXT IN
dns           | Nov 10 05:14:52 unbound[7:0] info: 10.255.2.23 a.test. TXT IN
dns           | Nov 10 05:14:52 unbound[7:0] info: 10.255.2.23 _dmarc.a.test. TXT IN
dns           | Nov 10 05:14:52 unbound[7:0] info: 10.255.2.23 imap.b.test. MX IN
dns           | Nov 10 05:14:52 unbound[7:0] info: 10.255.2.23 imap.b.test. A IN
dns           | Nov 10 05:14:52 unbound[7:0] info: 10.255.2.10 23.2.255.10.in-addr.arpa. PTR IN
a-smtp-dkim   | Nov 10 05:14:50 dkim postfix/smtpd[116]: connect from client.a.test[10.255.1.1]
a-smtp-dkim   | Nov 10 05:14:50 dkim postfix/smtpd[116]: B58F3383DDA: client=client.a.test[10.255.1.1]
a-smtp-dkim   | Nov 10 05:14:51 dkim postfix/cleanup[120]: B58F3383DDA: message-id=<20241110051450.11619@a.test>
a-smtp-dkim   | Nov 10 05:14:51 dkim postfix/qmgr[113]: B58F3383DDA: from=<user1@a.test>, size=405, nrcpt=1 (queue active)
a-smtp-dkim   | Nov 10 05:14:51 dkim postfix/smtpd[116]: disconnect from client.a.test[10.255.1.1] helo=1 mail=1 rcpt=1 data=1 quit=1 commands=5
a-smtp-dkim   | Nov 10 05:14:52 dkim postfix/smtp[121]: B58F3383DDA: to=<user1@dmarc.b.test>, relay=dmarc.mx.b.test[10.255.2.23]:25, delay=1.5, delays=1.2/0.02/0.05/0.19, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as E1E2C383DEE)
a-smtp-dkim   | Nov 10 05:14:52 dkim postfix/qmgr[113]: B58F3383DDA: removed
b-mx-dmarc    | Nov 10 05:14:51 dmarc postfix/smtpd[116]: connect from dkim.smtp.a.test[10.255.1.31]
b-mx-dmarc    | Nov 10 05:14:51 dmarc postfix/smtpd[116]: E1E2C383DEE: client=dkim.smtp.a.test[10.255.1.31]
b-mx-dmarc    | Nov 10 05:14:51 dmarc postfix/cleanup[120]: E1E2C383DEE: message-id=<20241110051450.11619@a.test>
b-mx-dmarc    | Nov 10 05:14:52 dmarc postfix/qmgr[113]: E1E2C383DEE: from=<user1@a.test>, size=1183, nrcpt=1 (queue active)
b-mx-dmarc    | Nov 10 05:14:52 dmarc postfix/smtpd[116]: disconnect from dkim.smtp.a.test[10.255.1.31] ehlo=2 starttls=1 mail=1 rcpt=1 data=1 quit=1 commands=7
b-mx-dmarc    | Nov 10 05:14:52 dmarc postfix/smtp[121]: E1E2C383DEE: to=<user1@dmarc.b.test>, relay=imap.b.test[10.255.2.10]:25, delay=0.25, delays=0.18/0.02/0.04/0.02, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 29048383DFC)
b-mx-dmarc    | Nov 10 05:14:52 dmarc postfix/qmgr[113]: E1E2C383DEE: removed
b-imap        | Nov 10 05:14:52 imap postfix/smtpd[123]: connect from unknown[10.255.2.23]
b-imap        | Nov 10 05:14:52 imap postfix/smtpd[123]: 29048383DFC: client=unknown[10.255.2.23]
b-imap        | Nov 10 05:14:52 imap postfix/cleanup[127]: 29048383DFC: message-id=<20241110051450.11619@a.test>
b-imap        | Nov 10 05:14:52 imap postfix/smtpd[123]: disconnect from unknown[10.255.2.23] ehlo=2 starttls=1 mail=1 rcpt=1 data=1 quit=1 commands=7
b-imap        | Nov 10 05:14:52 imap postfix/qmgr[104]: 29048383DFC: from=<user1@a.test>, size=1608, nrcpt=1 (queue active)
b-imap        | Nov 10 05:14:52 imap postfix/local[128]: 29048383DFC: to=<user1@dmarc.b.test>, relay=local, delay=0.02, delays=0.01/0.01/0/0, dsn=2.0.0, status=sent (delivered to maildir)
b-imap        | Nov 10 05:14:52 imap postfix/qmgr[104]: 29048383DFC: removed
```
