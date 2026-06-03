#!/bin/bash

# --- Security Hardening Script ---
# Роль: Security Engineer
# Задача: Обеспечение безопасности хоста и контейнеров

# 1. Проверка прав доступа к ключу репликации (MongoDB)
# MongoDB требует прав 400 для keyFile, иначе контейнер не запустится
echo "[*] Настройка прав доступа к файлам ключей..."
KEY_FILE="./deploy/docker/mongodb/keys/replica.key"
if [ -f "$KEY_FILE" ]; then
    chmod 400 "$KEY_FILE"
    echo "[+] Права на replica.key установлены (400)"
else
    echo "[!] Файл ключа не найден по пути $KEY_FILE, пропуск."
fi

# 2. Настройка UFW (Firewall)
# Внимание: убедитесь, что SSH (порт 22) разрешен, иначе потеряете связь!
echo "[*] Настройка Firewall (UFW)..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp       # SSH
sudo ufw allow 80/tcp       # Nginx/Web
sudo ufw allow 443/tcp      # Nginx/HTTPS
# Порт MongoDB (27017) открывать наружу НЕ нужно, если приложение внутри Docker
# Достаточно оставить его закрытым для внешнего мира
echo "[+] UFW настроен: порты 22, 80, 443 открыты."

# 3. Проверка запуска от root
# Проект требует, чтобы мы не работали под root постоянно
if [ "$EUID" -eq 0 ]; then
    echo "[!] ВНИМАНИЕ: Скрипт запущен от root. Рекомендуется запускать от пользователя с sudo."
fi

echo "[*] Hardening завершен успешно."
