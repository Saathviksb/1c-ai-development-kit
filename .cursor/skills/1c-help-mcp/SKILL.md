# 1C Help MCP — Platform Documentation Search

**MCP Server:** 1c-help (comol/1c_help_mcp:latest)
**Endpoint:** http://YOUR_SERVER:8003/mcp
**Status:** ⏳ Not deployed (awaiting large download)
**Purpose:** Search 1C:Enterprise 8.3 platform documentation

---

## Overview

This MCP server provides semantic search across 1C platform documentation (~16.8GB). It indexes official 1C documentation and provides fast lookup for methods, functions, syntax, and platform features.

**Key Features:**
- Semantic search via ChromaDB + embedding model
- Covers all 1C:Enterprise 8.3 platform documentation
- Russian language support
- Fast response (<1s typical)

**Use Cases:**
- Finding method signatures and parameters
- Understanding platform API
- Learning syntax and language features
- Discovering built-in functions

---

## Tools

### search_1c_docs (user-1c-help-docsearch)

**Purpose:** Search 1C platform documentation by keyword or method name

**When to use:**
- User asks "Как использовать [метод]?"
- Need to find platform method/function
- Looking for syntax reference
- Want to understand platform API
- Need examples of platform features

**When NOT to use:**
- Looking for БСП (SSL) functions → use `search_bsp_functions` instead
- Need code templates → use `search_1c_templates` instead
- Searching project-specific code → use project MCP tools
- Need business logic validation → use `check_1c_logic` instead

**Parameters:**

```yaml
query (string, required):
 - Method name in Russian (e.g., "СтрРазделить")
 - Description of functionality (e.g., "разделить строку")
 - Platform feature (e.g., "работа с файлами")
 - Can be partial match (e.g., "Стр" finds СтрДлина, СтрРазделить, etc.)
```

**Returns:**

```yaml
Structure:
 - Top N search results (typically 5-10)
 - Each result contains:
 - Method/function name
 - Full documentation text
 - Parameters description
 - Return value description
 - Usage examples (if available)
 - Relevance score

Format: Plain text with markdown formatting
```

**Examples:**

#### Example 1: Find specific method

```yaml
User: "Как использовать СтрРазделить?"

Action:
 user-1c-help-docsearch(query="СтрРазделить")

Expected result:
 ---
 СтрРазделить(Строка, Разделитель)
 
 Разделяет строку на части по указанному разделителю.
 
 Параметры:
 - Строка (Строка) - исходная строка
 - Разделитель (Строка) - символ-разделитель
 
 Возвращаемое значение:
 - Массив - массив строк
 
 Пример:
 Результат = СтрРазделить("один;два;три", ";");
 // Результат = ["один", "два", "три"]
 ---
```

#### Example 2: Search by functionality

```yaml
User: "Как работать с файлами в 1С?"

Action:
 user-1c-help-docsearch(query="работа с файлами")

Expected result:
 Multiple results about file operations:
 - НайтиФайлы()
 - КопироватьФайл()
 - УдалитьФайлы()
 - ПолучитьИмяВременногоФайла()
 - etc.
```

#### Example 3: Partial match

```yaml
User: "Какие есть функции для работы со строками?"

Action:
 user-1c-help-docsearch(query="функции строки")

Expected result:
 - СтрДлина()
 - СтрРазделить()
 - СтрЗаменить()
 - СтрНайти()
 - СтрСравнить()
 - etc.
```

#### Example 4: Platform feature

```yaml
User: "Как создать HTTP-соединение?"

Action:
 user-1c-help-docsearch(query="HTTP соединение")

Expected result:
 - HTTPСоединение - конструктор
 - HTTPЗапрос - создание запроса
 - HTTPОтвет - обработка ответа
 - Examples of usage
```

---

## Edge Cases

### Case 1: Method not found

```yaml
Situation: Query returns no results

Possible reasons:
 - Method is from БСП (not platform) → try search_bsp_functions
 - Typo in method name → try alternative spelling
 - Method is project-specific → try project MCP tools
 - Method doesn't exist → inform user

Action:
 1. Try alternative query (e.g., "Стр" instead of "СтрРазделить")
 2. If still no results, try search_bsp_functions
 3. If still no results, inform user and suggest alternatives
```

### Case 2: Too many results

```yaml
Situation: Query returns 50+ results

Possible reasons:
 - Query too broad (e.g., "функции")
 - Need more specific query

Action:
 1. Ask user to be more specific
 2. Or: Show top 5-10 results with note "Found 50+ results, showing top 10"
 3. Suggest refining query
```

### Case 3: English query

```yaml
Situation: User asks in English

Action:
 1. Translate to Russian (1C docs are in Russian)
 2. Search with Russian query
 3. Return results in Russian (with English summary if needed)

Example:
 User: "How to split string?"
 Query: user-1c-help-docsearch(query="разделить строку")
 Result: СтрРазделить() documentation
```

### Case 4: Ambiguous query

```yaml
Situation: Query could mean multiple things

Example: "Получить данные"
 - Could be: HTTP request, database query, file read, etc.

Action:
 1. Return multiple relevant results
 2. Let user choose or refine query
 3. Explain differences between results
```

---

## Integration with Other Tools

### Complementary Tools

```yaml
search_1c_docs → search_bsp_functions:
 - If platform method not found, try БСП
 - Example: "ОбщегоНазначения.ПолучитьДанные" → search_bsp_functions

search_1c_docs → search_1c_templates:
 - After finding method, get code example
 - Example: Found СтрРазделить() → get template for string processing

search_1c_docs → check_bsl_syntax:
 - After learning syntax, validate code
 - Example: Wrote code using new method → check syntax
```

### Workflow Patterns

#### Pattern 1: Learn → Apply → Validate

```yaml
Step 1: Learn method
 user-1c-help-docsearch(query="СтрРазделить")

Step 2: Get template
 user-1c-templates-templatesearch(query="разделение строки")

Step 3: Write code
 (AI generates code using learned method)

Step 4: Validate
 user-1c-syntax-checker-syntaxcheck(code="...")
```

#### Pattern 2: Explore → Deep Dive

```yaml
Step 1: Broad search
 user-1c-help-docsearch(query="работа с файлами")

Step 2: User picks specific method
 (User: "Расскажи подробнее про НайтиФайлы")

Step 3: Specific search
 user-1c-help-docsearch(query="НайтиФайлы")

Step 4: Show examples
 user-1c-templates-templatesearch(query="поиск файлов")
```

---

## Troubleshooting

### Issue 1: MCP server not responding

```yaml
Symptoms:
 - Timeout errors
 - Connection refused
 - No results

Diagnosis:
 1. Check server status: curl http://YOUR_SERVER:8003/health
 2. Check Docker container: ssh YOUR_SERVER "pct exec 100 -- docker ps | grep help-mcp"
 3. Check logs: ssh YOUR_SERVER "pct exec 100 -- docker logs help-mcp --tail 50"

Solutions:
 - Server not deployed: Deploy via docker-compose
 - Server crashed: Restart container
 - Network issue: Check Tailscale connection
```

### Issue 2: Slow responses (>5s)

```yaml
Symptoms:
 - Search takes >5 seconds
 - Timeout warnings

Possible causes:
 - First query after restart (loading embeddings)
 - Large result set
 - Server overloaded

Solutions:
 - Wait for first query to complete (cache warm-up)
 - Refine query to reduce results
 - Check server resources (memory, CPU)
```

### Issue 3: Incorrect results

```yaml
Symptoms:
 - Results don't match query
 - Irrelevant documentation returned

Possible causes:
 - Query too vague
 - Semantic search found related but not exact match
 - Documentation incomplete

Solutions:
 - Use exact method name instead of description
 - Try alternative query phrasing
 - Check if method is from БСП (use search_bsp_functions)
```

---

## Performance Characteristics

```yaml
Typical response time: <1s
First query after restart: 3-5s (cache warm-up)
Memory usage: ~2GB (with full documentation loaded)
Disk usage: ~16.8GB (documentation + embeddings)

Optimization tips:
 - Use specific queries (faster than broad searches)
 - Cache results in RLM for repeated queries
 - Batch multiple queries if possible
```

---

## Business Context

### Why this tool exists

1C platform has extensive documentation, but it's:
- Large (~16.8GB of text)
- Russian language only
- Not easily searchable
- Scattered across multiple sources

This MCP server solves these problems by:
- Indexing all documentation in one place
- Providing semantic search (find by meaning, not just keywords)
- Fast lookup (<1s typical)
- Integration with AI workflows

### Cost considerations

```yaml
Deployment cost:
 - Docker image: ~16.8GB download (one-time)
 - Disk space: ~16.8GB persistent
 - Memory: ~2GB RAM during operation
 - CPU: Minimal (<5% average)

Runtime cost:
 - Embedding model: OpenRouter (qwen/qwen3-embedding-8b)
 - Cost: ~$0.0001 per query (negligible)
 - Alternative: Use local Ollama (free, but slower)
```

---

## Related Documentation

- MCP server config: `configs/mcp-shared/docker-compose.yml`
- Cursor config: `C:\Users\YOUR_USERNAME\.cursor\mcp.json` (1c-help section)
- Infrastructure map: `configs/infra-mcp/data/infrastructure.yaml`
- Tool registry: `docs/mcp-tool-registry.md`

---

## Version History

- **1.0** (2026-02-08): Initial skill created as part of MCP tools refactoring project
