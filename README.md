# SMTP本(仮称)

## ビルド方法

ベースのイメージをビルドする必要があります。一度だけ、以下のコマンドを実行してください。

```
make build-all
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
make build-all
docker compose up -d dns a-client a-smtp-dkim b-mx-dmarc b-imap
docker compose exec a-client /example/send.sh user1@a.test user1@dmarc.b.test dkim.smtp.a.test
docker compose exec b-imap /example/receive.sh user1
docker compose down dns a-client a-smtp-dkim b-mx-dmarc b-imap
```

### 実行ログの例

`a-client` コンテナに設置されている `/example/send.sh` では、 `telnet` コマンドでSMTP通信を行う様子が確認できます。 

```
$ docker compose exec a-client /example/send.sh user1@a.test user1@dmarc.b.test dkim.smtp.a.test
# telnet dkim.smtp.a.test 25
Trying 10.200.0.60...
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
Message-ID: <20241107013135.19006@a.test>
Date: Thu, 07 Nov 2024 01:31:35 +0900
From: user1@a.test
To:   user1@dmarc.b.test
Subject: test mail from user1@a.test!

Hello user1@dmarc.b.test!
.
QUIT
Connection closed by foreign host.
```

`b-imap` に設置されている `/example/send.sh` では、引数に与えたユーザの `/home/$user/Maildir/new/` を確認し、一番最新のメールを表示します。
メールヘッダーから、SPF、DKIM、DMARCの検証が行われていることが分かります。

※ POP3 接続や IMAP 接続は行わないため、表示した対象のメールは `cur/` への移動は行われません。

```
$ docker compose exec b-imap /example/receive.sh user1
Return-Path: <user1@a.test>
X-Original-To: user1@dmarc.b.test
Delivered-To: user1@dmarc.b.test
Received: from mx-dmarc.b.test (unknown [10.200.0.73])
        by imap.b.test (Postfix) with ESMTPS id 54D58386617
        for <user1@dmarc.b.test>; Thu,  7 Nov 2024 01:31:36 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.200.0.60])
        by mx-dmarc.b.test (Postfix) with ESMTPS id 0B5F2386604
        for <user1@dmarc.b.test>; Thu,  7 Nov 2024 01:31:36 +0900 (JST)
Authentication-Results: mx-dmarc.b.test;
        dkim=pass header.d=a.test header.s=smtpbook header.b="o9K/69RI";
        dmarc=pass (policy=quarantine) header.from=a.test;
        spf=pass (mx-dmarc.b.test: domain of user1@a.test designates 10.200.0.60 as permitted sender) smtp.mailfrom=user1@a.test
Received: from a.test (client.a.test [10.200.0.5])
        by dkim.smtp.a.test (Postfix) with SMTP id D31C43865F0
        for <user1@dmarc.b.test>; Thu,  7 Nov 2024 01:31:34 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=a.test; s=smtpbook;
        t=1730910695;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=o9K/69RIc8A2wczf2aD70KObG5dZjHcUlg9MuC2ZdplNfGMU2c+vPpTLC4sK5hGENzmIGz
        OO+/dTu3eV2dPyMwynF+qdQv3QyGQJX2MivHMW8MmaAgjHavc75mGui8DTkS3vXjg990mg
        0/0z9pQCEIpjBuvtk0vVnQU4s7RYU+BQQm0RqDw83zJ1auWIbOhZaNP5RVasoueODsLcDa
        kzjVyh667X9QftqzFtVnmY+u5+RtC23rqFliuZx5xDIK9aaMs6VySpwx5+/FuTpTB1hw7D
        QwUX9j/KcRbTjhvLvitBVrQ1tKHiYsK+fcXlRsYIcbtTZXJAMNxVafBKWUmngA==
Message-ID: <20241107013135.19006@a.test>
Date: Thu, 07 Nov 2024 01:31:35 +0900
From: user1@a.test
To:   user1@dmarc.b.test
Subject: test mail from user1@a.test!

Hello user1@dmarc.b.test!
```

## 補足: コンテナの出力について

実行例 `docker compose up -d dns a-client a-smtp-dkim b-mx-dmarc b-imap` の `-d` を抜いて実行すると、例えば以下のような出力を得ることができます。
メールヘッダーだけでなく、DNSへの問い合わせ、postfixのログから、さらに理解を深められるように、ログの設計がなされています。

```
dns          | Nov 07 01:31:34 unbound[6:0] info: 10.200.0.5 dkim.smtp.a.test. A IN
dns          | Nov 07 01:31:34 unbound[6:0] info: 10.200.0.5 dkim.smtp.a.test. AAAA IN
dns          | Nov 07 01:31:34 unbound[6:0] info: 10.200.0.60 5.0.200.10.in-addr.arpa. PTR IN
dns          | Nov 07 01:31:34 unbound[6:0] info: 10.200.0.60 client.a.test. A IN
dns          | Nov 07 01:31:34 unbound[6:0] info: 10.200.0.60 localhost. A IN
dns          | Nov 07 01:31:35 unbound[6:0] info: 10.200.0.60 dmarc.b.test. MX IN
dns          | Nov 07 01:31:35 unbound[6:0] info: 10.200.0.60 mx-dmarc.b.test. A IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 60.0.200.10.in-addr.arpa. PTR IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 dkim.smtp.a.test. A IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 localhost. A IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 a.test. TXT IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 smtpbook._domainkey.a.test. TXT IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 _dmarc.a.test. TXT IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 imap.b.test. MX IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.73 mx-direct.b.test. A IN
dns          | Nov 07 01:31:36 unbound[6:0] info: 10.200.0.20 73.0.200.10.in-addr.arpa. PTR IN
a-smtp-dkim  | Nov 07 01:31:34 dkim postfix/smtpd[115]: connect from client.a.test[10.200.0.5]
a-smtp-dkim  | Nov 07 01:31:34 dkim postfix/smtpd[115]: D31C43865F0: client=client.a.test[10.200.0.5]
a-smtp-dkim  | Nov 07 01:31:35 dkim postfix/cleanup[119]: D31C43865F0: message-id=<20241107013135.19006@a.test>
a-smtp-dkim  | Nov 07 01:31:35 dkim postfix/qmgr[112]: D31C43865F0: from=<user1@a.test>, size=405, nrcpt=1 (queue active)
a-smtp-dkim  | Nov 07 01:31:35 dkim postfix/smtpd[115]: disconnect from client.a.test[10.200.0.5] helo=1 mail=1 rcpt=1 data=1 quit=1 commands=5
a-smtp-dkim  | Nov 07 01:31:36 dkim postfix/smtp[120]: D31C43865F0: to=<user1@dmarc.b.test>, relay=mx-dmarc.b.test[10.200.0.73]:25, delay=1.5, delays=1.2/0.02/0.05/0.23, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 0B5F2386604)
a-smtp-dkim  | Nov 07 01:31:36 dkim postfix/qmgr[112]: D31C43865F0: removed
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/smtpd[116]: connect from dkim.smtp.a.test[10.200.0.60]
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/smtpd[116]: 0B5F2386604: client=dkim.smtp.a.test[10.200.0.60]
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/cleanup[120]: 0B5F2386604: message-id=<20241107013135.19006@a.test>
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/qmgr[113]: 0B5F2386604: from=<user1@a.test>, size=1183, nrcpt=1 (queue active)
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/smtpd[116]: disconnect from dkim.smtp.a.test[10.200.0.60] ehlo=2 starttls=1 mail=1 rcpt=1 data=1 quit=1 commands=7
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/smtp[121]: 0B5F2386604: to=<user1@dmarc.b.test>, relay=mx-direct.b.test[10.200.0.20]:25, delay=0.31, delays=0.22/0.02/0.05/0.02, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 54D58386617)
b-mx-dmarc   | Nov 07 01:31:36 mx-dmarc postfix/qmgr[113]: 0B5F2386604: removed
b-imap       | Nov 07 01:31:36 imap postfix/smtpd[107]: connect from unknown[10.200.0.73]
b-imap       | Nov 07 01:31:36 imap postfix/smtpd[107]: 54D58386617: client=unknown[10.200.0.73]
b-imap       | Nov 07 01:31:36 imap postfix/cleanup[111]: 54D58386617: message-id=<20241107013135.19006@a.test>
b-imap       | Nov 07 01:31:36 imap postfix/smtpd[107]: disconnect from unknown[10.200.0.73] ehlo=2 starttls=1 mail=1 rcpt=1 data=1 quit=1 commands=7
b-imap       | Nov 07 01:31:36 imap postfix/qmgr[105]: 54D58386617: from=<user1@a.test>, size=1610, nrcpt=1 (queue active)
b-imap       | Nov 07 01:31:36 imap postfix/local[112]: 54D58386617: to=<user1@dmarc.b.test>, relay=local, delay=0.02, delays=0.01/0.01/0/0, dsn=2.0.0, status=sent (delivered to maildir)
b-imap       | Nov 07 01:31:36 imap postfix/qmgr[105]: 54D58386617: removed
```
