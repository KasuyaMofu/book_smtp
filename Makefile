.PHONY: build-all up down build scenario1 scenario2 scenario3 scenario4 

build-all:
	cd images && docker compose build && cd .. && docker compose build
up:
	docker compose up
down:
	docker compose down
build:
	docker compose build

scenario1/up:
	docker compose up dns a-client a-smtp-plain b-imap
scenario1/send:
	docker compose exec a-client     /example/send.sh user1@a.test user1@imap.b.test plain.smtp.a.test
scenario1/check:
	docker compose exec b-imap /example/receive.sh user1
scenario2:
	docker compose up dns a-client a-smtp-plain b-mx-spf  b-imap
scenario3:
	docker compose up dns a-client a-smtp-dkim b-mx-dkim  b-imap
scenario4:
	docker compose up dns a-client a-smtp-dkim b-mx-dmarc b-imap

