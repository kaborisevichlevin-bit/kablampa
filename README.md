# KABLampa

Личная сборка [Lampa](https://github.com/yumata/lampa) для телевизора через Media Station X.

Отличия от оригинала:
- `kablampa.js` — при первом запуске сам подключает набор расширений (TMDB Proxy, Showy Pro, коллекции, категории, Кинопоиск, рейтинги, интерфейс, трейлеры, пункт «Выход»). Удалённое вручную расширение повторно не добавляется.
- Название **KABLampa** в MSX и в заголовке.
- `install.sh` — установка и ежедневное автообновление на своём сервере.

## Установка на сервер
```
curl -fsSL https://raw.githubusercontent.com/kaborisevichlevin-bit/kablampa/main/install.sh | sudo bash
```
Сборка работает по HTTP (не HTTPS) — это нужно для Showy.

## Телевизор
Media Station X → Settings → Start Parameter → Setup → ввести адрес, который вывел скрипт (замок не ставить).

## Добавить своё расширение
Дописать строку в массив `PLUGINS` в `kablampa.js` и закоммитить — сервер подтянет изменения ночью.

## Обновление Lampa
На GitHub: кнопка **Sync fork** — затем сервер обновится автоматически.
