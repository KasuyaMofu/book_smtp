.PHONY: build-all up down stop view build 

build/images:
	cd images && docker compose --env-file ../.env build && cd ..
build/docker:
	docker compose build
build: build/images build/docker

up:
	docker compose up
down:
	docker compose down
stop:
	docker compose stop

view:
	docker compose exec b-imap /example/receive.sh user1

## 1hop(client -> imap)
scenario1/up:
	docker compose up -d dns a-client b-imap
scenario1/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@imap.b.test imap.b.test

## add MTA(relay) servers (client -> smtp -> mx -> imap)
scenario2/up:
	docker compose up dns a-client a-smtp-plain b-mx b-imap
scenario2/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@b.test     plain.smtp.a.test

## SPF check
scenario3/up:
	docker compose up dns a-client a-smtp-plain b-mx-spf  b-imap
scenario3/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@spf.b.test plain.smtp.a.test

## SPF fail
scenario4/up:
	docker compose up dns a-client b-mx-spf  b-imap
scenario4/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@dmarc.b.test spf.mx.b.test

## DKIM signed and verified
scenario5/up:
	docker compose up dns a-client a-smtp-dkim b-mx-dkim  b-imap
scenario5/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@dkim.b.test dkim.smtp.a.test

## dmarc=pass(dkim=pass, spf=pass, SPF/DKIM aligned)
scenario6/up:
	docker compose up dns a-client a-smtp-dkim b-mx-dmarc b-imap
scenario6/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@dmarc.b.test dkim.smtp.a.test

## dmarc=pass(dkim=pass, spf=fail, SPF not aligned)
scenario7/up: scenario6/up
scenario7/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@dmarc.b.test dkim.smtp.a.test user1@fail.a.test

## dmarc=pass(dkim=pass, spf=pass, DKIM not aligned)
scenario8/up: scenario6/up
scenario8/send:
	docker compose exec a-client     /example/send.sh user1@external.x.test user1@dmarc.b.test dkim.smtp.a.test user1@external.x.test

## dmarc=fail(dkim=pass, spf=pass, SPF/DKIM not aligned)
scenario9/up: scenario6/up
scenario9/send:
	docker compose exec a-client     /example/send.sh user1@x.test user1@dmarc.b.test dkim.smtp.a.test user1@a.test
