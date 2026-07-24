# Feature module layout

Every feature under `lib/features/<name>/` follows this shape:

```
lib/features/<name>/
├── presentation/
│   ├── <name>_page.dart
│   ├── <name>_cubit.dart
│   └── <name>_state.dart
├── domain/
│   ├── <entity>.dart
│   └── <name>_api.dart          # or *_service.dart abstract port
└── data/
    └── <name>_api_impl.dart     # implements domain port
```

Plus DI wiring:

```
lib/app/di/modules/<name>_module.dart
```

## Adding a feature

1. Create the three layer folders.
2. Define domain models + abstract port first.
3. Implement data against the port.
4. Implement cubit + sealed states + page.
5. Register port, impl, and cubit in `lib/app/di/modules/<name>_module.dart`.
6. Export/register the module from `lib/app/di/locator.dart`.
7. Add route in `lib/app/router/` if it is a screen.

## Assessment / parallel trees

- `part1_diagnosis/` and `part2_implementation/` are exercise sources.
- Production-shaped code lives under `lib/`.
- Prefer implementing Part 2 against the same boundaries as `lib/features/**`.
- Do not “fix” diagnosis files in `part1_diagnosis/`; answers go in `ANSWERS.md`.

## What belongs in core vs a feature

| Put in `core/` | Put in `features/<name>/` |
|----------------|---------------------------|
| HTTP client, interceptors | Feature API + impl |
| Auth/session primitives | Feature cubit/page/state |
| Shared `AppException` | Feature entities |
| Truly app-wide utilities | Anything used by one feature only |
