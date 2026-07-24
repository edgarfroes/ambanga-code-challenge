# Agent instructions

This repository is a Flutter technical assessment app.

## Mandatory architecture rules

Before writing or moving Dart code under `lib/`, read and follow:

1. [`rules/architecture.md`](rules/architecture.md) — overall style and stack
2. [`rules/layers.md`](rules/layers.md) — what each layer may do
3. [`rules/dependencies.md`](rules/dependencies.md) — import/DI boundaries
4. [`rules/features.md`](rules/features.md) — feature folder layout

**Summary:** feature-first + Presentation → Domain → Data. Cubits talk to abstract domain ports only. GetIt wires implementations in `lib/app/di/`.

## Assessment workflow

- Written answers → `ANSWERS.md` only
- Part 1 diagnosis → do **not** modify `part1_diagnosis/**`
- Part 2 implementation → implement indicated files; mirror `lib/features/**` boundaries
- Do not commit secrets; do not expand scope beyond the task

## When changing architecture-sensitive code

Reject or rewrite changes that:

- import `data/` or `*_impl.dart` from presentation
- import Flutter/http from domain
- resolve concrete implementations via GetIt outside DI modules
- place feature logic in `lib/core/` or UI logic in data sources
