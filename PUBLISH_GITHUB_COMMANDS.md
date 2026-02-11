# Команды для публикации на GitHub

## 1. Перейдите в папку проекта

```powershell
cd C:\Users\Arman\workspace\1c-ai-development-kit
```

## 2. Проверьте текущее состояние

```powershell
git status
git log --oneline -n 5
```

## 3. Добавьте GitHub remote

```powershell
git remote add github https://github.com/Jefest9988/1c-ai-development-kit.git
```

## 4. Проверьте remotes

```powershell
git remote -v
```

Должно показать:
```
github  https://github.com/Jefest9988/1c-ai-development-kit.git (fetch)
github  https://github.com/Jefest9988/1c-ai-development-kit.git (push)
```

## 5. Push на GitHub

```powershell
# Push main ветки
git push -u github main
```

Если попросит авторизацию:
- Username: `Jefest9988`
- Password: используйте **Personal Access Token** (не обычный пароль)

### Как создать Personal Access Token:

1. Зайдите на https://github.com/settings/tokens
2. "Generate new token" → "Generate new token (classic)"
3. Note: `1c-ai-development-kit`
4. Expiration: `90 days` (или больше)
5. Scopes: выберите `repo` (полный доступ к репозиториям)
6. "Generate token"
7. **Скопируйте токен** (он больше не покажется!)
8. Используйте его вместо пароля

## 6. Создайте первый Release

```powershell
# Создайте тег
git tag -a v1.0.0 -m "Initial public release"

# Push тега
git push github v1.0.0
```

## 7. Обновите ссылки в документации

После публикации замените `yourusername` на `Jefest9988` в файлах:
- README.md
- CONTRIBUTING.md
- QUICK_START.md
- docs/FAQ.md
- ACKNOWLEDGMENTS.md

```powershell
# Автоматическая замена (PowerShell)
$files = @(
    "README.md",
    "CONTRIBUTING.md", 
    "QUICK_START.md",
    "docs/FAQ.md",
    "ACKNOWLEDGMENTS.md"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    $content = $content -replace "yourusername", "Jefest9988"
    $content = $content -replace "github.com/yourusername", "github.com/Jefest9988"
    Set-Content $file -Value $content -NoNewline
}

# Коммит изменений
git add .
git commit -m "docs: update GitHub username in all links"
git push github main
```

## 8. Настройте GitHub репозиторий

На странице https://github.com/Jefest9988/1c-ai-development-kit:

### About (правая колонка)
- Description: `Comprehensive AI-powered development toolkit for 1C:Enterprise platform`
- Website: (если есть)
- Topics: `1c`, `cursor`, `ai`, `development-kit`, `bsl`, `vibecoding`, `mcp-servers`, `ai-agents`

### Settings → General
- Features:
  - ✅ Issues
  - ✅ Discussions (опционально)
  - ✅ Wiki (опционально)

### Create Release (на главной странице)
1. Нажмите "Create a new release"
2. Tag: `v1.0.0`
3. Title: `v1.0.0 - Initial Public Release`
4. Description:
```markdown
# 1C AI Development Kit v1.0.0

Первый публичный релиз комплексного набора инструментов для разработки на 1С с использованием AI.

## 🎉 Что включено

- 🤖 **12 AI-агентов** для разных задач (код-ревью, генерация форм, оптимизация запросов)
- 📚 **15+ навыков** для автоматизации рутинных операций
- 🔧 **9 правил** для контроля качества и стандартов кодирования
- 🌐 **8 MCP-серверов** (2 бесплатных, 6 платных)
- 📖 **Полная документация** с примерами и гайдами

## 🚀 Quick Start

```bash
git clone https://github.com/Jefest9988/1c-ai-development-kit.git
cd 1c-ai-development-kit
cp -r .cursor/* /path/to/your-1c-project/.cursor/
```

См. [QUICK_START.md](QUICK_START.md) для деталей.

## 📚 Документация

- [Руководство по установке](docs/guides/installation.md)
- [Настройка MCP-серверов](docs/guides/project-mcp-setup.md)
- [FAQ](docs/FAQ.md)

## 🙏 Благодарности

Особая благодарность:
- [Олег Филиппов](https://vibecoding1c.ru/) за MCP-серверы и вайбкодинг
- [Dmitrii Labintsev](https://habr.com/ru/articles/986702/) за RLM-toolkit
- Сообществу 1С-разработчиков

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE)
```

5. Нажмите "Publish release"

## 9. Добавьте бейджи в README

Добавьте в начало README.md (после заголовка):

```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/Jefest9988/1c-ai-development-kit.svg)](https://github.com/Jefest9988/1c-ai-development-kit/releases)
[![GitHub stars](https://img.shields.io/github/stars/Jefest9988/1c-ai-development-kit.svg)](https://github.com/Jefest9988/1c-ai-development-kit/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/Jefest9988/1c-ai-development-kit.svg)](https://github.com/Jefest9988/1c-ai-development-kit/issues)
```

Коммит:
```powershell
git add README.md
git commit -m "docs: add badges to README"
git push github main
```

## 10. Анонсируйте в сообществе

После публикации напишите в:
- [t.me/comol_it_does_matter](https://t.me/comol_it_does_matter) (сообщество вайбкодинга)
- Habr.com (статья)
- Infostart.ru (форум)

Шаблон сообщения:
```
🎉 Опубликовал 1C AI Development Kit — комплексный набор инструментов для разработки на 1С с AI

Включает:
- 12 AI-агентов
- 15+ навыков
- 9 правил
- Документация и примеры

GitHub: https://github.com/Jefest9988/1c-ai-development-kit

Благодарность @comol_foa за MCP-серверы и вдохновение! 🙏
```

---

## ✅ Чеклист

- [ ] Очистил старые репозитории на GitHub (опционально)
- [ ] Создал новый репозиторий `1c-ai-development-kit`
- [ ] Добавил remote `github`
- [ ] Push на GitHub (`git push -u github main`)
- [ ] Создал Personal Access Token (если нужен)
- [ ] Push тега v1.0.0
- [ ] Обновил ссылки (yourusername → Jefest9988)
- [ ] Настроил About и Topics
- [ ] Создал Release v1.0.0
- [ ] Добавил бейджи в README
- [ ] Анонсировал в сообществе

---

**Готово! Проект опубликован!** 🚀
