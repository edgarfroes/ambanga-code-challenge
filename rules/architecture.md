# Architecture

This project uses **feature-first layered architecture** with **Cubit** as the UI state holder (MVVM-style).

## Layers (dependency direction: inward only)

```
Presentation → Domain → Data
     ↑            ↑
   app/         core/   (shared infrastructure; never depends on features)
```

| Layer | Path | Allowed to know about |
|-------|------|------------------------|
| Presentation | `lib/features/<feature>/presentation/` | Domain types, Flutter, flutter_bloc |
| Domain | `lib/features/<feature>/domain/` | Dart only (no Flutter, no http, no data impls) |
| Data | `lib/features/<feature>/data/` | Domain ports/models, http, core network |
| App | `lib/app/` | Wiring: DI, router, shell |
| Core | `lib/core/` | Shared infra: network, auth, errors |

## Non-negotiable rules

1. Dependencies always point **inward**: UI → Domain → Data.
2. Presentation **never** imports `data/` or concrete `*ApiImpl` / `*ServiceImpl`.
3. Domain **never** imports Flutter, `package:http`, presentation, or data.
4. Cubits depend on **abstract** domain ports only; GetIt wires implementations.
5. Only DI modules (`lib/app/di/`) may reference both interface and implementation.
6. Cross-feature imports go through the other feature’s **domain** API, not its presentation or data.
7. New features follow the same folder shape; do not invent parallel structures.

## Stack

- State: Cubit + sealed states (`flutter_bloc`)
- DI: GetIt (`lib/app/di/`)
- Networking: HTTP client + interceptors (`lib/core/network/`)
- Routing: app router under `lib/app/router/`
