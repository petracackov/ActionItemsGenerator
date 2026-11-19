# Action Items Generator

Take-home test project for a job application. Timebox: 4 hours (graded on what's there, not how much). Stack is free choice.

## Requirements

- See [`Documentation/Assignment.md`](Documentation/Assignment.md). Read it before planning or building anything.

## Stack

- See [`Documentation/Stack.md`](Documentation/Stack.md), [`Documentation/Architecture.md`](Documentation/Architecture.md) and [`Documentation/Decisions.md`](Documentation/Decisions.md).

## Working rules

- **Small steps only.** Never do a big chunk of work in one go. After each meaningful step, stop and ask the user to review. Continue only after explicit permission.
- **Backend:** the user is new to backend development. Explain what you're doing and why (concepts, tools, commands) more often and in plain terms.
- **Swift / macOS:** the user is a senior iOS engineer. No long explanations; only call out non-obvious decisions.
- **General:** no fluff. Short, correct, to the point.
- **Docs location:** put all documentation and plans in the `Documentation/` folder. `AGENTS.md` holds only rules and pointers to those files, never documentation content. Exception: the root `README.md`, which holds only what the assignment requires. Add nothing extra unless the user asks.
- **Document as you go:** document features, stack, libraries and key decisions in `Documentation/`. Always ask the user before adding or changing any documentation.

## Swift / SwiftUI (Mac app)

- **No tests** for the Mac app.

### Swift + SwiftUI conventions

- Every new Swift file starts with the standard Xcode header: file name, project `ActionItemsGenerator`, `Created by Petra Cackov on <D. M. YY.>`.
- Follow Apple naming conventions (`UpperCamelCase` types, `lowerCamelCase` members).
- Keep views small and composable. Move logic out of views when it grows.
- Prefer `struct` and value semantics unless reference behavior is required.
- Keep side effects explicit and easy to trace.
- No `didSet`/`willSet` unless asked or there's no other option. Use explicit update methods that set the property and trigger the side effect.
- Never put the first `init` parameter on a new line after a standalone `init(`. Use a single line, or keep the first parameter on the `init(` line and continue on the next lines.

### Naming

- Protocols only when there's a clear need (multiple implementations, boundary decoupling). Suffix `Protocol`.
- Views: `<Name>View`. View modifiers: `<Name>Modifier`, exposed via a `View` extension (`.name()`). Styles: `<Name>Style`, variants `<Variant><Name>Style`.
- Models use plain entity names (`Note`, `ActionItem`).
- Clear, domain-neutral names.

### Component design

- Views get their data from their parent or ViewModel and focus on display, with minimal embedded logic.
- Prefer composition over inheritance and over configuration flags. Split into smaller views when options multiply.
- Flow: `View -> ViewModel (optional)`. Add a ViewModel only when the screen has real logic.
- ViewModel state uses `@Observable`, not `ObservableObject`/`@Published`. ViewModels are not `final` by default.
- View-local UI state lives in `@State`.
- Concurrency: the target's default actor isolation is `MainActor`, so don't annotate types with `@MainActor`. Mark non-UI work `nonisolated` explicitly.
- async/await by default. No Combine unless required.
- Don't use `.task` or make API calls in `.onAppear`. Start async work from ViewModel-owned `Task`s and cancel long-running ones explicitly.
- Shared/global state must not contain navigation or presentation concerns.

### Error handling

- Typed errors as enums (or a dedicated wrapper) conforming to `Error`.
- Don't handle generic `Error` unless it's converted to a typed error right away.
- Never silently swallow errors. Surface actionable failures.
- No automatic retries.

### Engineering patterns

- Single source of truth for shared state. No duplicate ownership of the same data.
- Prefer reactive state updates over manual refresh.
- Keep data mutation paths explicit and centralized.
- Enums: use `switch`, never `if` with enum cases. List every case explicitly, group cases with the same logic, no `default` unless asked.
- `guard` for early exits. Related branches as one `if/else` chain, ending in a final `else`, not several standalone `if`s.
- Exception for views: conditional rendering uses a single-branch `if`, never `else { EmptyView() }`.
- Prefer `!condition` over `condition == false`.
- No raw string literals for identifiers and keys (image names, storage keys, type identifiers). Use centralized constants or type-safe enums.
- Nest child model types inside the parent when they aren't reused elsewhere.
- Put extensions in the same file as their type unless there's a clear organizing reason.
- New methods are `private` by default. Widen only when needed.
- No custom `init` when the synthesized one is enough.
- Prefer synthesized `Codable` with decoder strategies (see [`Documentation/API.md`](Documentation/API.md)). No custom decoders unless clearly needed.

### Project structure

Under `MacApp/ActionItemsGenerator/ActionItemsGenerator/`:

- `Views/`: SwiftUI views, one folder per screen when it has supporting files.
- `ViewModels/`: `@Observable` ViewModels.
- `Models/`: `Codable` types matching the API.
- `Networking/`: the backend client.
- `Modifiers/`, `Styles/`: custom view modifiers and styles, if any.
- `Extensions/`: one file per extended type, named `<Type>+<Topic>.swift`.
- `Resources/`: asset catalog, the text and icon enums/structs, constants.

Keep code in the closest relevant folder. Promote it to a shared folder only when it's reused.

### Text

- All user-facing text (including accessibility labels) lives in one file, in one enum/struct. No string literals in views.

### Icons

- All icons live in one file, in one enum/struct (single source of truth).
- SF Symbols by default. A custom icon goes in the asset catalog and is still exposed through the same enum/struct.
- Name icons clearly by purpose.

### Colors

- Asset catalog color sets for app colors. Prefer semantic/system colors.
- Never hardcode hex/RGB values in views.
- Keep color names centralized and semantic.

### Images

- All bundled images go in the asset catalog.
- Never load UI images via raw file paths.
- Name images consistently and descriptively by feature.

## Git

- **Branches, no PRs:** do each step on a `feature/<name>` branch, then merge it into `main` directly. No pull requests (single developer).
- **Keep branches:** never delete a branch after merging it.

## Project skills

- Skills live in `.claude/skills/<name>/SKILL.md`. Run `/list-skills` to see them all.
- **Suggest new skills:** when a task or workflow repeats and would make a good skill, suggest creating one: name it and say what it would do. Don't create it without approval.
