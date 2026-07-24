# Dependency & import boundaries

Agents and contributors must preserve these edges. Violations are bugs.

## Allowed dependency graph

```
main.dart
  └── app/  (di, router, shell)
        ├── features/*/presentation
        │     └── features/*/domain
        ├── features/*/data
        │     ├── features/*/domain
        │     └── core/
        └── core/
```

## Forbidden imports

| From | Must not import |
|------|-----------------|
| `features/*/presentation/**` | `features/*/data/**`, `*_impl.dart`, `core/network/**` (prefer cubit → domain only) |
| `features/*/domain/**` | `package:flutter/**`, `package:http/**`, `features/**/data/**`, `features/**/presentation/**` |
| `features/*/data/**` | `features/**/presentation/**`, other features’ `data/` or `presentation/` |
| `core/**` | `features/**` |
| `features/A/**` | `features/B/presentation/**`, `features/B/data/**` |

Cross-feature need → depend on `features/B/domain/` only, or lift shared types into `core/` if truly shared.

## DI rules (GetIt)

1. Register in feature modules under `lib/app/di/modules/`.
2. Always register: `abstract port` ← `concrete impl`.
3. Cubits receive ports via constructor; resolve from locator at composition edge (page/route/module), not deep inside widgets when avoidable.
4. Never `GetIt.I<ConcreteImpl>()` from presentation or domain.
5. On logout / session clear, dispose or reset user-scoped registrations so no previous-user state leaks.

## Cubit rules

1. Constructor deps: domain abstractions only.
2. Emit explicit sealed states: loading / success / error (as required by the feature).
3. No direct `http` calls inside cubits.
4. Side effects (polling, lifecycle) stay in the cubit or a domain service — not in the widget beyond starting/stopping via cubit API.

## Enforcement checklist (before finishing a change)

- [ ] No presentation file imports `data/` or `*_impl.dart`
- [ ] No domain file imports Flutter or http
- [ ] New feature has `presentation/`, `domain/`, `data/` (omit only with reason)
- [ ] New port has a DI registration module entry
- [ ] Tests mock domain ports, not HTTP stack, when testing cubits
