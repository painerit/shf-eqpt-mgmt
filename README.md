# Система автоматизации управления поверкой СВЧ-оборудования

Веб-приложение на Ruby on Rails для метрологической службы: реестр СВЧ-оборудования,
графики поверок, результаты измерений, интеграция с внешними системами и аудит действий.

## Стек

- Ruby 3.2.11
- Rails 7.0.10
- PostgreSQL 15
- Docker / Docker Compose
- Minitest, Capybara, WebMock
- Pundit, Kaminari, JWT, Faraday, Prawn

## Быстрый старт

```bash
docker compose up --build
docker compose exec web bin/rails db:prepare db:seed
```

Приложение: http://localhost:3000

Демонстрационные аккаунты (пароль `password123`):

| Роль | Email |
|---|---|
| Администратор | `admin@example.com` |
| Метролог | `metrologist@example.com` |
| Инженер | `engineer@example.com` |
| Заказчик | `customer@example.com` |

> Пароли и ключи из репозитория предназначены только для локальной демонстрации.

## Полезные команды

```bash
# Консоль Rails
docker compose exec web bin/rails console

# Миграции и seed
docker compose exec web bin/rails db:prepare
docker compose exec web bin/rails db:seed

# Тесты
docker compose run --rm -e RAILS_ENV=test web bin/rails db:test:prepare
docker compose run --rm -e RAILS_ENV=test web bin/rails test

# Проверка автозагрузки
docker compose exec web bin/rails zeitwerk:check
```

## Текущее состояние

Первая итерация: подготовлена схема данных, модели, демонстрационные данные и
базовые тесты. Пользовательский интерфейс, аутентификация, REST API и интеграции
будут добавлены следующими итерациями.

### Схема данных

В базе 13 предметных таблиц:

1. `roles` — роли пользователей;
2. `departments` — подразделения;
3. `users` — сотрудники и заказчики;
4. `equipment_types` — типы СВЧ-оборудования;
5. `manufacturers` — производители;
6. `normative_documents` — нормативные документы и методики;
7. `equipment` — реестр оборудования;
8. `verification_schedules` — графики поверок;
9. `verifications` — поверки;
10. `verification_results` — результаты измерений;
11. `audit_logs` — история действий;
12. `notifications` — уведомления о сроках поверки;
13. `document_counters` — счётчики номеров протоколов и свидетельств.

Счётчик документов обновляется в транзакции с блокировкой строки
(`SELECT ... FOR UPDATE`), что защищает от выдачи одинаковых номеров при
одновременной работе инженеров.

### Что уже реализовано

- 13 миграций с внешними ключами, уникальными и partial-индексами, check-constraint;
- модели с ассоциациями, валидациями, enum-статусами и scopes;
- расчёт даты следующей поверки;
- audit log и notifications на уровне моделей;
- идемпотентные seed-данные: 32 прибора, 30 поверок, 90 результатов измерений;
- 25 модельных тестов;
- Docker Compose с healthcheck PostgreSQL и автоматическим `db:prepare`;
- русская локаль и часовой пояс Москвы;
- фиксация зависимостей `json ~> 2.6` и `minitest ~> 5.20` для совместимости с Rails 7.0.

## Структура проекта

```
app/models/          доменные модели
db/migrate/          миграции
db/seeds.rb          демонстрационные данные
test/models/         модельные тесты
test/fixtures/       фикстуры
config/locales/ru.yml русские подписи
```

## Roadmap

- [x] Итерация 1. Схема БД, модели, seed, базовые тесты, Docker.
- [ ] Итерация 2. Аутентификация, роли, layout, dashboard.
- [ ] Итерация 3. Реестр оборудования: CRUD, поиск, фильтры.
- [ ] Итерация 4. Графики и поверки, транзакции и блокировки.
- [ ] Итерация 5. REST API с JWT.
- [ ] Итерация 6. Интеграция с внешним API.
- [ ] Итерация 7. Уведомления и аудит в интерфейсе.
- [ ] Итерация 8. CI, документация, деплой.