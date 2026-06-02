#!/bin/bash
set -euo pipefail
# @file bootstrap.sh
# @brief Первичная подготовка ОС, создание сетей и генерация ключей репликации.
# @author Tech Lead
# @version 1.0.0

KEY_DIR="deploy/docker/mongodb/keys"
KEY_FILE="${KEY_DIR}/replica.key"

echo "LOG: Проверка файла .env..."
if [[ ! -f ".env" ]]; then
    echo "ERROR: Файл .env не найден! Скопируйте .env.example в .env и настройте пароли." >&2
    exit 1
fi

echo "LOG: Подготовка директорий и ключей кластера..."
mkdir -p "${KEY_DIR}" config/mongodb

# Генерация ключа репликации (если еще не создан)
if [[ ! -f "${KEY_FILE}" ]]; then
    echo "LOG: Генерируем ключ авторизации Replica Set..."
    openssl rand -base64 756 > "${KEY_FILE}"
    # Права строго 400 и владелец 999 (пользователь mongodb в официальном образе)
    chmod 400 "${KEY_FILE}"
    sudo chown 999:999 "${KEY_FILE}"
fi

echo "LOG: Настройка прав на конфигурацию..."
chmod 644 config/mongodb/mongod.conf

echo "SUCCESS: Базовая настройка завершена. Запустите 'make up'."
