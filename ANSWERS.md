# Answers

---

## Part 0 - Architecture Declaration

### 0.1 - Architecture choice

I will use a **Feature-first layered architecture** (Flutter recommended layers + feature modules), with **Cubit as the UI state holder** (MVVM-style).

To enforce architectural boundaries, I will have dedicated rules and guidelines for agentic IDEs, pre-commit hooks, and CI/CD pipelines with code analyzers raising flags before merging code (e.g. during Pull Requests).

#### Pros

- Well-known architectures make it easier to find professionals with experience, plus easening onboarding of new team members.
- Clear dependency direction (UI → Domain → Data), plus it's easy to test
- Feature modules scale with team size (own folders, fewer merge conflicts)
- Swapping data sources (HTTP → cache/offline) stays behind domain ports
- Matches Flutter’s recommended layering and this stack (Cubit, GetIt, interceptors)
- AI assisted development with clear boundaries and patterns enforces consistency and adoption.

#### Cons

- Higher ceremony per feature (page, cubit, state, port, impl, DI module) slows the first cut of simple screens
- Easy to over-abstract early when domain logic is thin and ports become pass-through wrappers
- Boundary safety still needs discipline and tooling (lint/import rules, agent rules, review); one bad import re-couples layers
- Cross-feature work is clumsier until shared contracts are extracted deliberately into domain or `core/`

### 0.2 - Layer mapping

| File                              | Layer / Component                | Reason                                                                                                                                                                                         |
| --------------------------------- | -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NotificationsCubit`              | **Presentation** (ViewModel)     | It turns domain results into UI state and handles screen behaviour (load, poll, retry, errors). That is presentation logic, so it sits next to the UI—not in domain or data.                   |
| `NotificationsApi` (interface)    | **Domain** (port)                | It defines _what_ the feature needs from the outside world, without saying _how_. Domain is where those stable contracts live so UI and data can both depend on them.                          |
| `NotificationsApiImpl` (concrete) | **Data** (implementation)        | It is the _how_: real calls, parsing, mocks, caching. Only the data layer should know transport details; DI plugs this into the domain port.                                                   |
| `NotificationsPage`               | **Presentation** (View)          | It is the Flutter UI: draw state, take taps, report lifecycle. It talks to the cubit only, so it belongs in presentation.                                                                      |
| `OrganisationService`             | **Domain** (application service) | It runs organisation use-cases against a port, with no widgets and no HTTP. That is domain work; wiring a Cubit into it (as in Part 1) would pull it into presentation and break the layering. |

### 0.3 - Scalability justification

Even though the architecture itself is simple, it scales well because it's well-known and agentic, meaning that AI analysis will grow with the codebase. However, some arguments against this approach include:

- Privacy concerns with AI analysis sending private code and data to external services;
- Cost in AI code analysis can pose a significant financial burden as the codebase grows;
- Dependency on external AI services for code analysis may introduce latency and reliability issues;

If possible and financially feasible, on-premise or self-hosted AI solutions should be considered to mitigate these concerns.

### 0.4 - Proposed folder structure

Feature-first under `lib/features/`, layers inside each feature. App wiring and shared infra stay outside features.

```
lib/
├── main.dart
├── app/                              # composition root
│   ├── app.dart
│   ├── home_shell.dart
│   ├── router/
│   │   └── app_router.dart
│   └── di/
│       ├── locator.dart              # GetIt root
│       └── modules/
│           ├── core_module.dart
│           ├── notifications_module.dart
│           ├── organisations_module.dart
│           └── users_module.dart
├── core/                             # shared infra (no feature imports)
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── session_coordinator.dart
│   ├── error/
│   │   └── app_exception.dart
│   └── network/
│       ├── interceptor_contract.dart
│       ├── remote_api_client.dart
│       └── interceptors/
│           ├── http_error_interceptor.dart
│           └── http_rate_limit_interceptor.dart
└── features/
    ├── notifications/
    │   ├── presentation/             # Page, Cubit, State
    │   │   ├── notifications_page.dart
    │   │   ├── notifications_cubit.dart
    │   │   └── notifications_state.dart
    │   ├── domain/                   # entities + abstract ports
    │   │   ├── notification.dart
    │   │   └── notifications_api.dart
    │   └── data/                     # port implementations
    │       └── notifications_api_impl.dart
    ├── organisations/
    │   ├── presentation/
    │   ├── domain/                   # includes OrganisationService
    │   └── data/
    └── users/
        ├── presentation/
        ├── domain/
        └── data/
```

**How to read it:** navigation and DI live in `app/`. HTTP/auth/errors in `core/`. Each product capability is a folder under `features/` with `presentation → domain → data`. New screens add a feature (or extend one) and a DI module—nothing lands in `core/` unless two+ features truly share it.

---

## Part 1 - Diagnosis

### 1.1 - UserListCubit

| Lines nº     | What                                     | Impact                                                                                                          |
| ------------ | ---------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 37           | The `users` variable is not being used   | The users list is not being emitted to the UI.                                                                  |
| 36-38        | Missing error handling.                  | The app will crash if the API call fails.                                                                       |
| 42-44        | Missing error handling.                  | The app will crash if the API call fails.                                                                       |
| 36, 42       | Missing loading state.                   | The UI will not show a loading indicator while the data is being fetched.                                       |
| 36-38, 42-44 | Missing error state.                     | The UI will not show an error message if the API call fails.                                                    |
| 36           | Missing pagination support.              | Fetching all users without pagination and/or filtering can lead to performance issues and resources exhaustion. |
| 37, 43       | Check for disposal before emitting state | The app will throw an exception in the background if the cubit is not mounted.                                  |
|              |                                          |                                                                                                                 |

Things I'd change but are not necessarily wrong:

- Using `async` and `await` instead of `.then()` have a better flow and are more readable, with better syntax.
- Add cancelation support to avoid memory leaks.
- Add an empty state when there is no data (users list is empty).
- Line 41: Add debouncing to avoid multiple parallel calls each time a term has changed. This can be handled in the UI instead.

### 1.2 - HttpErrorInterceptor

#### Bug scenario

If/when the session expires (401 403 HTTP status codes) while several requests are concurrently in flight (dashboard loading multiple resources, app resuming and refreshing lists), then `interceptResponse` runs once per response and is stateless — it has no memory that an error is already being handled. Result: N overlapping executions of `await logout(); replace(LoginRoute())` or `push(ForbiddenRoute())` instead of one.

#### Why it happens

1. `logout()` is invoked synchronously when each 401 arrives, making N concurrent logouts race on shared mutable state (token storage, session). If `logout()` itself calls an endpoint through this same client, its 401 re-enters the interceptor then cascades. As each logout completes, `replace(LoginRoute())` fires, then N replaces land on the router in quick succession.
2. For 403, concurrent 403s deterministically stack N `ForbiddenRoute` pages (back button shows Forbidden again), meaning that a `ForbiddenRoute` will be stacked on top of itself for each concurrent request.

#### How I would fix it

1. I would use a single-flight the session handling by moving "what to do on 401" out of the interceptor into one owner (e.g. a `SessionCoordinator`) guarded by an in-flight flag. The first 401 starts logout+navigation; every 401 that arrives while handling is in progress is ignored (or joins the same in-flight operation) — so N concurrent 401s still produce exactly one logout and one navigation.
2. Make the interceptor signal-only. It detects the 401 and notifies the coordinator; it does not call `logout()`, does not navigate, and holds no callback that can fire-and-forget. Side effects live at app level, where they can be coordinated.
3. Navigate once, from above the network layer. The app shell/router reacts to a single "session expired" event emitted by the coordinator, instead of routes being replaced from inside the HTTP pipeline per response.

### 1.3 - OrganisationService

#### The problem

Inverted dependency: the service depends on a Cubit. `OrganisationService` (domain logic) takes `OrganisationsCubit` (presentation) as a constructor dependency and pokes it after every API call (`_cubit.setAll(orgs)`, `_cubit.addOne(org)`, `_cubit.removeById(id)`). A lower layer reaches up and mutates UI state directly — the dependency arrow points the wrong way (which is also why `flutter_bloc` leaks into the service).

#### Why it is problematic

- **Cyclic coupling**: the cubit normally calls the service (presentation → domain). Now each knows the other — the service can't be reused behind a different state holder, and changing the cubit ripples into the service.
- **Unusable without UI**: tests, background sync, or a second screen must construct a Cubit just to call `createOrganisation`. The design silently assumes exactly one global cubit and breaks the moment two consumers need the data.
- **Lifecycle fragility**: if the page closes while a request is in flight, emitting to the closed cubit crashes at runtime.
- **Hidden side effects**: a method that looks like "fetch and return" secretly mutates global UI state; the return value and the cubit state become two competing sources of truth.
- **Anemic cubit**: a raw `List<Organisation>` with no loading/error states, so the UI can't render progress or failures — worse as pagination/caching/offline arrive.

#### How I would refactor it

1. I would restore the dependency direction: the service depends only on the `OrganisationsApi` port; remove the cubit from its constructor and just return data.
2. The cubit owns its own state: it calls the service and emits from the returned values.
3. Give the cubit a sealed state hierarchy (`Loading / Loaded / Error`) instead of a bare list.
4. If multiple consumers need fresh data, expose a domain-owned stream (e.g. `watchOrganisations()` from a repository with its own cache/invalidation) and let any cubit subscribe — presentation subscribes to domain, domain never pokes presentation.
5. Wire cubit → service → api port → impl in the feature's DI module.

In short: flip the arrow — data flows up as return values/streams; only the cubit writes cubit state.

### 1.4 - Architecture Boundary Breaks

Measured against the architecture declared in Part 0 (Presentation → Domain → Data; `core/` infrastructure owned by the app composition root).

#### Break 1 — `organisation_service.dart`: `OrganisationService` constructor and all its methods

The domain service takes `OrganisationsCubit` (presentation) as a dependency and calls `setAll` / `addOne` / `removeById` on it, importing `flutter_bloc` to do so. **Expected direction:** presentation → domain — the cubit calls the service and owns its own state; the service depends only on the `OrganisationsApi` port and must never import presentation or flutter_bloc. **Practical consequence (testability/coupling):** the service can't be unit-tested without constructing a Cubit and pulling in the bloc framework, and any change to the cubit's API ripples into the service — two consumers (a second screen, a sync job) can't share it.

#### Break 2 — `http_error_interceptor.dart`: the registered `onError` callbacks (401/403 block)

The network-layer interceptor triggers `AuthService.logout()` (session policy) and `AppRouter.replace/push` (navigation, presentation) from inside the HTTP pipeline. **Expected direction:** the interceptor only _signals_ (typed exception or status event); the app layer above the network stack owns session policy and navigation. Infrastructure must not know routes exist. **Practical consequence (team velocity):** session/navigation behaviour is glued to the HTTP client — every change to global auth behaviour touches network code, per-response side effects can't be coordinated (the concurrent-401 storm from 1.2), and the client can't be tested without a router and a fully populated locator.

#### Break 3 — `http_error_interceptor.dart`: `locator<AuthService>()` / `locator<AppRouter>()` inside the callback

Service-locator lookups inside infrastructure code — hidden dependencies that bypass constructor injection, so the DI composition root no longer owns the graph. **Expected direction:** dependencies flow inward via constructors, wired in `app/di` modules; an interceptor receives what it needs at registration (ideally just a signal hook provided by a session coordinator). **Practical consequence (coupling/testability):** the dependency is invisible from the constructor, tests must spin up a global locator with auth + router registered, and lifecycle bugs appear — the lookups happen after `await` gaps, so they can hit a locator that logout just reset.

---

## Part 2 - Implementation

### 2.1 - Locator registration snippet

````dart
import 'package:get_it/get_it.dart';

import 'modules/core_module.dart';
import 'modules/notifications_module.dart';
import 'modules/organisations_module.dart';
import 'modules/users_module.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  await registerCoreModule(locator);
  registerNotificationsModule(locator);
  registerOrganisationsModule(locator);
  registerUsersModule(locator);
}
```

---

## Part 3 - Written Questions

### 3.1 - Cubit vs BLoC vs Riverpod

### 3.2 - Centralised locator

### 3.3 - Offline operations queue

### 3.4 - Previous user data bug

### 3.5 - SOLID principles in practice

<!-- Principle 1: name, file, violation, consequence, refactor -->

<!-- Principle 2: name, file, violation, consequence, refactor -->

### 3.6 - Dependency direction in this project

<!-- Describe expected dependency direction, a concrete break scenario, and how to enforce boundaries -->

### 3.7 - Architecture under growth

<!-- Firebase push notifications - layers touched: -->

<!-- Offline-first organisation list - layers touched: -->

<!-- Global theme switcher - layers touched: -->
````
