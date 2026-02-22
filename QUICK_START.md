# Quick Start

Быстрый старт для нетерпеливых 😊

## За 5 минут

### 1. Клонируйте репозиторий

```bash
git clone https://github.com/Arman-Kudaibergenov/1c-ai-development-kit.git
cd 1c-ai-development-kit
```

### 2. Скопируйте в ваш проект

```bash
# Windows PowerShell
Copy-Item .cursor\* -Destination "C:\path\to\your-1c-project\.cursor\" -Recurse -Force

# Linux/macOS
cp -r .cursor/* /path/to/your-1c-project/.cursor/
```

### 3. Перезапустите Cursor

Ctrl+Shift+P → "Reload Window"

### 4. Готово!

Теперь в чате Cursor попробуйте:

```
Проверь код модуля CommonModule.ОбщегоНазначения
```

AI автоматически использует агента `onec-code-reviewer` для проверки.

## Настройка MCP (опционально)

### Бесплатные MCP-серверы

#### Песочница для AI-агентов (рекомендуется)

**Автор:** [Vladimir Akimov (SteelMorgan)](https://github.com/SteelMorgan)

Перед началом работы рекомендуем развернуть [1c-ai-sandbox-client-server](https://github.com/SteelMorgan/1c-ai-sandbox-client-server) — изолированную среду, в которой AI-агент не имеет доступа к вашей хостовой системе. Защищает от случайной потери данных.

#### BSL LSP Bridge (анализ кода)

**Автор:** [Vladimir Akimov (SteelMorgan)](https://github.com/SteelMorgan)

```bash
# Установка
git clone https://github.com/SteelMorgan/mcp-bsl-lsp-bridge.git
cd mcp-bsl-lsp-bridge
npm install
node server.js
```

Добавьте в `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "bsl-lsp-bridge": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "http://localhost:5007/mcp",
        "-H", "Content-Type: application/json",
        "-d", "@-"
      ]
    }
  }
}
```

#### RLM Toolkit (память между чатами)

**Автор:** [Dmitrii Labintsev](https://habr.com/ru/articles/986702/)

```bash
# Установка
git clone https://github.com/dmitrii-labintsev/rlm-toolkit.git
cd rlm-toolkit
pip install -r requirements.txt
python server.py
```

Добавьте в `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "rlm-toolkit": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "http://localhost:8200/mcp",
        "-H", "Content-Type: application/json",
        "-d", "@-"
      ]
    }
  }
}
```

## Что попробовать?

### Код-ревью

```
Проверь модуль src/cf/CommonModules/МойМодуль/Ext/Module.bsl
```

### Создание формы

```
Создай обработку "ЗагрузкаДанных" с формой для выбора файла
```

### Оптимизация запроса

```
Оптимизируй этот запрос:
[вставьте код запроса]
```

### Генерация тестов

```
Создай тесты для функции РассчитатьСумму в модуле ОбщегоНазначения
```

## Следующие шаги

- [Полное руководство по установке](docs/guides/installation.md)
- [Работа с агентами](docs/guides/agents.md)
- [Использование навыков](docs/guides/skills.md)
- [Настройка проектных MCP](docs/guides/project-mcp-setup.md)
- [FAQ](docs/FAQ.md)

## Проблемы?

- Агенты не работают? Перезапустите Cursor (Ctrl+Shift+P → "Reload Window")
- MCP не отвечает? Проверьте, что сервер запущен: `curl http://localhost:PORT/health`
- Другие проблемы? См. [Troubleshooting](docs/troubleshooting/README.md)

## Помощь

- 💬 Telegram: [@Arman-Kudaibergenov](https://t.me/Arman-Kudaibergenov)
- 📧 Email: arman.kudaibergenov.mail@gmail.com
- 🐛 Issues: https://github.com/Arman-Kudaibergenov/1c-ai-development-kit/issues
- 🌐 Сообщество: [t.me/comol_it_does_matter](https://t.me/comol_it_does_matter) (вайбкодинг для 1С)
