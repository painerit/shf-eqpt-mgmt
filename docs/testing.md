# Тестирование

## Запуск

```bash
docker compose run --rm -e RAILS_ENV=test web bin/rails db:test:prepare
docker compose run --rm -e RAILS_ENV=test web bin/rails test
```

Проверка автозагрузки:

```bash
docker compose run --rm web bin/rails zeitwerk:check
```

## Покрытые области

- модели, валидации, ассоциации и scopes;
- Pundit-политики и ограничения по ролям;
- query-объекты поиска, фильтров и сортировки;
- контроллеры веб-интерфейса и админ-раздела;
- REST API: JWT, доступы, фильтры, пагинация, ошибки;
- сервисы: генерация графиков, завершение поверки, публикация;
- транзакция завершения и откат изменений;
- генерация PDF-протокола;
- фоновые задания и дедупликация уведомлений;
- журнал аудита и фильтры.

## CI

`.github/workflows/ci.yml` запускает на каждый push и pull request:

1. PostgreSQL 15;
2. установку Ruby и gems с кешированием;
3. `bin/rails db:test:prepare`;
4. `bin/rails zeitwerk:check`;
5. `bin/rails test`.

## Текущий результат

```text
199 runs, 641 assertions, 0 failures, 0 errors
```