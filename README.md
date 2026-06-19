# Video Game

2D high-fidelity co-op game built with **Godot 4**, targeting **Steam** on **Windows** and **macOS**.

## Architecture

```
Client (Godot 4)
├── SteamService      → Steam lobbies (GodotSteam when installed)
├── NetworkManager    → Host-authoritative ENet co-op (2–8 players)
├── SaveManager       → Versioned local saves (+ Steam Cloud later)
├── SceneRouter       → Menu → Lobby → Run flow
└── CrashReporter     → Local crash logs (+ Sentry DSN optional)

Steam                 → Distribution, updates, depots, playtest branches
GitHub Actions        → Win/Mac exports, steamcmd playtest deploy
```

## Prerequisites

- [Godot 4.3+](https://godotengine.org/download)
- [Git LFS](https://git-lfs.com/)
- Steam client (for lobby testing)
- GodotSteam addon — see [addons/godotsteam/README.md](addons/godotsteam/README.md)

See [`planning/`](planning/) for the mobile-friendly design decision app (open `planning/index.html` on your phone).

```powershell
cd video-game
git lfs install
# Install GodotSteam via Godot Asset Library (see addons/godotsteam/README.md)
# Open project.godot in Godot 4.3+
```

### Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| E / Space | Interact (host-validated RPC) |

### Dev modes

- **Offline Vertical Slice** — single-player run, no networking
- **Host Co-op** — creates Steam lobby (or LAN host if GodotSteam missing)
- **Join Local** — connects to `127.0.0.1:7777`

## Project layout

```
video-game/
├── addons/godotsteam/     # Install GodotSteam here
├── assets/                # Art, audio, shaders (LFS)
├── scenes/                # main_menu, lobby, game
├── scripts/autoload/      # Core singletons
├── steam/                 # steamcmd VDF templates
├── export_presets.cfg     # Windows + macOS presets
└── .github/workflows/     # CI export + Steam deploy
```

## Exports

```bash
godot --headless --export-release "Windows Desktop" build/windows/VideoGame.exe
godot --headless --export-release "macOS" build/macos/VideoGame.app
```

CI runs these on push/PR via [.github/workflows/export.yml](.github/workflows/export.yml).

## Steam deployment

1. Create Steamworks app + depots (Windows, macOS)
2. Set GitHub secrets: `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_APP_ID`, `STEAM_DEPOT_WIN`, `STEAM_DEPOT_MAC`
3. Optional Mac signing: `CODESIGN_IDENTITY`, `APPLE_ID`, `APPLE_APP_SPECIFIC_PASSWORD`, `APPLE_TEAM_ID`
4. Tag a release: `git tag v0.1.0 && git push origin v0.1.0`

Deploy workflow uploads to the **playtest** branch ([.github/workflows/steam-deploy.yml](.github/workflows/steam-deploy.yml)).

## Save schema

Saves use versioned JSON at `user://savegame.json`. Migrations live in `SaveManager._migrate()`. Bump `CURRENT_SCHEMA_VERSION` when changing save shape.

## Crash reporting

`CrashReporter` writes rolling local logs under `user://crashes/`. Set `SENTRY_DSN` in GitHub secrets to wire external reporting later.

## Replace before shipping

| Item | Dev value | Production |
|------|-----------|------------|
| App ID | `480` (SpaceWar) | Your Steam App ID |
| Bundle ID | `com.videogame.app` | Your identifier |
| Code signing | Disabled | Enable in export_presets + CI |
