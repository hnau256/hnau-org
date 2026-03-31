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
2. **Проверяется внешняя папка сборки** (`build/upchain-app`):
   - Если папка пустая или не существует → клонируется https://github.com/hnau256/upchain-app
   - Если папка существует → выполняется `git pull` для обновления
3. **Собирается upchain-app** во внешней папке (`./gradlew :server:installDist`)
4. **Собирается Docker образ**, копируя уже собранное приложение
5. **Запускаются контейнеры** (Nginx, Upchain, Certbot)
6. **Автоматически получается SSL сертификат** от Let's Encrypt для upchain.hnau.org

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
│   └── Dockerfile             # Копирует собранное приложение
├── build/
│   └── upchain-app/          # Внешняя папка сборки (git clone + build)
└── data/
    └── upchain/              # Данные upchain-app (volume)
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
2. Обновит upchain-app во внешней папке (`git pull`)
3. Пересоберёт приложение
4. Пересоберёт и перезапустит Docker контейнеры

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

# Полная пересборка (обновление кода + билд)
./deploy.sh
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

## Преимущества внешней сборки

- **Быстрее**: Docker кэширует слои, а не пересобирает каждый раз
- **Проще отладка**: Можно проверить сборку отдельно от Docker
- **Гибкость**: Легко переключаться между версиями upchain-app
- **Чистота**: Логика git отделена от Docker