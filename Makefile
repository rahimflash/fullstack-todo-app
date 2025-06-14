.PHONY: help build up down restart logs test clean backup restore

help:
	@echo "Available commands:"
	@echo "  make build    - Build all containers"
	@echo "  make up       - Start all containers"
	@echo "  make down     - Stop all containers"
	@echo "  make restart  - Restart all containers"
	@echo "  make logs     - View container logs"
	@echo "  make test     - Run container tests"
	@echo "  make testall  - Run advanced container tests"
	@echo "  make clean    - Clean up everything"
	@echo "  make backup   - Backup MongoDB"
	@echo "  make restore  - Restore MongoDB"

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

test:
	./scripts/test-containers.sh

testall:
	./scripts/advanced-test.sh

clean:
	docker compose down -v
	docker system prune -af

backup:
	./scripts/backup-mongodb.sh

restore:
	@read -p "Enter backup file path: " backup_file; \
	./scripts/restore-mongodb.sh $$backup_file

prod:
	docker compose up -d --build