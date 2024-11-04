.PHONY: 1-send 1-receive 2-send 2-receive base/build build up

1-send:
	docker compose exec a-client     /example/1-send.sh

1-receive:
	docker compose exec b-imap /example/1-receive.sh

2-send:
	docker compose exec a-client     /example/2-send-dkim.sh

2-receive:
	docker compose exec b-imap /example/1-receive.sh

base/build:
	cd base && docker compose build

build:
	docker compose down
	docker compose build
up:
	docker compose up

up-dkim:
	docker compose up dns a-client a-smtp-dkim b-imap b-mx-spf-dkim

log-rspamd:
	docker compose exec b-mx-spf-dkim tail -f /var/log/rspamd/rspamd.log

bash/client:
	docker compose exec a-client bash
bash/b-imap:
	docker compose exec b-imap bash
bash/a-smtp-plain:
	docker compose exec a-smtp-plain bash
bash/a-smtp-dkim:
	docker compose exec a-smtp-dkim bash