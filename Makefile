# Используем docker compose v2 (плагин) — обязательно наличие docker-compose-plugin
DC := docker compose

.PHONY: setup up down clean backup test hardening ps logs

up: setup hardening
	@echo "==> Запуск кластера MongoDB..."
	cd deploy && $(DC) up -d --build

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
	cd deploy && $(DC) ps

logs:
	cd deploy && $(DC) logs -f
