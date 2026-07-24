# Layer responsibilities

## Presentation (`presentation/`)

**Owns:** widgets/pages, Cubits, UI state classes.

**Does:**
- Render state via `BlocBuilder` / `BlocListener`
- Forward user actions to Cubit methods
- Hold ephemeral UI-only concerns (animation, layout)

**Does not:**
- Call HTTP, parse JSON, or touch interceptors
- Import `*ApiImpl`, `RemoteApiClient`, or other data types
- Contain business rules beyond simple view mapping

**Naming:**
- `*_page.dart` — screen widgets
- `*_cubit.dart` — state holders
- `*_state.dart` — sealed state hierarchy (prefer sealed + subclasses)

## Domain (`domain/`)

**Owns:** entities, abstract ports (Api/Service), pure domain logic.

**Does:**
- Define contracts (`abstract class NotificationsApi`)
- Define models used across layers
- Optional: pure validation / mapping that needs no I/O

**Does not:**
- Import `package:flutter`, `package:http`, or `data/`
- Perform I/O

**Naming:**
- `*.dart` entities (`notification.dart`, `user.dart`)
- `*_api.dart` / `*_service.dart` — abstract ports

## Data (`data/`)

**Owns:** concrete implementations of domain ports.

**Does:**
- Implement `*Api` / `*Service` with HTTP (or cache/DB)
- Map DTOs ↔ domain models
- Use `lib/core/network` clients and shared errors

**Does not:**
- Import presentation (pages, cubits, states)
- Expose transport types to UI

**Naming:**
- `*_api_impl.dart` / `*_service_impl.dart`

## App (`lib/app/`)

**Owns:** composition root — DI modules, router, app shell.

**Does:**
- Register interfaces → implementations in GetIt modules
- Define routes and top-level navigation chrome

**Does not:**
- Implement feature business logic

## Core (`lib/core/`)

**Owns:** shared infrastructure used by multiple features.

**Does:**
- HTTP client, interceptor contracts, auth/session, app exceptions

**Does not:**
- Depend on `lib/features/*`
- Contain feature-specific UI or domain rules
