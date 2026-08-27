# Ratepanik (Flutter)

Native **iOS and Android** client for [Ratepanik](https://github.com/wladosh/ratepanik), the German party quiz.

Both clients talk to the **same Supabase** project (Auth, Realtime, RPCs). There is no separate native backend.

## What works

| Feature | Status |
| --- | --- |
| **Auth** | Email+password login, registration, anonymous guest sign-in |
| **Home** | German pastel claymorphic dashboard — create room (host), join by 6-char code, Freunde / Statistik / Erfolge / Shop navigation |
| **Lobby** | Create room via DB insert, join by code, realtime player list, host kick (`kick_player` RPC), host starts match |
| **Match — number_guess** | Question prompt, numeric input, reveal with scoring |
| **Match — find_lie** | Tap-the-lie statements, reveal |
| **Match — order_it** | Drag-to-reorder items, submit order, reveal |
| **Match — pick_correct** | 8-card grid, tap to find 4 correct, real-time turn tracking |
| **Theme picker** | Rotating per-block theme vote (random 2 themes), theme icons |
| **Block scoreboard** | Ranked score list after each block |
| **Final results** | Match leaderboard, play again / go home |
| **Realtime** | Postgres Changes subscription on rooms, players, match_blocks, answers, pick_correct_turns — same channels as the web client |
| **Profile** | XP, Level, Hirncoins from `profiles` table |
| **Friends** | Lists accepted friendships |
| **Achievements** | Grid of all active achievements with unlock state |
| **Shop** | Lootbox tiers (UI, purchase stubbed) |
| **Art assets** | Theme icons, lootbox images, badge images from web repo `public/rp/` |

### Not yet implemented (stubs / planned)

- Google OAuth (needs iOS/Android redirect URI config per Supabase dashboard)
- Schleimi cosmetic loadout rendering
- Lootbox purchase + open_lootbox RPC
- Friend add/remove
- Daily play streak persistence
- Match rewards (XP/Hirncoins at match end)
- Avatar onboarding
- Username claim

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.38+ (stable)
- Xcode (iOS) and/or Android Studio / Android emulator

```bash
flutter doctor
```

## Run

The app connects to the shared Ratepanik Supabase project (`uwbhgveknypqvrwazleq`). You must supply the **anon key** via `--dart-define`. Do **not** commit the key.

```bash
flutter pub get

# Replace YOUR_ANON_KEY with the value from the Ratepanik Supabase dashboard
# (same as NEXT_PUBLIC_SUPABASE_ANON_KEY in the web app's .env)
flutter run \
  --dart-define=SUPABASE_URL=https://uwbhgveknypqvrwazleq.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Or create a local `.env` file (git-ignored) and source it:

```bash
# .env (do NOT commit)
SUPABASE_URL=https://uwbhgveknypqvrwazleq.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

```bash
source .env
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Checks

```bash
flutter analyze
flutter test
```

## Layout

```
lib/
  main.dart                 # Entry: init Supabase, run app
  app.dart                  # MaterialApp.router with GameService
  core/
    supabase_config.dart    # Supabase init from --dart-define
  models/
    db_models.dart          # DB row models (rooms, players, blocks, answers…)
    room_settings.dart      # Room settings parsing (mirrors web)
    game_scoring.dart       # Scoring logic for all 4 modes
  services/
    game_service.dart       # Game state + realtime (port of game-context.tsx)
  theme/                    # Colors + Material theme (web --rp-* tokens)
  l10n/                     # German strings
  routing/                  # go_router
  widgets/                  # Shared shell controls
  features/
    landing/                # Guest join landing
    auth/                   # Login + Register
    home/                   # Dashboard with nav cards
    lobby/                  # Room code, player list, kick, start
    match/                  # Match shell + all 4 mode screens + reveal + scores
    shop/                   # Hirnkiste lootbox shop
    profile/                # XP / Level / Hirncoins
    friends/                # Friends list
    achievements/           # Achievement grid
assets/rp/                  # Art assets from web repo
```

## Architecture

- **No WebView** — pure native Flutter widgets.
- **GameService** (`ChangeNotifier`) holds all match state and realtime subscriptions. It's a faithful port of the web app's `game-context.tsx`.
- **Supabase Realtime** via Postgres Changes on `rooms`, `players`, `match_blocks`, `answers`, `pick_correct_turns` — identical channel patterns to the web client.
- **Same RPCs**: `kick_player(p_room_id, p_player_id)`, `leave_match(p_room_id)`.
- **Same tables**: `rooms`, `players`, `match_blocks`, `answers`, `pick_correct_turns`, `match_scores`, `themes`, `prompts`, `profiles`, `friendships`, `achievements`, `user_achievements`.
