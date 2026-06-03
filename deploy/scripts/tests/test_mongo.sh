#!/bin/bash
# @file test_mongo.sh
# @brief Интеграционные тесты работоспособности кластера MongoDB Replica Set.
# @author Мизиев Рашид Саит-Алиевич (rasidmiziev279@gmail.com)
# @date 2026-05-28
# @version 1.1.0
# @license GNU GPLv3 <https://gnu.org>
#
# @details
# Данный сценарий выполняет следующие проверки:
# 1. Ожидание готовности контейнера mongo-primary.
# 2. Проверка статуса Replica Set (rs.status().ok == 1).
# 3. Проверка базовой операции записи в базу данных.
set -euo pipefail

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# @brief Ожидание готовности MongoDB с таймаутом.
# @return 0 если MongoDB ответила на ping, 1 если таймаут истёк.
wait_for_mongo() {
    for i in {1..30}; do
        if docker exec mongo-primary mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
            echo -e "${GREEN}LOG: MongoDB Primary готова!${NC}"
            return 0
        fi
        echo "Ожидание... (${i}/30)"
        sleep 2
    done
    echo -e "${RED}ERROR: MongoDB не запустилась за 60 секунд!${NC}" >&2
    return 1
}

# @brief Проверка состояния Replica Set.
# @return 0 если Replica Set активен, 1 если нет.
test_replica_set() {
    echo "LOG: Тест 1. Проверка состояния Replica Set..."
    RS_STATUS=$(docker exec mongo-primary mongosh --quiet --eval "rs.status().ok" 2>/dev/null || echo "0")
    if [ "${RS_STATUS}" = "1" ]; then
        echo -e "${GREEN}SUCCESS: Replica Set активен.${NC}"
        return 0
    else
        echo -e "${RED}ERROR: Replica Set не инициализирован!${NC}" >&2
        return 1
    fi
}

# @brief Проверка операции записи в базу данных.
# @return 0 если запись прошла успешно, 1 при ошибке.
test_write_operation() {
    echo "LOG: Тест 2. Проверка операции записи..."
    if docker exec mongo-primary mongosh --quiet \
        --eval "db.test.insertOne({test: 'data', ts: new Date()})" > /dev/null 2>&1; then
        echo -e "${GREEN}SUCCESS: Запись в базу прошла успешно.${NC}"
        return 0
    else
        echo -e "${RED}ERROR: Ошибка записи в базу!${NC}" >&2
        return 1
    fi
}

# --- Главная точка входа ---
wait_for_mongo
test_replica_set
test_write_operation

echo "---------------------------------------"
echo -e "${GREEN}ИТОГ: Все тесты пройдены успешно!${NC}"
