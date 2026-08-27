# Ratepanik (Flutter)

Native **iOS and Android** client for [Ratepanik](https://github.com/wladosh/ratepanik), the German party quiz.

This repo is the mobile app. The web prototype stays in the sibling Next.js project (`../ratepanik`). Both clients will talk to the **same Supabase** project (Auth, Realtime, RPCs). There is no separate native iOS/Android codebase.

Right now this is an **app shell only**: Ratepanik theme, German copy, and Landing / Login / Home stubs. Nothing talks to a server yet.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.38+ (stable)
- Xcode (iOS) and/or Android Studio / an Android emulator

Check the toolchain:

```bash
flutter doctor
```

## Run

```bash
flutter pub get
flutter run
```

Pick a simulator/emulator, or pass `-d` with a device id from `flutter devices`.

Useful checks:

```bash
flutter analyze
flutter test
```

## What’s in the shell

| Screen | Route | Behavior |
| --- | --- | --- |
| Landing | `/` | Join-code field, register (placeholder), login |
| Login | `/login` | Visual email/Google/guest card. **Anmelden** opens Home so the route tree is reachable. Other actions show **Bald**. |
| Home | `/home` | Mock registered home: level / XP / Hirncoins as **Bald**. Create and join are placeholders. |

Join validates a 6-character code locally, then shows **Bald** — no room lookup.

## Next slices (not built yet)

1. Wire `supabase_flutter` to the same project as web (`NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY`)
2. Session restore + email login (then Google / guest)
3. Join-by-code against real rooms
4. Lobby and the realtime match engine (the hard part — today this lives in the web `game-context.tsx`)

Keep the Next.js service-role key off this client. Use the anon key and RLS, same as the website.

## Layout

```
lib/
  main.dart
  app.dart
  theme/          # colors + Material theme (web `--rp-*` tokens)
  l10n/           # German strings (swap for real i18n later)
  routing/        # go_router
  widgets/        # shared shell controls
  features/
    landing/
    auth/
    home/
```
