.PHONY: build base up down bash/client bash/b-imap bash/a-smtp-plain bash/a-smtp-dkim

build-all:
	cd images && docker compose build && cd .. && docker compose build
up:
	docker compose up
down:
	docker compose down
build:
	docker compose build

senario1/up:
	docker compose up dns a-client a-smtp-plain b-imap
senario1/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@imap.b.test plain.smtp.a.test
senario1/check:
	docker compose exec b-imap /example/receive.sh user1
senario2:
	docker compose up dns a-client a-smtp-plain b-mx-spf  b-imap
senario3:
	docker compose up dns a-client a-smtp-dkim b-mx-dkim  b-imap
senario4:
	docker compose up dns a-client a-smtp-dkim b-mx-dmarc b-imap

