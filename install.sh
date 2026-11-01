#!/usr/bin/env bash
# KABLampa — установка/обновление на сервере (Ubuntu/Debian).
# Запуск:  curl -fsSL https://raw.githubusercontent.com/kaborisevichlevin-bit/kablampa/main/install.sh | sudo bash
set -euo pipefail

REPO="https://github.com/kaborisevichlevin-bit/kablampa.git"
DIR="/opt/kablampa"
NAME="kablampa"

echo "== KABLampa: установка =="

# 1. Docker и git
if ! command -v docker >/dev/null 2>&1; then
  echo "-> Ставлю Docker"
  curl -fsSL https://get.docker.com | sh
fi
command -v git >/dev/null 2>&1 || { apt-get update -y && apt-get install -y git; }

# 2. Порт: 80, если свободен, иначе 8080 (чтобы не мешать сайту на этом сервере)
if [ -z "${PORT:-}" ]; then
  if docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
    PORT=$(docker port "$NAME" 80/tcp | head -n1 | awk -F: '{print $NF}')
  elif ss -ltn '( sport = :80 )' | grep -q LISTEN; then
    PORT=8080
  else
    PORT=80
  fi
fi

# 3. Внешний IP
IP="${IP:-$(curl -fsS4 https://ifconfig.me || curl -fsS4 https://api.ipify.org)}"
if [ "$PORT" = "80" ]; then DOMAIN="$IP"; else DOMAIN="$IP:$PORT"; fi

# 4. Код
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" fetch --depth 1 origin main && git -C "$DIR" reset --hard origin/main
else
  git clone --depth 1 "$REPO" "$DIR"
fi

# 5. Сборка и запуск
docker build --build-arg domain="$DOMAIN" -t "$NAME" "$DIR"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --restart unless-stopped -p "$PORT:80" "$NAME"

# 6. Открыть порт в ufw, если он включён
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  ufw allow "$PORT/tcp" >/dev/null
fi

# 7. Автообновление раз в сутки в 05:00
CRON="0 5 * * * curl -fsSL https://raw.githubusercontent.com/kaborisevichlevin-bit/kablampa/main/install.sh | PORT=$PORT IP=$IP bash >/var/log/kablampa.log 2>&1"
if command -v crontab >/dev/null 2>&1; then
  { crontab -l 2>/dev/null | grep -v 'kablampa/main/install.sh' || true; echo "$CRON"; } | crontab - || echo "!! не удалось настроить автообновление"
fi

echo
echo "================================================"
echo " Готово! KABLampa работает: http://$DOMAIN"
echo " В Media Station X: Settings -> Start Parameter -> Setup"
echo " Введите (БЕЗ замка):  $DOMAIN"
echo "================================================"
