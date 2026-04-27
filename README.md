# Marsky Crypto Dashboard

A SaaS-style crypto dashboard built with **Flutter** for the Marsky Code Challenge.
Powered by the **CoinRanking** API, secured with **Supabase** authentication, and
backed by a **Hive** local database for per-user favorites.

## Features

- **Email/password authentication** (Supabase) with persistent sessions,
  reactive auth-aware routing (`go_router`), and **password reset** flow.
- **Home tab**: paginated list of coins with infinite scroll, pull-to-refresh,
  client-side **search bar**, and sort options (Market Cap / Price / 24h Volume /
  24h Change / Listed Date, asc ↔ desc).
- **Favorites tab**: per-user favorites stored locally in Hive, surviving app
  restarts and isolated by `userId`. Pull-to-refresh supported.
- **iOS-style modal bottom sheet** for coin detail with description, all-time
  high, website link, high/low/market cap stats and an `fl_chart` line chart
  with selectable time period (1H / 24H / 7D / 30D / 1Y).
- **Hero animation** between coin tile and detail sheet icons.
- **Shimmer skeletons** for coins-list loading state.
- **Dark / light mode toggle** persisted via `SharedPreferences`.
- **Localization** (TR / EN) generated through `flutter_localizations` + ARB.
- **Offline mode**: GET responses cached for 5 minutes via
  `dio_cache_interceptor` (Hive store).
- **Structured logging** via `logger` package (Dio request/response/error).
- **Logout confirmation** via Cupertino dialog from the main shell.
- Friendly error / empty / loading states throughout.
- **CI**: GitHub Actions runs `flutter analyze` + `flutter test --coverage` on
  every push (`.github/workflows/ci.yml`).

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

- Cross-device favorite sync (local-only; Supabase schema documented below for
  a future milestone).
- Candlestick chart (line chart used).
- Push notifications / price alerts.
- Social login (email + password only).

### Future: Supabase favorites cloud sync

```sql
create table favorites (
  user_id  uuid references auth.users on delete cascade,
  uuid     text not null,
  name     text not null,
  symbol   text not null,
  icon_url text,
  added_at timestamptz default now(),
  primary key (user_id, uuid)
);
alter table favorites enable row level security;
create policy "own favorites" on favorites
  for all using (auth.uid() = user_id);
```
