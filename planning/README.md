# Game Design Planner

Mobile-friendly planning app for **Expedition Protocol** design decisions.

## Open on your phone (public URL)

**Live app:** https://cskremers.github.io/video-game/index.html

New tabs: **Art** (concept images), **Lore** (storyline options), **Theme** (mission-connecting spines). Every comment box auto-saves and appears in Export.

Works on any network. Decisions save in your browser. Use **Export → Copy summary** to paste back into Cursor.

Redeploys automatically when `planning/` changes on `main`.

## Open locally (optional)

```powershell
cd c:\Users\cskre\Projects\video-game\planning
python -m http.server 8080
```

Visit `http://localhost:8080` on your PC only.

## What it includes

- Core design overview (B + C + D pillars, session modes)
- **Room-by-room GDD** — first biome options
- **Combat system spec** — three combat direction options
- **Hub upgrade tree** — three hub direction options
- **Mockup → scene breakdown** — mapping template + placeholder scenes
- Decision toggles, notes, progress tracking
- **Export for Cursor** — copy markdown summary to paste back into chat

Decisions auto-save in your browser (`localStorage`).
