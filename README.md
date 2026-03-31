# HNAU Self-Deploying Server

Автоматически разворачивающийся сервер для hnau.org

## Быстрый старт

На сервере hnau.org:

```bash
# Клонировать репозиторий
sudo mkdir -p /opt
sudo git clone https://github.com/hnau256/hnau-org.git /opt/hnau-org

# Перейти в директорию
cd /opt/hnau-org

# Запустить деплой (всё произойдёт автоматически)
sudo ./deploy.sh
```

## Что происходит автоматически

При запуске `deploy.sh`:

1. **Обновляется текущий репозиторий** (hnau-org)
2. **Пересобирается и запускается контейнер upchain** (свежий код из https://github.com/hnau256/upchain-app)
3. **Автоматически получается SSL сертификат** от Let's Encrypt для upchain.hnau.org
4. **Nginx автоматически переключается** с HTTP на HTTPS когда сертификат получен
5. **Создаются необходимые директории** для данных

## Структура

```
/opt/hnau-org/
├── docker-compose.yml         # Конфигурация сервисов
├── deploy.sh                  # Скрипт деплоя (одна команда для всего)
├── nginx/
│   ├── entrypoint.sh          # Entrypoint для nginx (выбор HTTP/HTTPS)
│   ├── nginx-http.conf        # Конфигурация без SSL
│   └── nginx-https.conf       # Конфигурация с SSL
├── upchain/
│   └── Dockerfile             # Сборка upchain-app
└── data/
    └── upchain/               # Данные upchain-app (volume)
```

## Доступ

После деплоя:

- **http://upchain.hnau.org** → автоматический редирект на HTTPS
- **https://upchain.hnau.org** → Upchain приложение (с SSL)

## Обновление

Просто запустить:

```bash
cd /opt/hnau-org
sudo ./deploy.sh
```

Это:
1. Обновит hnau-org репозиторий
2. Пересоберёт контейнер upchain со свежим кодом из https://github.com/hnau256/upchain-app
3. Перезапустит все сервисы

## Логи

```bash
cd /opt/hnau-org

# Логи всех сервисов
docker-compose logs -f

# Логи конкретного сервиса
docker-compose logs -f upchain
docker-compose logs -f nginx
docker-compose logs -f certbot-init
```

## Команды управления

```bash
cd /opt/hnau-org

# Остановить все сервисы
docker-compose down

# Перезапустить только upchain
docker-compose restart upchain

# Перезапустить только nginx
docker-compose restart nginx

# Проверить статус
docker-compose ps

# Пересобрать и запустить (обновление)
docker-compose up --build -d
```

## Обновление SSL сертификата

Сертификаты обновляются автоматически (каждые 12 часов проверка). При необходимости обновить вручную:

```bash
cd /opt/hnau-org
docker-compose run --rm certbot renew
docker-compose restart nginx
```

## Требования

- Docker и Docker Compose установлены
- Порты 80 и 443 открыты
- DNS запись `upchain.hnau.org` указывает на сервер
- Домен upchain.hnau.org доступен из интернета (для Let's Encrypt)