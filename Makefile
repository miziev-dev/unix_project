# Переменная для вызова Docker Compose (автоопределение)
DC := $(shell command -v docker compose > /dev/null 2>&1 && echo "docker-compose" || echo "docker-compose")

.PHONY: setup up down clean backup test hardening

# ... (остальные строки те же)

up: setup hardening
	@echo "==> Запуск кластера MongoDB..."
	cd deploy && docker-compose up -d --build

setup:
	@echo "==> Подготовка хоста и генерация ключей кластера..."
	bash deploy/scripts/bootstrap.sh

down:
	@echo "==> Остановка кластера..."
	cd deploy && $(DC) down

clean:
	@echo "==> Полная очистка стенда (ВНИМАНИЕ: удаляет данные!)"
	cd deploy && $(DC) down -v
	sudo rm -rf deploy/docker/mongodb/keys/*

backup:
	@echo "==> Запуск резервного копирования..."
	bash deploy/scripts/backup.sh

test:
	@echo "==> Запуск интеграционных тестов кластера..."
	bash deploy/scripts/tests/test_mongo.sh

hardening:
	@echo "==> Применение политик безопасности ОС..."
	sudo bash security/hardening.sh
ps:
	cd deploy && docker-compose ps

logs:
	cd deploy && docker-compose logs -f
