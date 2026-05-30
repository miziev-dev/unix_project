#!/bin/bash

# Цвета для красивого вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "LOG: Ожидание готовности MongoDB..."

# 1. Цикл ожидания, пока контейнер не ответит на пинг
for i in {1..30}; do
    if docker exec mongo-primary mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo -e "${GREEN}LOG: MongoDB Primary готова!${NC}"
        break
    fi
    echo "Ожидание..."
    sleep 2
    if [ $i -eq 30 ]; then
        echo -e "${RED}ERROR: MongoDB не запустилась за 60 секунд!${NC}"
        exit 1
    fi
done

# 2. Проверка состояния Replica Set
echo "LOG: Тест 1. Проверка состояния Replica Set..."
RS_STATUS=$(docker exec mongo-primary mongosh --quiet --eval "rs.status().ok")

if [ "$RS_STATUS" == "1" ]; then
    echo -e "${GREEN}SUCCESS: Replica Set активен.${NC}"
else
    echo -e "${RED}ERROR: Replica Set не инициализирован!${NC}"
    exit 1
fi

# 3. Проверка записи/чтения (базовая функциональность)
echo "LOG: Тест 2. Проверка операции записи..."
docker exec mongo-primary mongosh --quiet --eval "db.test.insert({test: 'data'});" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: Запись в базу прошла успешно.${NC}"
else
    echo -e "${RED}ERROR: Ошибка записи в базу!${NC}"
    exit 1
fi

echo "---------------------------------------"
echo -e "${GREEN}ИТОГ: Все тесты пройдены успешно!${NC}"
