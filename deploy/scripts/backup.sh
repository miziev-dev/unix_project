#!/bin/bash
set -euo pipefail
# @file backup.sh
# @brief Скрипт горячего резервного копирования коллекций MongoDB с ротацией.
# @author DevOps Engineer

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="mongo_backup_${TIMESTAMP}.gz"

# Вытягиваем пароли из .env
source .env

mkdir -p "${BACKUP_DIR}"

echo "LOG: Запуск mongodump из контейнера mongo-primary..."
docker exec mongo-primary mongodump \
    -u "${MONGO_INITDB_ROOT_USERNAME}" \
    -p "${MONGO_INITDB_ROOT_PASSWORD}" \
    --authenticationDatabase admin \
    --archive="/tmp/${ARCHIVE_NAME}" \
    --gzip

echo "LOG: Извлечение бэкапа на хост-машину..."
docker cp "mongo-primary:/tmp/${ARCHIVE_NAME}" "${BACKUP_DIR}/${ARCHIVE_NAME}"
docker exec mongo-primary rm "/tmp/${ARCHIVE_NAME}"

echo "LOG: Ротация логов: удаляем бэкапы старше 7 дней..."
find "${BACKUP_DIR}" -type f -name "*.gz" -mtime +7 -exec rm {} \;

echo "SUCCESS: Бэкап ${ARCHIVE_NAME} успешно создан."
