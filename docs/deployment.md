# Развёртывание

## Локальный запуск

```bash
docker compose up --build -d
docker compose exec web bin/rails db:prepare db:seed
```

Приложение: http://localhost:3000

## Production через Docker Compose

1. Создайте production-окружение:

```bash
cp .env.production.example .env.production
```

2. Заполните `.env.production`:

- `POSTGRES_PASSWORD` — пароль PostgreSQL;
- `RAILS_MASTER_KEY` — содержимое `config/master.key`;
- `SECRET_KEY_BASE` — случайная строка (`openssl rand -hex 64`);
- `JWT_SECRET` — отдельный секрет для API;
- `ADMIN_PASSWORD` — пароль первого администратора;
- `APP_HOST` — домен или IP;
- `REGISTRY_API_*` — параметры внешнего реестра.

3. Запустите:

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up --build -d
```

При старте контейнер:

- создаёт БД, если её нет;
- применяет миграции;
- создаёт справочники и администратора (`app:bootstrap`);
- собирает assets;
- запускает Puma.

Демонстрационные данные в production не загружаются.

## Проверка

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml ps
curl -f http://localhost:3000/up
```

Ожидаемый ответ:

```json
{"status":"ok","database":"ok"}
```

## HTTPS и reverse proxy

Рекомендуется поставить перед контейнером Caddy или Nginx:

- проксировать `http://127.0.0.1:3000`;
- выпустить TLS-сертификат;
- установить `FORCE_SSL=true`;
- указать `APP_HOST` реальным доменом.

## Резервное копирование

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml \
  exec -T db pg_dump -U postgres sw_verification_production > backup.sql
```

Восстановление:

```bash
cat backup.sql | docker compose --env-file .env.production -f docker-compose.prod.yml \
  exec -T db psql -U postgres sw_verification_production
```

## Хостинг

Для приложения нужны Ruby 3.2, PostgreSQL 15 и возможность запускать контейнеры.
Надёжный вариант — VPS с Docker (например, Beget VPS). Shared-хостинг без Docker
и PostgreSQL может не поддерживать Rails 7 и фоновые задания.

## Ограничения демо-контура

- Active Job в production по умолчанию использует `:async`; задания живут в процессе
  Puma. Для промышленной эксплуатации подключите Solid Queue, GoodJob или Sidekiq.
- PDF и уведомления не отправляются по email; уведомления отображаются в интерфейсе.
- Для повторной синхронизации с внешним реестром используйте кнопку в карточке поверки.