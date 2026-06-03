#!/bin/bash
# @file hardening.sh
# @brief Настройка политик безопасности хоста и контейнерной среды.
# @author Мизиев Рашид Саит-Алиевич (rasidmiziev279@gmail.com)
# @date 2026-05-28
# @version 1.1.0
# @license GNU GPLv3 <https://gnu.org>
#
# @details
# Данный сценарий выполняет следующие этапы:
# 1. Установка прав 400 на файл ключа репликации MongoDB.
# 2. Настройка межсетевого экрана UFW по принципу «запрещено всё, что не разрешено явно».
# 3. Проверка запуска скрипта не от имени root.
set -euo pipefail

KEY_FILE="./deploy/docker/mongodb/keys/replica.key"

# @brief Установка прав доступа на файл ключа репликации.
# @description MongoDB требует прав 400 для keyFile, иначе контейнер не запустится.
# @return 0 при успехе, 1 если файл ключа не найден.
setup_key_permissions() {
    echo "[*] Настройка прав доступа к файлам ключей..."
    if [ -f "${KEY_FILE}" ]; then
        chmod 400 "${KEY_FILE}"
        echo "[+] Права на replica.key установлены (400)"
        return 0
    else
        echo "[!] Файл ключа не найден по пути ${KEY_FILE}, пропуск." >&2
        return 1
    fi
}

# @brief Настройка межсетевого экрана UFW.
# @description Политика «запрещено всё входящее, кроме явно разрешённых портов».
# Порт MongoDB (27017) намеренно закрыт снаружи — доступ только внутри Docker-сети.
# @return 0 при успешной настройке UFW.
setup_firewall() {
    echo "[*] Настройка Firewall (UFW)..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 22/tcp    # SSH — доступ администратора
    sudo ufw allow 80/tcp    # HTTP
    sudo ufw allow 443/tcp   # HTTPS
    sudo ufw --force enable
    echo "[+] UFW настроен: порты 22, 80, 443 открыты. MongoDB (27017) закрыт снаружи."
}

# @brief Проверка того, что скрипт не запущен от root.
# @return 0 если пользователь не root, выход с предупреждением если root.
check_not_root() {
    if [ "${EUID}" -eq 0 ]; then
        echo "[!] ВНИМАНИЕ: Скрипт запущен от root. Рекомендуется запускать от пользователя с sudo." >&2
    fi
}

# --- Главная точка входа ---
check_not_root
setup_key_permissions
setup_firewall

echo "[*] Hardening завершён успешно."
