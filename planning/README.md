# Game Design Planner

Mobile-friendly planning app for **Expedition Protocol** design decisions.

## Open on your phone

**Option A — local file (same Wi‑Fi)**  
Serve from your PC, then open the URL on your phone:

```powershell
cd c:\Users\cskre\Projects\video-game\planning
python -m http.server 8080
```

Visit `http://<your-pc-ip>:8080` on your phone.

**Option B — open file directly**  
Copy `index.html` to your phone (AirDrop, Google Drive, etc.) and open in Safari/Chrome.

**Option C — GitHub Pages**  
Push the repo and enable Pages on the `planning/` folder if you want a permanent URL.

## What it includes

- Core design overview (B + C + D pillars, session modes)
- **Room-by-room GDD** — first biome options
- **Combat system spec** — three combat direction options
- **Hub upgrade tree** — three hub direction options
- **Mockup → scene breakdown** — mapping template + placeholder scenes
- Decision toggles, notes, progress tracking
- **Export for Cursor** — copy markdown summary to paste back into chat

Decisions auto-save in your browser (`localStorage`).
