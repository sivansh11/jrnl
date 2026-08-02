# JRNL

An offline-first AI journaling tool. All data lives on your machine in `~/.jrnl`.

## Usage

```
jrnl --help
usage: jrnl [-h] [--debug] {add,sync,ls,ask,reembed} ...

options:
  -h, --help    show this help message and exit
  --debug       enable debug output

commands:
  {add,sync,ls,ask,reembed}
    add         add jrnl entry
    sync        sync jrnl entries
    ls          list entries
    ask         ask a question against your journal
    reembed     reembed all chunks with the current embedding model
```

## Commands

### add

`jrnl add "your jrnl entry"`

Appends the entry to the journal and automatically dispatches a sync in the background.

### ls

`jrnl ls [--days N]`

Lists entries from the last `N` days (default 3). Entries that have not been synced yet are marked as `(pending)`.

### sync

`jrnl sync`

Breaks journal entries down into semantically atomic chunks (events, thoughts, emotions, observations) via an LLM, then generates embeddings for each chunk to enable dynamic retrieval.

### ask

`jrnl ask "query" [--threshold F] [--top N] [--no-tools]`

By default, `ask` gives the LLM two tools and lets it decide what to fetch:

- `journal_search` — embeds the query and retrieves the most similar chunks from the journal (using cosine similarity against the embedding threshold), then returns them as context.
- `journal_get_entries` — returns all chunks from entries within an inclusive date range (`DD-MM-YYYY`), e.g. to answer date-specific questions.

The LLM calls the tools iteratively and answers using the retrieved chunks, citing their timestamps and chunk ids. Pass `--no-tools` to disable tool calling and use the old single-shot semantic retrieval. The `--threshold` and `--top` flags set the defaults for `journal_search`.

### reembed

`jrnl reembed`

Re-embeds every chunk with the current embedding model and updates `in-use.config`. Run this if the embedding model or its endpoint ever changes; `sync` and `ask` refuse to run against embeddings produced by a different model and point you here.

## Environment Variables

| Variable | Purpose | Default |
| --- | --- | --- |
| `JRNL_DEBUG` | Enable debug output | `False` |
| `JRNL_FOLDER` | Directory where journal data is stored | `~/.jrnl` |
| `JRNL_BASE_URL` | Base URL of the OpenAI-compatible API server | `http://localhost:8080/v1` |
| `JRNL_API_KEY` | API key used to authenticate with the server | `api-key` |
| `JRNL_EXTRACTION_MODEL` | Model used to split entries into semantic chunks during sync | `unsloth/gemma-4-E2B-it-qat-GGUF:Q4_K_XL` |
| `JRNL_CHAT_MODEL` | Model used to answer questions during ask | `JRNL_EXTRACTION_MODEL` (same as extraction model) |
| `JRNL_EMBEDDING_MODEL` | Model used to generate embeddings for chunks and queries | `nomic-ai/nomic-embed-text-v1.5-GGUF:Q8_0` |
| `JRNL_EMBEDDING_BASE_URL` | Base URL of the embedding API server; must stay constant to keep embeddings comparable | `JRNL_BASE_URL` |
| `JRNL_EMBEDDING_API_KEY` | API key used to authenticate with the embedding server | `JRNL_API_KEY` |
| `JRNL_EXTRA_BODY` | Extra JSON body sent with chat completions, e.g. `{"reasoning": {"enabled": true, "effort": "medium"}}` for OpenRouter | `{"enable_thinking": true}` |
