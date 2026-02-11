# Задача для следующего чата (Opus)

## Контекст

Работаю над автоматизацией развёртки проекта 1С (спецификация: MinimKG_old/openspec/changes/optimize-project-setup/).

Создан скрипт `init-1c-project.ps1`, который автоматически:
- ✅ Создаёт структуру проекта (src/cf, src/cfe, openspec, .cursor/skills)
- ✅ Копирует навыки (1c-batch, 1c-feature-dev-enhanced, и др.)
- ✅ Находит 1С:Предприятие автоматически
- ✅ Создаёт OpenSpec структуру и README.md
- ✅ Инициализирует Git

## Проблема

**PowerShell не может корректно записать .1c-devbase.bat с кириллицей.**

При создании файла `.1c-devbase.bat` логин "Бухгалтер" превращается в "??????????????????", из-за чего выгрузка конфигурации не работает.

### Попробованные решения (все не работают):

1. `Out-File -Encoding ASCII` - искажает кириллицу
2. `Out-File -Encoding UTF8` - добавляет BOM, ломает bat
3. `[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)` - добавляет BOM
4. Создание через промежуточный bat-скрипт с `chcp 65001` - всё равно искажается

### Что работает:

Копирование готового файла из `MinimKG_old\.1c-devbase.bat` работает корректно (кириллица сохраняется).

## Задача

Исправить скрипт `init-1c-project.ps1`, чтобы он корректно создавал `.1c-devbase.bat` с кириллическим логином.

### Требования:

1. Файл должен быть в кодировке UTF-8 **без BOM**
2. Кириллица должна сохраняться корректно
3. Bat-файл должен работать (не ломаться от BOM)
4. Решение должно работать в PowerShell 5.1+

### Возможные подходы:

1. **Использовать .NET StreamWriter с UTF8 без BOM:**
   ```powershell
   $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
   $writer = New-Object System.IO.StreamWriter($path, $false, $utf8NoBom)
   $writer.Write($content)
   $writer.Close()
   ```

2. **Использовать Python/Node.js** (если установлены)

3. **Использовать certutil для конвертации**

4. **Создать временную C# утилиту**

## Файлы

- **Скрипт:** `C:\Users\YOUR_USERNAME\workspace\Home_Infrastructure\.cursor\skills\1c-project-init\scripts\init-1c-project.ps1`
- **Проблемное место:** Шаг 4 (Creating config) - строки 89-106
- **Тестовый проект:** `C:\Users\YOUR_USERNAME\workspace\MinimKG_test` (можно удалить и пересоздать)
- **Эталон:** `C:\Users\YOUR_USERNAME\workspace\MinimKG_old\.1c-devbase.bat` (рабочий пример)

## Тестирование

После исправления запустить:

```powershell
cd C:\Users\YOUR_USERNAME\workspace
if (Test-Path "MinimKG_test") { Remove-Item "MinimKG_test" -Recurse -Force }

C:\Users\YOUR_USERNAME\workspace\Home_Infrastructure\.cursor\skills\1c-project-init\scripts\init-1c-project.ps1 `
  -ProjectPath "C:\Users\YOUR_USERNAME\workspace\MinimKG_test" `
  -Server "localhost:1641" `
  -Database "Minim_kg" `
  -Username "Бухгалтер" `
  -ProjectName "MinimKG_test" `
  -OneCPath "C:\Program Files\1cv8\8.3.24.1808\bin\1cv8.exe"
```

**Ожидаемый результат:**
- Скрипт должен завершиться успешно (exit code 0)
- Файл `.1c-devbase.bat` должен содержать `set "ONEC_USER=Бухгалтер"` (не искажённое)
- Конфигурация должна выгрузиться в `src\cf\`
- Git коммиты должны быть созданы

## Загрузка контекста из RLM

```
Используй RLM для загрузки полного контекста:
rlm_enterprise_context(query="1c-project-init кириллица PowerShell .1c-devbase.bat")
```

Все решения, попытки и проблемы зафиксированы в RLM.

## Цель

Получить полностью рабочий скрипт `init-1c-project.ps1`, который создаёт проект 1С за < 5 минут без ошибок.

---

**Приоритет:** Высокий  
**Модель:** Opus 4.6 (требуется глубокое понимание кодировок)  
**Время:** ~30 минут
