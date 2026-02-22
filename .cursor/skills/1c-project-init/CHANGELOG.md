# Changelog - 1c-project-init

## 2026-02-10 - MCP Folders Support

### IMPORTANT: MCP Server Naming

**Correct naming** (as per actual deployment):
1. **`{project}-codemetadata`** — Semantic search (embeddings, AI-powered code search)
2. **`{project}-graph`** — Neo4j graph database (metadata structure and relationships)

**NOT** the other way around!

### Added

#### MCP Data Structure
- **mcp/base/report/** — для отчёта по конфигурации
- **mcp/base/src/** — junction на src/cf/
- **mcp/ext/report/** — для отчёта расширения
- **mcp/ext/src/** — junction на src/cfe/

#### Documentation
- **mcp/README.md** — инструкции по использованию MCP папок
- **docs/export-configuration-report.md** — детальное руководство по экспорту отчётов из 1С

#### Script Changes
- Автоматическое создание папок mcp/ при инициализации
- Создание junctions (вместо symlinks, не требуют прав администратора)
- Копирование export-configuration-report.md в docs/

#### .gitignore
- Исключение mcp/base/report/ и mcp/ext/report/
- Комментарий про junctions (отслеживаются Git)

#### README Updates
- Добавлена структура mcp/ в README.md
- Ссылка на docs/export-configuration-report.md

#### configs/mcp-setup.md Updates
- Раздел "Prepare Data for MCP"
- Инструкции по экспорту отчёта
- Объяснение зачем нужны report/ и src/

### Changed

- **Symlinks → Junctions**: Использование `cmd /c mklink /J` вместо `New-Item -ItemType SymbolicLink`
  - Причина: Junctions не требуют прав администратора
  - Работает на Windows без повышения привилегий

### Technical Details

#### Junction vs Symlink
- **Junction**: Directory-level link, no admin rights required
- **Symlink**: File/directory link, requires admin rights
- **Choice**: Junction для mcp/*/src/ (достаточно для MCP)

#### File Structure After Init
```
MyProject/
├── mcp/
│   ├── README.md
│   ├── base/
│   │   ├── report/          # Empty, user exports here
│   │   └── src/             # Junction → src/cf/
│   └── ext/
│       ├── report/          # Empty, user exports here
│       └── src/             # Junction → src/cfe/
├── docs/
│   └── export-configuration-report.md
└── configs/
    └── mcp-setup.md         # Updated with report export instructions
```

### Migration for Existing Projects

For projects initialized before this update:

```powershell
# 1. Create MCP folders
New-Item -ItemType Directory -Path "mcp\base\report" -Force
New-Item -ItemType Directory -Path "mcp\ext\report" -Force

# 2. Create junctions
cmd /c "mklink /J `"mcp\base\src`" `"src\cf`""
cmd /c "mklink /J `"mcp\ext\src`" `"src\cfe`""

# 3. Copy README
Copy-Item "C:\Users\Arman\workspace\Home_Infrastructure\.cursor\skills\1c-project-init\templates\mcp-README.md" "mcp\README.md"

# 4. Copy export guide
Copy-Item "C:\Users\Arman\workspace\Home_Infrastructure\.cursor\skills\1c-project-init\docs\export-configuration-report.md" "docs\"

# 5. Update .gitignore
Add-Content .gitignore @"

# MCP data (large, frequently updated)
mcp/base/report/
mcp/ext/report/

# Note: mcp/base/src and mcp/ext/src are junctions (tracked by git)
"@
```

### Why This Change?

**Problem**: MCP servers need 2 types of data:
1. Configuration reports (metadata descriptions)
2. Code files (BSL modules)

**Before**: Only src/cf/ and src/cfe/ existed (code only)

**After**: 
- mcp/base/report/ — for configuration reports
- mcp/base/src/ — junction to src/cf/ (code)
- Same for extensions

**Benefit**: 
- MCP servers can index both metadata and code
- Semantic search works better with metadata
- Clear separation of concerns

### References

- MCP Documentation: https://docs.onerpa.ru/mcp-servery-1c/servery/code-metadata-search/podgotovka-dannyh
- CloudEmbeddingsServer: Uses report/ and src/ folders
- CodeMetadataSearchServer: Same structure
