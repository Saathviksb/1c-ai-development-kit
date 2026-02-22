# 1C AI Development Kit v1.0.0

Первый публичный релиз комплексного набора инструментов для разработки на 1С с использованием AI.

## 🎉 Что включено

### 🤖 AI-Агенты (12 шт.)
- `onec-code-writer` — написание и модификация кода
- `onec-code-reviewer` — код-ревью с проверкой стандартов
- `onec-code-architect` — проектирование архитектуры
- `onec-code-explorer` — анализ кодовой базы
- `onec-code-simplifier` — упрощение и рефакторинг
- `onec-form-generator` — генерация управляемых форм
- `onec-query-optimizer` — оптимизация запросов
- `onec-test-generator` — генерация тестов (Vanessa, YaXUnit)
- `onec-metadata-helper` — навигация по метаданным
- `onec-admin` — администрирование 1С серверов
- `mcp-deploy` — управление MCP-серверами
- `dev-optimizer` — мониторинг и оптимизация разработки

### 📚 Навыки (15+ шт.)
- **Работа с конфигурацией:** `1c-batch`, `1c-project-init`
- **Генерация объектов:** `1c-forms`, `1c-mxl`, `1c-roles`
- **Интеграция с БСП:** `1c-bsp`
- **Разработка:** `1c-feature-dev-enhanced`, `1c-query-optimization`
- **Утилиты:** `auto-skill-bootstrap`

### 🔧 Правила (9 шт.)
- `1c-coding-standards.mdc` — стандарты кодирования для 1С
- `onec.mdc` — специфика платформы 1С
- `sdd-workflow.mdc` — Specification-Driven Development
- `model-selection.mdc` — выбор модели AI (экономия токенов)
- `context-management.mdc` — управление контекстом и агентами
- `bsl-lsp-integration.mdc` — интеграция с BSL Language Server
- `mcp-tools-usage.mdc` — работа с MCP-инструментами
- `skills-first.mdc` — приоритет использования навыков
- `no-roi-estimates.mdc` — без оценок времени и ROI

### 🌐 MCP-серверы (описание)
**Бесплатные:**
- `bsl-lsp-bridge` — LSP интеграция для BSL
- `rlm-toolkit` — память между чатами

**Платные** ([vibecoding1c.ru](https://vibecoding1c.ru/mcp_server)):
- `1c-help` — документация 1С
- `1c-ssl` — БСП (Библиотека Стандартных Подсистем)
- `1c-templates` — шаблоны кода
- `1c-syntax-checker` — проверка синтаксиса BSL
- `1c-code-checker` — проверка логики (1С:Напарник)
- `1c-forms` — схемы управляемых форм

**Важно:** Docker-контейнеры для развертывания на вашем сервере. Используете свои API-ключи, все данные остаются у вас.

### 📖 Документация
- README с примерами использования
- QUICK_START для быстрого старта
- Руководство по установке
- Гайд по созданию проектных MCP
- FAQ с 50+ вопросами
- CONTRIBUTING для контрибьюторов

## 🚀 Quick Start

```bash
# Клонируйте репозиторий
git clone https://github.com/Arman-Kudaibergenov/1c-ai-development-kit.git
cd 1c-ai-development-kit

# Скопируйте в ваш проект
cp -r .cursor/* /path/to/your-1c-project/.cursor/

# Перезапустите Cursor IDE
# Ctrl+Shift+P → "Reload Window"

# Готово! Попробуйте в чате:
# "Проверь код модуля CommonModule.ОбщегоНазначения"
```

См. [QUICK_START.md](QUICK_START.md) для деталей.

## 📚 Документация

- [Руководство по установке](docs/guides/installation.md)
- [Настройка MCP-серверов](docs/guides/project-mcp-setup.md)
- [FAQ](docs/FAQ.md)
- [Contributing](CONTRIBUTING.md)

## 🙏 Благодарности

Особая благодарность:

- **[Олег Филиппов](https://t.me/comol_foa)** ([vibecoding1c.ru](https://vibecoding1c.ru/)) за:
  - Пионерскую работу в области AI для 1С
  - Первые MCP-серверы для 1С ([8 серверов](https://vibecoding1c.ru/mcp_server))
  - Курсы по вайбкодингу и разработке AI-агентов
  - Активное сообщество [t.me/comol_it_does_matter](https://t.me/comol_it_does_matter)

- **[Dmitrii Labintsev](https://habr.com/ru/articles/986702/)** за:
  - Создание **RLM-toolkit** — системы иерархической памяти для AI
  - Решение проблемы сохранения контекста между чатами
  - Бесплатный open-source инструмент

- **Сообществу 1С-разработчиков** за открытость к новым технологиям

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE)

## 📞 Контакты

- 💬 Telegram: [@Jefest9988](https://t.me/Jefest9988)
- 📧 Email: arman.kudaibergenov.mail@gmail.com
- 🐙 GitHub: [github.com/Arman-Kudaibergenov/1c-ai-development-kit](https://github.com/Arman-Kudaibergenov/1c-ai-development-kit)

---

**Сделано с ❤️ для сообщества 1С разработчиков**
