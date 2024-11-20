# SMTP(Simple Mail Transfer Protocol)

**SMTP**とは、通信のプロトコルです。HTTPなどと同様に、クライアントが何らかの通信を行うと、サーバは、ステータスコードとメッセージを返却します。

**SMTP**で一番気を付けるべきポイントは、SMTPはステートフルであるということです。SMTP接続を行ったクライアント、および受け付けたサーバは、クライアントのリクエストに対して状態を持つということです。

皆さんに馴染みの深いであろう、**HTTP**(HyperText Transfer Protocol)はステートレスです。 クライアントがリクエストを送信すると、サーバは対応するレスポンスを受け取ります。サーバは、 `HTTP/1.1 200 OK` という1つのステータスコードを返しており、単純なやり取りであることが分かります。

\clearpage

```lua
telnet example.com 80
Trying 93.184.215.14...
Connected to example.com.
Escape character is '^]'.

---- クライアントのリクエスト
HEAD / HTTP/1.1
Host: example.com
User-Agent: telnet    
Accept: */*

----

---- HTTPサーバのレスポンス
HTTP/1.1 200 OK
Accept-Ranges: bytes
Age: 385691
Cache-Control: max-age=604800
Content-Type: text/html; charset=UTF-8
Date: Sun, 10 Nov 2024 12:03:59 GMT
Etag: "3147526947"
Expires: Sun, 17 Nov 2024 12:03:59 GMT
Last-Modified: Thu, 17 Oct 2019 07:18:26 GMT
Server: ECAcc (lac/55CD)
X-Cache: HIT
Content-Length: 1256
----
```

![HTTPのイメージ-1.png](HTTPのイメージ-1.png)

\clearpage

一方、SMTPの通信を見てみましょう。以下の結果の中では、 220 や 250 、354といったステータスコードから始まる行がサーバのレスポンスで、6回、レスポンスコードを返していることが分かります。

```lua
$ telnet imap.b.test 25
Trying 10.255.2.40...
Connected to imap.b.test.
Escape character is '^]'.
220 imap.b.test ESMTP Postfix
HELO a.test
250 imap.b.test
MAIL FROM: user1@a.test
250 2.1.0 Ok
RCPT TO:   user1@b.test
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
Message-ID: <20241113081556.12727@a.test>
Date: Wed, 13 Nov 2024 08:15:56 +0900
From: user1@a.test
To:   user1@b.test
Subject: scenario1-1 (mail from user1@a.test)

Hello user1@b.test!
.
250 2.0.0 Ok: queued as 3EE173C0ADC
QUIT
221 2.0.0 Bye
Connection closed by foreign host.
```

![SMTPのイメージ-1.png](SMTPのイメージ-1.png)

\clearpage

## SMTPクライアントとサーバ

SMTPでは、以下の流れで、クライアントとサーバが通信を行う必要があります。クライアントが以下のリクエストを送信し、サーバがレスポンスを行う必要があります。

1. サーバへの接続（25番ポート、587番ポート等）
2. HELO or EHLO
3. MAIL FROM
4. RCPT TO
5. DATA
6. メールの内容
7. `.` （ドットのみで終わる行）
8. QUIT

（より詳しく知りたい方は、RFC 5321 [https://www.rfc-editor.org/rfc/rfc5321.html#section-3](https://www.rfc-editor.org/rfc/rfc5321.html#section-3) を参照してください。）

```lua
$ telnet imap.b.test 25
Trying 10.255.2.40...
Connected to imap.b.test.
Escape character is '^]'.
---- 1. サーバへの接続
220 imap.b.test ESMTP Postfix
---- HELO or EHLO
HELO a.test
250 imap.b.test
---- MAIL FROM
MAIL FROM: user1@a.test
250 2.1.0 Ok
---- RCPT TO
RCPT TO:   user1@imap.b.test
250 2.1.5 Ok
---- DATA
DATA
354 End data with <CR><LF>.<CR><LF>
---- メールの内容
Message-ID: <20241110215910.10161@a.test>
Date: Sun, 10 Nov 2024 21:59:10 +0900
From: user1@a.test
To:   user1@imap.b.test
Subject: scenario1 (mail from user1@a.test)

Hello user1@imap.b.test!
.
250 2.0.0 Ok: queued as CECC4383F6B
---- QUIT
QUIT
Connection closed by foreign host.
```

\clearpage

前述のSMTP通信を実行すると、宛先には、以下のようなデータが保存されます。

```lua
Return-Path: <user1@a.test>
Received: from a.test (client.a.test [10.255.1.10])
        by imap.b.test (Postfix) with SMTP id CECC4383F6B
        for <user1@imap.b.test>; Sun, 10 Nov 2024 21:59:09 +0900 (JST)
Message-ID: <20241110215910.10161@a.test>
Date: Sun, 10 Nov 2024 21:59:10 +0900
From: user1@a.test
To:   user1@imap.b.test
Subject: scenario1 (mail from user1@a.test)

Hello user1@imap.b.test!
```

このままではわかりづらいので、先ほどのメールデータの内容を、わかりやすさのために3つに分けましょう。

```lua
---- セクション1 MAIL FROMから生成
Return-Path: <user1@a.test>

---- セクション2 RFC 5321 Trace Information の内容
Received: from a.test (client.a.test [10.255.1.10])
        by imap.b.test (Postfix) with SMTP id CECC4383F6B
        for <user1@imap.b.test>; Sun, 10 Nov 2024 21:59:09 +0900 (JST)
Message-ID: <20241110215910.10161@a.test>

---- セクション3 DATAの内容
Date: Sun, 10 Nov 2024 21:59:10 +0900
From: user1@a.test
To:   user1@imap.b.test
Subject: scenario1 (mail from user1@a.test)

Hello user1@imap.b.test!
```

\clearpage

- セクション1
    - MAIL FROM に指定した内容が Return-Path となること
- セクション2
    - telnet コマンドの実行時に表示されている `250 2.0.0 Ok: queued as CECC4383F6B` の`CECC4383F6B` が含まれていること
- セクション3
    - DATA と同一であること

上記のように、セクション1と2の内容は、クライアントとサーバ間のSMTPのリクエスト/レスポンスの情報を元に、メールサーバが自動的に追加します。

特に気を付けるべき点は、送信元メールアドレスである `user1@a.test` が2カ所に存在するということです。これらは、「エンベロープFrom」と「ヘッダーFrom」という2つの言葉で分けて呼称されます。

エンベロープFromとは、一般的に、メール送信を行うメールサーバが追加する情報で、 Return-Path に記載されるメールアドレスのことです。

ヘッダーFromとは、DATA コマンドの中で記述されている `From:` から始まる行のメールアドレスのことです。何故ヘッダーFromかというと、これはRFC 5322に定義されている「Internet Message Format」のヘッダーであるためです。

（RFC 5322 [https://www.rfc-editor.org/rfc/rfc5322.html](https://www.rfc-editor.org/rfc/rfc5322.html)）

\clearpage

# SPF(Sender Policy Framework)

概要：エンベロープFromのドメインに対応するDNSレコードを元に、メールの送信元IPが許可されたIPであるかを認証します。

（第2版で追加予定）

\clearpage

# DKIM(DomainKeys Identified Mail)

概要：ヘッダーFromのドメインに対応するDNSレコードを元に、メールの内容が改ざんされていないかを認証します。

（第2版で追加予定）

\clearpage

# DMARC(Domain-based Message Authentication Reporting and Conformance)認証

DMARC認証は、ヘッダーFrom（RFC5322.From）のドメインをベースに認証を行います。また、SPF、SPFアライメント、DKIM、DKIMアライメントの4種類の要素によって構成されています。

状況に従って、14種類※1 の全てのパターンを説明する表が世の中では用いられることがありますが、それら全てを覚える必要はありません。DMARC=passとなるのは、以下の2つの条件のどちらかが満たされている場合です。

1. SPF=passであり、SPFアライメントが合格となるもの
2. DKIM=passであり、DKIMアライメントが合格となるもの

※1 SPF/DKIMがfailした場合、アライメントがpassすることはありません。なので、2^4-2=14通りとなります。

\clearpage

## アライメントについて

技術的には、以下の通りです。

- SPFアライメントとは、ヘッダーFromとエンベロープFrom(Return-Path)のドメインが一致することです。
- DKIMアライメントとは、へッダーFrom と DKIM-Signature ヘッダの d= のドメインが一致することです。

ただ、これだけでは、技術的な正しさはわかっても、これが、本来的に何を意味するのかが分かりません。私の解釈は、以下の通りです。

- SPFアライメントとは、エンベロープFromのドメインが、DNSサーバに登録されているSPFレコードの送信元IPと一致したという結果を元に、さらにエンベロープFromとヘッダーFromのドメインが一致することで、DATAコマンドで記述した内容が、正規のメールサーバから送信されたことが証明されること
- DKIMアライメントとは、ヘッダーFromのドメインのDNSサーバに登録されているDKIMレコードの公開鍵を元に検証することで、送信元IPに関わらず、秘密鍵を持っているサーバからメールを送信したことが証明されること

共通して言えることは、メール全体内容とヘッダーFromのドメインに登録されているDNSサーバの情報を元に、正しいメールであると言えるということです。

逆に言えば、SPFアライメントは、SPFレコードに登録された正規のメール送信サーバからメールが送信できた場合に対して無力※ですし、DKIMアライメントは、秘密鍵が漏れた場合には詐称されてしまいます。

※現実問題として、メールの送信は、SPFレコードに登録された、広いIPレンジに属する共通のメールサーバから送信を行うことさえできれば、SPFやDMARCをpassすることができます。これらの手法は、BreakSPF [https://www.ndss-symposium.org/ndss-paper/breakspf-how-shared-infrastructures-magnify-spf-vulnerabilities-across-the-internet/](https://www.ndss-symposium.org/ndss-paper/breakspf-how-shared-infrastructures-magnify-spf-vulnerabilities-across-the-internet/) として報告されています。

\clearpage

# SPF/DKIM/DMARC のメールログ実例

|  | From(ヘッダーFrom) | SMTPサーバ | Return-Path | DKIM d= | DKIMレコードの公開鍵 |
| --- | --- | --- | --- | --- | --- |
| SPF=pass | @a.test | a.test | - | - | - |
| SPF=fail | @a.test | x.test | - | - | - |
| DKIM=pass | @pass.dkim.a.test | a.test | - | pass.dkim.a.test | pass.dkim.a.test |
| DKIM=fail | @fail.dkim.a.test | a.test | - | fail.dkim.a.test | a.test |
| DMARC=pass | @pass.dkim.a.test | a.test | - | pass.dkim.a.test | pass.dkim.a.test |
| DMARC=pass | @fail.dkim.a.test | a.test | - | fail.dkim.a.test | a.test |
| DMARC=pass | @pass.dkim.a.test | x.test | - | pass.dkim.a.test | pass.dkim.a.test |
| DMARC=fail | @x.test | a.test | @a.test | y.test | y.test |

\clearpage

## SPF

### SPF=pass

![SPFpass-1.png](SPFpass-1.png)

```lua
Return-Path: <user1@a.test>
Received: from spf.mx.b.test (spf.mx.b.test [10.255.2.31])
        by imap.b.test (Postfix) with ESMTPS id 11D113C0B40
        for <user1@spf.b.test>; Mon, 11 Nov 2024 22:59:02 +0900 (JST)
Received: from plain.smtp.a.test (plain.smtp.a.test [10.255.1.20])
        by spf.mx.b.test (Postfix) with ESMTPS id D2EC43C0B32
        for <user1@spf.b.test>; Mon, 11 Nov 2024 22:59:01 +0900 (JST)
Authentication-Results: spf.mx.b.test;
        spf=pass (spf.mx.b.test: domain of user1@a.test designates 10.255.1.20 as permitted sender) smtp.mailfrom=user1@a.test
Received: from a.test (client.a.test [10.255.1.10])
        by plain.smtp.a.test (Postfix) with SMTP id CF7D13C0B2A
        for <user1@spf.b.test>; Mon, 11 Nov 2024 22:59:00 +0900 (JST)
Message-ID: <20241111225901.7568@a.test>
Date: Mon, 11 Nov 2024 22:59:01 +0900
From: user1@a.test
To:   user1@spf.b.test
Subject: scenario2-1 (mail from user1@a.test)

Hello user1@spf.b.test!
```

\clearpage

### SPF=fail

![SPFfail-1.png](SPFfail-1.png)

```lua
Return-Path: <user1@a.test>
Received: from spf.mx.b.test (spf.mx.b.test [10.255.2.31])
        by imap.b.test (Postfix) with ESMTPS id BF87F3C0B45
        for <user1@spf.b.test>; Mon, 11 Nov 2024 22:59:13 +0900 (JST)
Received: from plain.smtp.x.test (plain.smtp.x.test [10.255.24.20])
        by spf.mx.b.test (Postfix) with ESMTPS id A73933C0B48
        for <user1@spf.b.test>; Mon, 11 Nov 2024 22:59:13 +0900 (JST)
Authentication-Results: spf.mx.b.test;
        spf=fail (spf.mx.b.test: domain of user1@a.test does not designate 10.255.24.20 as permitted sender) smtp.mailfrom=user1@a.test
Received: from a.test (client.a.test [10.255.1.10])
        by plain.smtp.x.test (Postfix) with SMTP id B38B43C0B45
        for <user1@spf.b.test>; Mon, 11 Nov 2024 22:59:12 +0900 (JST)
Message-ID: <20241111225912.28233@a.test>
Date: Mon, 11 Nov 2024 22:59:13 +0900
From: user1@a.test
To:   user1@spf.b.test
Subject: scenario2-2 (mail from user1@a.test)

Hello user1@spf.b.test!
```

\clearpage

## DKIM

### DKIM=pass

![DKIMpass-1.png](DKIMpass-1.png)

```
Return-Path: <user1@pass.dkim.a.test>
Received: from dkim.mx.b.test (dkim.mx.b.test [10.255.2.32])
        by imap.b.test (Postfix) with ESMTPS id 5D0923C0B5C
        for <user1@dkim.b.test>; Mon, 11 Nov 2024 22:59:30 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.21])
        by dkim.mx.b.test (Postfix) with ESMTPS id 2AC753C0B4E
        for <user1@dkim.b.test>; Mon, 11 Nov 2024 22:59:30 +0900 (JST)
Authentication-Results: dkim.mx.b.test;
        dkim=pass header.d=pass.dkim.a.test header.s=smtpbook header.b=HXOHX5f4
Received: from pass.dkim.a.test (client.a.test [10.255.1.10])
        by dkim.smtp.a.test (Postfix) with SMTP id 2669F3C0B45
        for <user1@dkim.b.test>; Mon, 11 Nov 2024 22:59:29 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pass.dkim.a.test;
        s=smtpbook; t=1731333570;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=0pdj9wqws+KIJQqIWGPQakvN114IPDt1CK4ekSU+NIs=;
        b=HXOHX5f4PMUXvhYONo7sr9GDmcwH8IXk330Y63AA8j+8zydcFC1PPpohjRMDamRvjuVkuV
        98Vr5nA83Jk1Bp0usAWF2jyY68gvsRnczDEINctGmsD54+M7/ET3HHtD3tEMJu2jxvWmmm
        ZyKHgk6NMxYzWjeamCqHFbWQKNKFdhE+sTkW8PfXJMhhwd/id2Si/a20cleERO7BSPWD+2
        dLuwxsjU5iklYWCwyitLBRzN422CGc60SgyPBYZ1bLZlt8I3P5ypC5wpJhKVbKYmtVXFGC
        jtVSWTP15ja3N1ftlqFT94rifbA928h1oCcYBQIgBIDEadL7xqUrvuO30RtwWg==
Message-ID: <20241111225929.22082@pass.dkim.a.test>
Date: Mon, 11 Nov 2024 22:59:29 +0900
From: user1@pass.dkim.a.test
To:   user1@dkim.b.test
Subject: scenario3-1 (mail from user1@pass.dkim.a.test)

Hello user1@dkim.b.test!
```

\clearpage

### DKIM=fail

![DKIMfail-1.png](DKIMfail-1.png)

```lua
Return-Path: <user1@fail.dkim.a.test>
Received: from dkim.mx.b.test (dkim.mx.b.test [10.255.2.32])
        by imap.b.test (Postfix) with ESMTPS id E10EC3C0B21
        for <user1@dkim.b.test>; Mon, 11 Nov 2024 22:59:43 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.21])
        by dkim.mx.b.test (Postfix) with ESMTPS id C879A3C0B66
        for <user1@dkim.b.test>; Mon, 11 Nov 2024 22:59:43 +0900 (JST)
Authentication-Results: dkim.mx.b.test;
        dkim=fail ("headers rsa verify failed") header.d=fail.dkim.a.test header.s=smtpbook header.b="UUjtdzq/"
Received: from fail.dkim.a.test (client.a.test [10.255.1.10])
        by dkim.smtp.a.test (Postfix) with SMTP id B33773C0B21
        for <user1@dkim.b.test>; Mon, 11 Nov 2024 22:59:42 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fail.dkim.a.test;
        s=smtpbook; t=1731333583;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=0pdj9wqws+KIJQqIWGPQakvN114IPDt1CK4ekSU+NIs=;
        b=UUjtdzq/m1EvY948YX5EQnSDvpqi0w0JQgWJMq6hCxuCLpKQkLdMGDB+VfwHsR3cd64lKA
        eeqU5WRt5uX3hsBBwAP3TtmvGFW3T87IoaLi9m9hWGNjN8JQ0KSccqLqbMCj8RGQOgm/Ko
        H8uO2LHznKER9mfdk2bxCsOj35aqISUlcx9E0eRGyH3tAEhYUDR64bq3IORl2/Lf4EO00q
        8FCtw2IrGfDF7VZi8Rh2oKWXadbpF3KQy9LviamqT4kT3pAmdVqH1v9nR3+x9vywnJ7xhb
        azVCkKL+lRnoCz/0oq92PKf1XBrErg7jOotYjZcmfEnk2kew0xE0/KL2+QVYAg==
Message-ID: <20241111225942.24430@fail.dkim.a.test>
Date: Mon, 11 Nov 2024 22:59:43 +0900
From: user1@fail.dkim.a.test
To:   user1@dkim.b.test
Subject: scenario3-2 (mail from user1@fail.dkim.a.test)

Hello user1@dkim.b.test!
```

\clearpage

## DMARC

### DMARC=pass(SPF=pass, SPF aligned, DKIM=pass, DKIM aligned)

SPF

| ヘッダーFrom | user1@pass.dkim.a.test |
| --- | --- |
| Return-Path | user1@pass.dkim.a.test |
| SPFレコード | pass.dkim.a.test "v=spf1 ip4:10.255.1.20/31 -all” |
| 送信元サーバ(IP) | dkim.smtp.a.test(10.255.1.21) |
| 結果 | spf=pass |

DKIM

| ヘッダーFrom | user1@pass.dkim.a.test |
| --- | --- |
| DKIM-Signature d= | d=pass.dkim.a.test |
| 結果 | dkim=pass |

```lua
Return-Path: <user1@pass.dkim.a.test>
Received: from dmarc.mx.b.test (dmarc.mx.b.test [10.255.2.33])
        by imap.b.test (Postfix) with ESMTPS id 1661E3C0B21
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 22:59:59 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.21])
        by dmarc.mx.b.test (Postfix) with ESMTPS id E2F6D3C0B6A
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 22:59:58 +0900 (JST)
Authentication-Results: dmarc.mx.b.test;
        dkim=pass header.d=pass.dkim.a.test header.s=smtpbook header.b=F6rlfsvS;
        spf=pass (dmarc.mx.b.test: domain of user1@pass.dkim.a.test designates 10.255.1.21 as permitted sender) smtp.mailfrom=user1@pass.dkim.a.test;
        dmarc=pass (policy=quarantine) header.from=a.test
Received: from pass.dkim.a.test (client.a.test [10.255.1.10])
        by dkim.smtp.a.test (Postfix) with SMTP id D9ED03C0B21
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 22:59:57 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pass.dkim.a.test;
        s=smtpbook; t=1731333598;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=F6rlfsvSbuyAeFj5z0P/BpLxYLXbualYDGS0Ufljj4KXmcHfktoSNsMXI8pkBl0iEdzNps
        V2R8TR1xhbp46uJvjV3K10az+F0g5cfcQTo6iqKAxA5oI9fR5YEA7SVGVZT/nMyOYR1yZu
        XgGe8eyfJ373pITFBBH7MjhJqQ/Qfwb1T7e80c3M+ou4NbCGTEc8a//hBOs+iV5dEvZYQQ
        7cu3/fHXE7TTKJi+PyDtvGfoMLrsQaSH3SzGQLOA7V1xDq5etGA8NRL4UQkCNctlkPaDEj
        wDZZxwLM1sB4g4o9B1WtoKSS8uNKK98vLb/4c0n+nhkfTPidw98CMBMWAa1IOw==
Message-ID: <20241111225958.14795@pass.dkim.a.test>
Date: Mon, 11 Nov 2024 22:59:58 +0900
From: user1@pass.dkim.a.test
To:   user1@dmarc.b.test
Subject: scenario4-1 (mail from user1@pass.dkim.a.test)

Hello user1@dmarc.b.test!
```

![DMARC1-1.png](DMARC1-1.png)

\clearpage

### DMARC=pass(SPF=pass, SPF aligned, DKIM=fail)

SPF

| ヘッダーFrom | user1@fail.dkim.a.test |
| --- | --- |
| Return-Path | user1@fail.dkim.a.test |
| SPFレコード | "v=spf1 ip4:10.255.1.20/31 -all” |
| 送信元サーバ(IP) | dkim.smtp.a.test(10.255.1.21) |
| 結果 | spf=pass |

DKIM

| ヘッダーFrom | user1@fail.dkim.a.test |
| --- | --- |
| DKIM-Signature d= | d=fail.dkim.a.test |
| 結果 | dkim=fail("headers rsa verify failed") |

```lua
Return-Path: <user1@fail.dkim.a.test>
Received: from dmarc.mx.b.test (dmarc.mx.b.test [10.255.2.33])
        by imap.b.test (Postfix) with ESMTPS id 30B583C0B21
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:14 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.21])
        by dmarc.mx.b.test (Postfix) with ESMTPS id 191733C0B74
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:14 +0900 (JST)
Authentication-Results: dmarc.mx.b.test;
        dkim=fail ("headers rsa verify failed") header.d=fail.dkim.a.test header.s=smtpbook header.b=khuhmNBv;
        spf=pass (dmarc.mx.b.test: domain of user1@fail.dkim.a.test designates 10.255.1.21 as permitted sender) smtp.mailfrom=user1@fail.dkim.a.test;
        dmarc=pass (policy=quarantine) header.from=a.test
Received: from fail.dkim.a.test (client.a.test [10.255.1.10])
        by dkim.smtp.a.test (Postfix) with SMTP id 1CD2F3C0B21
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:13 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fail.dkim.a.test;
        s=smtpbook; t=1731333614;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=khuhmNBvrxEVcu4nhcxLYATWnZ73vXz8tchytQ07ndRxzJRAHWyXw3GF36CyMbzGgH73O3
        zp78BhglJpMtTBtu4EgPO5dX1QIWfC8iBI7z3wzlqehzzJTY4cSTxryXq90iNph84Tr0Q6
        5wpsuuSIVjjQFwLNbYiAnRfQbetaolI1ho9Ld/26YNwfgpZ9ydh0ZqE3z5YuiXYjuD/DHh
        ZChdTDsiecA4b5Igben330RQuwVBiquXTcb1TKO1ppqWJGYJtCgxWaKSNYlSfD3EH/9XKz
        nhANLbVJdRcJridVYP6CKYqXymLk8GsNqUS7ofM/+2LS2B+VuItdCTbhlcpXZA==
Message-ID: <20241111230013.28558@fail.dkim.a.test>
Date: Mon, 11 Nov 2024 23:00:13 +0900
From: user1@fail.dkim.a.test
To:   user1@dmarc.b.test
Subject: scenario4-2 (mail from user1@fail.dkim.a.test)

Hello user1@dmarc.b.test!
```

![DMARC2-1.png](DMARC2-1.png)

\clearpage

### DMARC=pass(SPF=fail, DKIM=pass, DKIM aligned)

SPF

| ヘッダーFrom | user1@pass.dkim.a.test |
| --- | --- |
| Return-Path | user1@pass.dkim.a.test |
| SPFレコード | pass.dkim.a.test "v=spf1 ip4:10.255.1.20/31 -all” |
| 送信元サーバ(IP) | dkim.smtp.x.test(10.255.24.21) |
| 結果 | spf=fail |

DKIM

| ヘッダーFrom | user1@pass.dkim.a.test |
| --- | --- |
| DKIM-Signature d= | d=pass.dkim.a.test |
| 結果 | dkim=pass |

```lua
Return-Path: <user1@pass.dkim.a.test>
Received: from dmarc.mx.b.test (dmarc.mx.b.test [10.255.2.33])
        by imap.b.test (Postfix) with ESMTPS id 02C013C0B21
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:35 +0900 (JST)
Received: from dkim.smtp.x.test (dkim.smtp.x.test [10.255.24.21])
        by dmarc.mx.b.test (Postfix) with ESMTPS id DCEFF3C0B78
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:34 +0900 (JST)
Authentication-Results: dmarc.mx.b.test;
        dkim=pass header.d=pass.dkim.a.test header.s=smtpbook header.b=ORWUqDxY;
        spf=fail (dmarc.mx.b.test: domain of user1@pass.dkim.a.test does not designate 10.255.24.21 as permitted sender) smtp.mailfrom=user1@pass.dkim.a.test;
        dmarc=pass (policy=quarantine) header.from=a.test
Received: from pass.dkim.a.test (client.a.test [10.255.1.10])
        by dkim.smtp.x.test (Postfix) with SMTP id D91FF3C0B21
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:33 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pass.dkim.a.test;
        s=smtpbook; t=1731333634;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=ORWUqDxY5+og4uOLWr6o5egYETOMrISUccxcCLayflr1uSCgel7BsOpSDEM87J+Sx5nUYc
        nhC6L2wTZIV/C6AgcKRYilcT9j5UmHnFyEYNRIrn4gPBYz4jXH2ee9CTGlCmK4WMXDAi6l
        bzvmSRs8PIjBmO7uY02HJQPdgIYIejhyPSzozcirbpBicTOOI4DPbfRW2uAN1UYpXFles8
        T2wj38IM99Ie40F1kEt7MEz9CYjaQk9/p9mRTr8EkZXdjkOqeOfrljPPtKUmgBsLczIp3z
        aAAX9wkgax0qyCkGIaNpvUHaGwtQiz0M9CuwYuP+ZqmfAhQvXAS2MTU/Hyb1Mw==
Message-ID: <20241111230034.7867@pass.dkim.a.test>
Date: Mon, 11 Nov 2024 23:00:34 +0900
From: user1@pass.dkim.a.test
To:   user1@dmarc.b.test
Subject: scenario4-3 (mail from user1@pass.dkim.a.test)

Hello user1@dmarc.b.test!
```

![DMARC3-1.png](DMARC3-1.png)

\clearpage

### DMARC=fail(SPF=pass, SPF not aligned, DKIM=pass, DKIM not aligned)

SPF

| ヘッダーFrom | user1@x.test |
| --- | --- |
| Return-Path | user1@a.test |
| SPFレコード | a.test "v=spf1 ip4:10.255.1.20/31 -all” |
| 送信元サーバ(IP) | dkim.smtp.a.test(10.255.1.21) |
| 結果 | spf=pass |

DKIM

| ヘッダーFrom | user1@x.test |
| --- | --- |
| DKIM-Signature d= | d=y.test |
| 結果 | dkim=pass |

DMARC

| ヘッダーFrom | user1@x.test |
| --- | --- |
| Return-Path | user1@a.test |
| DKIM-Signature d= | d=y.test |
| 結果 | dmarc=fail |

```lua
Return-Path: <user1@a.test>
Received: from dmarc.mx.b.test (dmarc.mx.b.test [10.255.2.33])
        by imap.b.test (Postfix) with ESMTPS id 91AF63C0B20
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:53 +0900 (JST)
Received: from dkim.smtp.a.test (dkim.smtp.a.test [10.255.1.21])
        by dmarc.mx.b.test (Postfix) with ESMTPS id 765833C0B85
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:53 +0900 (JST)
Authentication-Results: dmarc.mx.b.test;
        dkim=pass header.d=y.test header.s=smtpbook header.b=uOhxNxzm;
        spf=pass (dmarc.mx.b.test: domain of user1@a.test designates 10.255.1.21 as permitted sender) smtp.mailfrom=user1@a.test;
        dmarc=fail reason="SPF not aligned (relaxed), DKIM not aligned (relaxed)" header.from=x.test (policy=reject)
Received: from x.test (client.a.test [10.255.1.10])
        by dkim.smtp.a.test (Postfix) with SMTP id 789F43C0B20
        for <user1@dmarc.b.test>; Mon, 11 Nov 2024 23:00:52 +0900 (JST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=y.test; s=smtpbook;
        t=1731333653;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc; bh=4O5lFigIhxLU8If/5QjKchggSnc7Yxld80E41+l39XE=;
        b=uOhxNxzmXzrlirTgBELshntqF6xKNgypuq7LAH0Us9K6PVH+H4HpKrjuvkAapKR9MotwMm
        x0SaeitVbawxpftxQi1KC5YaMOjUOepe+boPZ29mHTpVctncYrENxILvPE3gC588G6DAjz
        LUNfS2jdwQvNuntR53DOGy17Vk/EVPWfnsL7DtF9MrZo6c3l4wRi74pG6b8uSEnjPCQ9Ca
        2SBx2JmJpHnGd1dcSIl+aj8lMxDwVaa8saxjciHp81JFfVOV/vzz9ZlPtTwLdfV++i9lNS
        oacORDyKix5XWPeNkA2UkLeCm6NT5PJfbw3QTqwM9T3jh3ic5+pxMYgYkl8NGw==
Message-ID: <20241111230052.26219@x.test>
Date: Mon, 11 Nov 2024 23:00:52 +0900
From: user1@x.test
To:   user1@dmarc.b.test
Subject: scenario4-4 (mail from user1@x.test)

Hello user1@dmarc.b.test!
```

![DMARC4-1.png](DMARC4-1.png)
