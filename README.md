# 1C AI Development Kit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-supported-blue.svg)](https://claude.ai/code)
[![Cursor IDE](https://img.shields.io/badge/Cursor_IDE-supported-purple.svg)](https://cursor.sh/)

> Комплект инструментов для AI-ассистированной разработки на 1С:Предприятие 8.3.
> Поддерживает **Claude Code** и **Cursor IDE**.

---

## Что это?

**1C AI Development Kit** — готовая экосистема для разработки на 1С с помощью AI. Включает агентов, навыки (skills), правила, шаблоны конфигов и документацию по форматам 1С.

Проект развился из нескольких решений сообщества (см. [Благодарности](#благодарности)) и объединяет их в единый рабочий комплект с поддержкой Claude Code.

---

## Что внутри

### Claude Code Skills

71 skill для автоматизации полного цикла разработки 1С. Вызываются как `/skill-name` в диалоге с Claude:

| Группа | Skills |
|--------|--------|
| Объекты метаданных | `meta-compile`, `meta-edit`, `meta-info`, `meta-remove`, `meta-validate` |
| Формы | `form-compile`, `form-edit`, `form-add`, `form-info`, `form-validate`, `form-patterns` |
| Обработки (EPF) | `epf-init`, `epf-build`, `epf-dump`, `epf-validate`, `epf-bsp-init`, `epf-bsp-add-command` |
| Отчёты (ERF) | `erf-init`, `erf-build`, `erf-dump`, `erf-validate` |
| СКД | `skd-compile`, `skd-edit`, `skd-info`, `skd-validate` |
| Макеты (MXL) | `mxl-compile`, `mxl-decompile`, `mxl-info`, `mxl-validate` |
| Роли | `role-compile`, `role-info`, `role-validate` |
| Подсистемы | `subsystem-compile`, `subsystem-edit`, `subsystem-info`, `subsystem-validate` |
| Конфигурация | `cf-init`, `cf-edit`, `cf-info`, `cf-validate` |
| Расширения (CFE) | `cfe-init`, `cfe-borrow`, `cfe-patch-method`, `cfe-validate`, `cfe-diff` |
| База данных | `db-create`, `db-list`, `db-run`, `db-update`, `db-dump-cf`, `db-load-cf`, `db-dump-xml`, `db-load-xml`, `db-load-git` |
| Workflow | `1c-feature-dev`, `1c-help-mcp`, `1c-query-opt`, `1c-project-init`, `bsp-patterns` |
| OpenSpec | `openspec-proposal`, `openspec-apply`, `openspec-archive` |

### Cursor IDE

- **12 специализированных агентов** — ревью кода, генерация форм, оптимизация запросов, проектирование архитектуры и др.
- **9 правил** — стандарты BSL, SDD workflow, выбор модели, использование MCP
- **13 skill-групп** — навыки для Cursor

### Документация — 29 спецификаций

XML-форматы объектов 1С, JSON DSL для компиляции без знания XML, паттерны форм, гайды по работе с objects.

### Шаблоны

- `templates/mcp.json` — готовый конфиг MCP-серверов для нового проекта

---

## Быстрый старт

Смотри [QUICK_START.md](QUICK_START.md) — там пошаговые инструкции для Claude Code и Cursor IDE.

---

## MCP-серверы

Для полной функциональности рекомендуются MCP-серверы от [vibecoding1c.ru](https://vibecoding1c.ru/mcp_server):

| Сервер | Назначение |
|--------|-----------|
| `1c-help` | Документация платформы 1С |
| `1c-ssl` | Паттерны БСП (Standard Subsystems Library) |
| `1c-templates` | Шаблоны кода 1С |
| `1c-syntax-checker` | Проверка синтаксиса BSL |
| `1c-code-checker` | Проверка логики через 1С:Напарник |
| `1c-forms` | Схемы управляемых форм |
| `rlm-toolkit` | Персистентная память между сессиями (от [@Dmitrii_Labintsev](https://habr.com/ru/articles/986702/)) |
| `edt-mcp` | Интеграция с 1C:EDT (от [@DitriXNew](https://github.com/DitriXNew/EDT-MCP)) |

Настройка MCP: [docs/guides/project-mcp-setup.md](docs/guides/project-mcp-setup.md)

---

## Требования

- 1С:Предприятие 8.3.24+
- PowerShell 5.1+
- Git
- Claude Code или Cursor IDE

---

## Благодарности

Проект построен на работе сообщества. Полные благодарности: [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md)

| Проект | Автор | Вклад |
|--------|-------|-------|
| [cc-1c-skills](https://github.com/Nikolay-Shirokov/cc-1c-skills) | [@Nikolay-Shirokov](https://github.com/Nikolay-Shirokov) | Основа архитектуры Claude Code skills — 44+ skills, XML DSL, спецификации |
| [cursor_rules_1c](https://github.com/comol/cursor_rules_1c) | [@comol](https://github.com/comol) | Skills для Cursor, JSON DSL, агенты, правила |
| [1c-batch](https://github.com/vladimir-kharin/1c-batch) | [@vladimir-kharin](https://github.com/vladimir-kharin) | Bat-скрипты для пакетных операций с платформой 1С |
| [mcp-bsl-lsp-bridge](https://github.com/SteelMorgan/mcp-bsl-lsp-bridge) | [@SteelMorgan](https://github.com/SteelMorgan) | MCP-сервер для BSL Language Server |
| [1c-ai-sandbox](https://github.com/SteelMorgan/1c-ai-sandbox-client-server) | [@SteelMorgan](https://github.com/SteelMorgan) | Концепция безопасной sandbox-среды для AI-агентов |
| [EDT-MCP](https://github.com/DitriXNew/EDT-MCP) | [@DitriXNew](https://github.com/DitriXNew) | MCP-сервер для интеграции с 1C:EDT |
| [vibecoding1c.ru](https://vibecoding1c.ru) | [@comol_foa](https://t.me/comol_foa) | MCP-серверы, курсы, сообщество AI-разработки на 1С |

---

## Контакты

- 💬 Telegram: [@Arman-Kudaibergenov](https://t.me/Arman-Kudaibergenov)
- 📧 Email: arman.kudaibergenov.mail@gmail.com
- 🐙 GitHub: [github.com/Arman-Kudaibergenov/1c-ai-development-kit](https://github.com/Arman-Kudaibergenov/1c-ai-development-kit)

---

**Сделано с ❤️ для сообщества 1С-разработчиков**
