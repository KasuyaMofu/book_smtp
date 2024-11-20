# はじめに

近年、日本では、Google社が「メール送信者のガイドライン（旧称: 一括送信ガイドライン）」発表してからというもの、神奈川県の高校出願システムにおけるメール送信の事件などが発生し、メール管理者だけでなく、様々な人々がメールへ関心を寄せることとなりました。

そんな世界の状況において、メールの送信したい場合にまず考えることは、「いかにしてメールサーバを自分で運用をしないか」ということは、メールを管理する立場の方であれば、同意いただけるかと思います。明確な理由がない限り、高度なメールの知識を持ったエンジニアが運用しているであろう、メール送信のSaaSを利用することをオススメします。

それでも、どうしても、自前でメール送信を行わなければならない、またはメールの運用を行わなければならない、つまり、**SMTPを取り扱わないといけない方**に向けて、この本は書かれています。

## 内容

この本では、メール通信の内容と、メールサーバに保管されたメールのソースコードの実例を用いながら、以下の事柄について解説を行い、**メールに関するトラブルシューティングに、最低限必要な知識を学ぶこと**を目的とします。

- SMTP(Simple Mail Transfer Protocol)
- SPF(Sender Policy Framework)
- DKIM(DomainKeys Identified Mail)
- DMARC(Domain-based Message Authentication Reporting and Conformance)認証

尚、初版では、以下の内容については取り扱いません。

- DMARC Report
- ARC(Authenticated Received Chain)

\clearpage

## 動作環境

この文書では、以下のURLのリポジトリの成果物を用いています。 `docker compose` が実行できる環境であれば、誰もが検証可能です。 動作の際には、いくらかの注意事項がありますので、リポジトリを確認してください。

[https://github.com/KasuyaMofu/smtpbook/tree/v1](https://github.com/KasuyaMofu/smtpbook/tree/v1)

（本書は、 v1 ブランチの情報を元に構成しています。）

本書で使用している主要なソフトウェアのバージョンは以下の通りです。

- Ubuntu 24.04 (Noble)
- Docker 24.0.5
- Postfix 3.8.6
- Rspamd 3.8.1
- Unbound 1.19.2

## 謝辞

素敵なイラストを描いていただいた yuukin さんに感謝いたします。

また、本文を作成する上で、技術書典さんのRe:VIEWテンプレートを使用しています。

[https://github.com/TechBooster/ReVIEW-Template](https://github.com/TechBooster/ReVIEW-Template)

## 免責事項

本書に記載された内容は、情報の提供のみを目的としています。したがって、本書を用いた開発、製作、運用は、必ずご自身の責任と判断によって行ってください。これらの情報による開発、製作、運用の結果について、著者はいかなる責任も負いません。