# GodotSteam GDExtension

Install GodotSteam from the Godot Asset Library (recommended):

1. Open this project in **Godot 4.3+**
2. **AssetLib** tab → search **GodotSteam GDExtension**
3. Download **GodotSteam GDExtension 4.4+** by Gramps (v4.19.1+)
4. Install into `res://addons/godotsteam/`

Or run the setup script from the project root:

```powershell
.\scripts\install_godotsteam.ps1
```

## After install

Expected layout:

```
addons/godotsteam/
├── godotsteam.gdextension
├── win64/
├── linux64/   (optional)
└── osx/       (required for macOS exports)
```

## Steam App ID

- Development uses SpaceWar app ID **480** via [`steam_appid.txt`](../../steam_appid.txt)
- Replace with your real Steam App ID before shipping (Project → Export → environment or `steam_appid.txt` during dev only)

## Verify

1. Launch Steam client and log in
2. Run the game from Godot editor
3. Main menu should show **Steam: connected (YourName)**

See [GodotSteam docs](https://godotsteam.com/) for lobby and networking tutorials.
