# 1c-batch

Навык ([Agent Skill](https://agentskills.io)) для AI-агентов — автоматизация пакетных операций с платформой 1С:Предприятие 8.

Набор bat-скриптов для сборки обработок, управления конфигурацией и расширениями, запуска 1С — всё без ручного вмешательства.

## Что такое Agent Skills?

Открытый стандарт расширения AI-агентов (Claude Code, Cursor и др.). Навык загружается в контекст по требованию: агент видит только имя и описание (~100 токенов), а полные инструкции и скрипты подключает когда они нужны.

## Что умеет

| Операция | Что делает |
|---|---|
| Сборка обработки | XML → EPF/ERF |
| Разборка обработки | EPF/ERF → XML |
| Загрузка конфигурации | XML → база (полностью или отдельные файлы) |
| Выгрузка конфигурации | база → XML (полная или инкрементальная) |
| Загрузка расширения | XML → база |
| Выгрузка расширения | база → XML |
| Запуск предприятия | открыть базу в режиме предприятия |
| Запуск конфигуратора | открыть базу в конфигураторе |

## Установка

Навык уже установлен в `.cursor/skills/1c-batch/`.

## Настройка

Создайте в корне проекта файл `.1c-devbase.bat` по образцу `.cursor/skills/1c-batch/.1c-devbase.bat.example`:

```batchfile
set "ONEC_PATH=C:\Program Files\1cv8\8.3.24.1467\bin\1cv8.exe"

REM Серверная база (приоритет):
set "ONEC_SERVER=localhost"
set "ONEC_BASE=erp_dev"

REM Или файловая база:
REM set "ONEC_FILEBASE_PATH=D:\Bases\MyBase"

set "ONEC_USER=Администратор"
set "ONEC_PASSWORD="
```

**Важно:** Добавьте `.1c-devbase.bat` в `.gitignore` — файл содержит учётные данные.

## Использование

### Через AI-агента

Просто попросите агента выполнить операцию:

```
"Разбери обработку МояОбработка.epf в XML"
"Загрузи изменения в модуле ОбщегоНазначения"
"Выгрузи расширение МоёРасширение"
```

Агент автоматически использует навык 1c-batch.

### Вручную

Все скрипты запускаются из корня проекта:

```bat
REM Разборка обработки
.cursor\skills\1c-batch\scripts\dump-epf.bat src\epf\МояОбработка.xml D:\МояОбработка.epf

REM Сборка обработки
.cursor\skills\1c-batch\scripts\build-epf.bat src\epf\МояОбработка.xml build\МояОбработка.epf

REM Загрузка конфигурации (полная)
.cursor\skills\1c-batch\scripts\load-config.bat src\cf

REM Загрузка конфигурации (частичная)
.cursor\skills\1c-batch\scripts\load-config.bat src\cf "CommonModules/МойМодуль/Ext/Module.bsl"

REM Выгрузка конфигурации (полная)
.cursor\skills\1c-batch\scripts\dump-config.bat src\cf

REM Выгрузка конфигурации (инкрементальная)
.cursor\skills\1c-batch\scripts\dump-config.bat src\cf update

REM Загрузка расширения
.cursor\skills\1c-batch\scripts\load-extension.bat src\cfe\МоёРасширение МоёРасширение

REM Выгрузка расширения
.cursor\skills\1c-batch\scripts\dump-extension.bat src\cfe\МоёРасширение МоёРасширение

REM Запуск предприятия
.cursor\skills\1c-batch\scripts\run-enterprise.bat

REM Запуск предприятия с обработкой
.cursor\skills\1c-batch\scripts\run-enterprise.bat build\МояОбработка.epf

REM Запуск конфигуратора
.cursor\skills\1c-batch\scripts\run-designer.bat
```

## Примеры сценариев

### Исправить ошибку в обработке

1. Разобрать обработку в XML
2. Отредактировать BSL-файлы в `src/epf/МояОбработка/`
3. Собрать обработку из XML
4. Проверить в предприятии

```bat
.cursor\skills\1c-batch\scripts\dump-epf.bat src\epf\МояОбработка.xml D:\МояОбработка.epf
REM Редактируем файлы в src\epf\МояОбработка\
.cursor\skills\1c-batch\scripts\build-epf.bat src\epf\МояОбработка.xml build\МояОбработка.epf
.cursor\skills\1c-batch\scripts\run-enterprise.bat build\МояОбработка.epf
```

### Загрузка изменённого модуля

После редактирования BSL-файла загрузить его в базу:

```bat
.cursor\skills\1c-batch\scripts\load-config.bat src\cf "CommonModules/МойМодуль/Ext/Module.bsl"
```

### Обновить расширение

1. Выгрузить расширение в XML
2. Внести изменения
3. Загрузить расширение обратно

```bat
.cursor\skills\1c-batch\scripts\dump-extension.bat src\cfe\МоёРасширение МоёРасширение
REM Редактируем файлы в src\cfe\МоёРасширение\
.cursor\skills\1c-batch\scripts\load-extension.bat src\cfe\МоёРасширение МоёРасширение
```

## Интеграция с onec-quick-deploy

Навык 1c-batch отлично дополняет систему `onec-quick-deploy`:

- `onec-quick-deploy` — первоначальное развертывание проекта
- `1c-batch` — ежедневная работа с конфигурацией и обработками

Типичный workflow:

1. Развернуть проект: `onec-quick-deploy.ps1`
2. Работать с кодом: `1c-batch` скрипты
3. Коммитить изменения в Git
4. При необходимости пересоздать проект: `onec-quick-deploy.ps1`

## Автор оригинального проекта

Владимир Харин — [Telegram](https://t.me/vladimir_kharin)

Оригинальный репозиторий: https://github.com/vladimir-kharin/1c-batch

## Адаптация

Адаптировано для Home_Infrastructure проекта:
- Путь к навыку: `.cursor/skills/1c-batch/`
- Интеграция с `onec-quick-deploy`
- Примеры для локальной инфраструктуры

## Лицензия

MIT License (оригинальный проект)
