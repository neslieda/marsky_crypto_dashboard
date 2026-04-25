# Marsky Crypto Dashboard

A SaaS-style crypto dashboard built with **Flutter** for the Marsky Code Challenge.
Powered by the **CoinRanking** API, secured with **Supabase** authentication, and
backed by a **Hive** local database for per-user favorites.

## Features

- **Email/password authentication** (Supabase) with persistent sessions and
  reactive auth-aware routing (`go_router`).
- **Home tab**: paginated list of coins with infinite scroll, pull-to-refresh,
  and sort options:
  - Price
  - Market Cap
  - 24h Volume
  - 24h Change
  - Listed Date
- **Favorites tab**: per-user favorites stored locally in Hive, surviving app
  restarts and isolated by `userId` (different accounts see different lists).
- **iOS-style modal bottom sheet** for coin detail with:
  - Name, rank, symbol, current price and 24h change
  - High / low (derived from history)
  - Market cap and 24h volume
  - **Line chart** (`fl_chart`) with selectable time period (1H / 24H / 7D / 30D / 1Y)
- **Logout confirmation** via Cupertino dialog, accessible from a fixed icon in
  the top-right corner of the main shell.
- Friendly error / empty / loading states throughout.

## Architecture

Clean Architecture with a feature-first folder layout.

```
lib/
  core/
    config/    # env, constants
    di/        # get_it registrations
    error/     # Failure / AppException / mappers
    network/   # Dio client + interceptors
    router/    # go_router with auth guard
    theme/     # Material 3 light + dark
    utils/     # formatters
    widgets/   # ErrorView, EmptyView
  features/
    auth/        (data | domain | presentation)
    coins/       (data | domain | presentation)
    favorites/   (data | domain | presentation)
    shell/       (MainShellPage with bottom nav)
  app.dart
  main.dart
```

Each feature is split into:
- **domain**: entities, repository interfaces, use-cases.
- **data**: models, datasources, repository implementations.
- **presentation**: BLoCs (events / states), pages, widgets.

## Tech stack

| Concern         | Choice                          |
|-----------------|---------------------------------|
| State           | `flutter_bloc` + `equatable`    |
| DI              | `get_it`                        |
| Routing         | `go_router` (auth-aware redirect) |
| Networking      | `dio`                           |
| Auth            | `supabase_flutter`              |
| Local DB        | `hive` + `hive_flutter` (manual `TypeAdapter`) |
| Chart           | `fl_chart` (Line)               |
| Functional      | `dartz` (`Either<Failure, T>`)  |
| Env             | `flutter_dotenv`                |
| Tests           | `bloc_test`, `mocktail`         |

## Getting started

### 1. Prerequisites

- Flutter `>= 3.41` (Dart 3.11)
- iOS / Android toolchain (for emulator runs)
- Supabase project (URL + anon key)
- CoinRanking API key — https://developers.coinranking.com

### 2. Configure environment

Copy the example env file and fill in your credentials:

```bash
cp .env.example .env
```

`.env`:

```
SUPABASE_URL=https://YOUR-PROJECT.supabase.co
SUPABASE_ANON_KEY=...
COINRANKING_BASE_URL=https://api.coinranking.com/v2
COINRANKING_API_KEY=...
```

The `.env` file is bundled as a Flutter asset (declared in `pubspec.yaml`)
and is **git-ignored**.

### 3. Supabase setup

In your Supabase project:

1. **Authentication → Providers → Email**: enabled.
2. (Optional) **Authentication → Email** → disable “Confirm email” during
   development so newly registered accounts can sign in immediately.
3. No additional tables are required (favorites are stored locally per user).

### 4. Run

```bash
flutter pub get
flutter run
```

### 5. Test

```bash
flutter test
flutter analyze
```

## Architectural notes

- **Auth guard**: `AppRouter` listens to `AuthBloc` and redirects unauthenticated
  users to `/login`. Supabase persists sessions automatically, so users remain
  logged in across app restarts.
- **Per-user favorites**: when an `AuthState.authenticated` is observed, the
  `FavoritesBloc` opens a Hive box named `favorites_<userId>`. On sign-out the
  box is closed and state is cleared. Different users therefore see different
  favorite lists on the same device.
- **Pagination**: `CoinsListBloc` keeps page state (offset, hasMore) and
  triggers `LoadMoreRequested` from a `ScrollController` near the list bottom.
  Sort changes reset the list and reload from offset 0.
- **Detail sheet**: opened via `showModalBottomSheet` with `isScrollControlled`,
  `useSafeArea`, drag handle, and rounded top corners — matching iOS-style
  presentation. Hosted inside a `DraggableScrollableSheet` for natural drag
  behavior.
- **Error handling**: API/Dio errors map to typed `Failure`s
  (`NetworkFailure`, `ServerFailure`, `AuthFailure`, `CacheFailure`) which are
  surfaced via `ErrorView` (with retry) or snackbar messages.

## Out of scope

- Cross-device favorite sync (favorites tracked locally per user only)
- Candlestick chart (line chart used)
- Push notifications / price alerts
- Localization (English only)
- Social login (email + password only)
