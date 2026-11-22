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

Пятая итерация: добавлен защищённый REST API `/api/v1` с JWT-аутентификацией,
фильтрами, пагинацией и сериализацией оборудования, графиков и поверок.
Интеграция с внешним измерительным API будет добавлена следующей итерацией.

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
- вход/выход и регистрация заказчика на bcrypt;
- ролевая авторизация Pundit: администратор, метролог, инженер, заказчик;
- общий layout с сайдбаром, топбаром и flash-сообщениями;
- dashboard со сводкой по срокам поверки и уведомлениям;
- управление пользователями для администратора;
- реестр оборудования с поиском по номеру и модели;
- фильтры по типу, производителю, подразделению, статусу и сроку поверки;
- карточка прибора с историей поверок, графиком и аудитом изменений;
- создание и редактирование оборудования с проверкой ролей;
- графики поверок: список, фильтры, создание, редактирование и согласование;
- автоматическое формирование графика на год по подразделению;
- проведение поверки из графика: черновик, результаты измерений, завершение и отмена;
- завершение поверки в транзакции `READ COMMITTED` с блокировкой строки;
- генерация номеров протокола и свидетельства через счётчик с `FOR UPDATE`;
- печатная HTML-форма протокола и PDF с поддержкой кириллицы;
- REST API `/api/v1` с JWT-аутентификацией;
- API оборудования, графиков и поверок с фильтрами и пагинацией;
- сериализаторы API и единый формат ошибок `401/403/404/422`;
- health endpoint `/up`;
- 160 тестов: модели, контроллеры, API, запросы, сервисы, доступы, политики;
- Docker Compose с healthcheck PostgreSQL и автоматическим `db:prepare`;
- русская локаль и часовой пояс Москвы;
- фиксация зависимостей `json ~> 2.6` и `minitest ~> 5.20` для совместимости с Rails 7.0.

## Доступ к интерфейсу

После запуска откройте http://localhost:3000 — приложение перенаправит на страницу входа.

Демо-аккаунты (пароль `password123`):

| Роль | Email |
|---|---|
| Администратор | `admin@example.com` |
| Метролог | `metrologist@example.com` |
| Инженер | `engineer@example.com` |
| Заказчик | `customer@example.com` |

## REST API

Базовый префикс: `/api/v1`. Все endpoints, кроме входа, требуют заголовок:

```http
Authorization: Bearer <token>
```

Получить токен:

```bash
curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password123"}'
```

Пример ответа:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_at": "2026-11-19T18:12:08+03:00",
  "user": {
    "id": 1,
    "email": "admin@example.com",
    "full_name": "Администратор Системы",
    "role": "Администратор",
    "department": "Метрологическая служба"
  }
}
```

Доступные endpoints:

| Метод | Endpoint | Назначение |
|---|---|---|
| POST | `/api/v1/auth/login` | Получение JWT |
| GET | `/api/v1/equipment` | Реестр оборудования |
| GET | `/api/v1/equipment/:id` | Карточка оборудования и последние поверки |
| GET | `/api/v1/equipment/:id/verifications` | История поверок прибора |
| GET | `/api/v1/verification_schedules` | Графики поверок |
| GET | `/api/v1/verifications` | Список поверок |
| GET | `/api/v1/verifications/:id` | Поверка с результатами измерений |

Поддерживаются фильтры:

- оборудование: `q`, `equipment_type_id`, `manufacturer_id`, `department_id`, `status`, `due`;
- графики: `q`, `department_id`, `period_year`, `status`;
- поверки: `q`, `department_id`, `status`, `date_from`, `date_to`;
- пагинация: `page`, `per_page` (по умолчанию 20, максимум 100).

Пример:

```bash
TOKEN="<token из ответа login>"

curl -s "http://localhost:3000/api/v1/equipment?due=overdue&per_page=10" \
  -H "Authorization: Bearer $TOKEN"
```

Формат списка:

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 32,
    "total_pages": 2
  }
}
```

Формат ошибки:

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Требуется авторизация"
  }
}
```

JWT подписывается секретом из `JWT_SECRET`, а при его отсутствии — `Rails secret_key_base`.
Для production рекомендуется задать отдельный `JWT_SECRET`.

## Структура проекта

```
app/controllers/      контроллеры, API и админ-раздел
app/models/           доменные модели
app/policies/         Pundit-политики доступа
app/queries/          query-объекты поиска и фильтрации
app/serializers/      JSON-сериализаторы REST API
app/services/         транзакции, JWT, генерация графиков и PDF-протоколов
app/views/            ERB-шаблоны и layout
db/migrate/           миграции
db/seeds.rb           демонстрационные данные
test/                 модельные, контроллерные и policy-тесты
test/fixtures/        фикстуры
config/locales/ru.yml русские подписи
```

## Roadmap

- [x] Итерация 1. Схема БД, модели, seed, базовые тесты, Docker.
- [x] Итерация 2. Аутентификация, роли, layout, dashboard.
- [x] Итерация 3. Реестр оборудования: CRUD, поиск, фильтры.
- [x] Итерация 4. Графики и поверки, транзакции и блокировки.
- [x] Итерация 5. REST API с JWT.
- [ ] Итерация 6. Интеграция с внешним API.
- [ ] Итерация 7. Уведомления и аудит в интерфейсе.
- [ ] Итерация 8. CI, документация, деплой.