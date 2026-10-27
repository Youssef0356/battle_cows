# Battle Cows — itch.io Store Listing Pack

Ready-to-paste data for the itch.io project page. Copy each field into the matching
section of the itch.io "Edit game" page. The **Full description** at the bottom is also
provided as HTML for itch.io's description editor.

---

## 1. Build / Upload File

| Field | Value |
|---|---|
| File | `build/app/outputs/flutter-apk/app-release.apk` |
| Size | 75.35 MB |
| SHA-256 | `A34616ACC0D7A9C966FB8677E71A0E0FBBD280EBAAC50D89D6D1A41D09B11499` |
| Version name | `1.0.1` |
| Version code | `6` |
| Package ID | `com.the356company.battlecows` |
| Signing | Release keystore — `CN=Battle Cows, O=BattleCows` (signed, verified) |
| Min Android | 7.0 (API 24) |
| Target Android | 16 / API 36 |

**Download channel suggestion:** `android`

---

## 2. Page Identity

**Title:** `Battle Cows`

**Project URL (suggested):** `battle-cows`

**Short description / tagline (one line):**

> A playful turn-based hex-grid strategy game — build the pasture, split your herd, and out-graze your rivals for every tile.

**Alternative taglines:**

- Herd vs herd on a hex battlefield. Grab ground, overrun rivals, rule the pasture.
- Turn-based hex warfare with cows. Split your herd, march the lanes, hold the most ground.

---

## 3. Metadata / Classification

| Field | Value |
|---|---|
| Project type | Game |
| Kind of project | Downloadable (also works as HTML if you later export a web build) |
| Release status | Released |
| Genre | Strategy |
| Platforms | Android |
| Pricing | Free — *or* "Name your own price" if you want optional support (see note in §6) |
| Multiplayer | Local (same device), 2 players |

**Tags (exactly 10 — itch.io's maximum; do NOT repeat the genre "strategy" or platform "android"):**

`turn-based-strategy`, `hex`, `local-multiplayer`, `2-player`, `tactical`, `cartoon`, `cute`, `animals`, `farming`, `offline`

**AI / Content disclosure:** ⚠️ **Recommended: "Yes — contains the output of Generative AI."** The repo ships
`docs/gemini_art_prompts.md`; if those prompts produced any shipped asset, itch.io requires the Yes
disclosure even when hand-edited. Confirm this yourself before posting.

---

## 4. Features (bullet list for the page)

- **True hex warfare** — a hexagonal pasture that grows as you play, not a square grid.
- **Split-and-march tactics** — a herd's reach equals the number of cows you send: send 6, cross 6 hexes. The rest stay behind to hold ground.
- **Play vs AI** on Easy, Medium or Hard — the AI plays by the exact same rules, it just picks better moves.
- **Local multiplayer** — two players, one device, pass-and-play.
- **Three match types** — Standard Pasture, Timed Strategy (60 s turns, 3 hearts) and Fence Battle (place and move fences to trap enemy herds).
- **Adjustable battlefield** — Small, Medium and Large pastures change both board size and hex scale.
- **Progression that rewards play** — earn coins, complete daily quests, and unlock cow skins, hats, board themes and tile styles.
- **Six collectible cow skins** — Cowboy, Viking, Farmer, Disco and more shop cosmetics.
- **No account, no tracking** — progress is stored locally on your device.
- **Play offline** — no internet connection required to play.

---

## 5. Controls / How to Play

**Everything is tap and drag — no on-screen thumbstick.**

1. **Build the pasture** — players take turns adding 4-hex diamond tiles: tap **Rotate**, drag the tile onto a free spot touching the pasture, then tap **Place**.
2. **Place your herd** — with the last tile down, tap a highlighted edge hex to drop a herd of 16 cows.
3. **Move** — tap a hex holding 2+ of your cows. Reachable hexes light up. Use the *Move Cows* slider to choose how many march out (at least 1 stays), then tap a glowing hex. Cows walk straight hex lines; enemy herds and fences block the lane.
4. **Win** — the match ends when no legal move remains. Most hexes wins; ties go to the biggest connected group.

---

## 6. Important notes before you publish

- **In-app purchase / ads on itch.io:** the build includes Google AdMob and Google Play Billing (the "Remove Ads" purchase). AdMob can serve ads on any Android device with Play Services, but the **Remove Ads purchase will not work** for players who sideload the APK outside Google Play. Either (a) note this on the page, (b) ship a Play-free build, or (c) drop the IAP wording from the listing.
- **Pricing:** if you set the page to **Free**, the Shop/Premium buttons still show. If you set **Name your own price**, itch.io handles payment and you keep the "download" framing.
- The game launches in immersive fullscreen (no system bars) and supports portrait and landscape.

---

## 7. Plain-text description

```
Battle Cows is a playful turn-based strategy game fought on a hexagonal pasture.

BUILD THE FIELD
Players take turns laying down chunky 4-hex tiles, rotating and placing them to grow
the battlefield. When the last tile drops, each player picks an edge tile and plants a
herd of 16 cows. Then the grazing war begins.

SPLIT, MARCH, CLAIM
Tap a hex with 2 or more of your cows to pick a herd. Drag the slider to choose how
many march out — at least one always stays to hold the ground. Herds move in straight
hex lines and reach exactly as far as the number of cows you sent, so a 6-cow party
crosses 6 hexes. Land on an enemy herd and you overrun it. Every hex you hold scores
when the round locks up, and the biggest connected block breaks any tie.

THREE WAYS TO PLAY
- Standard Pasture — classic territory war, no clock.
- Timed Strategy — 60 seconds a turn and 3 hearts. Run out of time and you lose a
  heart while a random herd scrambles.
- Fence Battle — each side owns 3 fences. Drop or move one to block a lane and trap
  an enemy herd, but it costs your whole turn.

PLAY YOUR WAY
Face the AI on Easy, Medium or Hard — it follows the same rules you do, it just hits
better moves. Or grab a friend for local pass-and-play multiplayer on one device.
Pick a Small, Medium or Large pasture to change both the board size and the hex scale.

EARN AND COLLECT
Win matches to bank coins, finish daily quests for bonus rewards, and spend it all in
the shop on cow skins, hats, board themes and tile styles.

No account and no tracking required — your progress is saved right on your device,
and the whole game plays offline.

Claim the pasture. Battle Cows.
```

---

## 8. HTML description (for itch.io's rich editor)

```html
<h2>Battle Cows is a playful turn-based strategy game fought on a hexagonal pasture.</h2>

<h3>Build the field</h3>
<p>Players take turns laying down chunky 4-hex tiles, rotating and placing them to grow the battlefield. When the last tile drops, each player picks an edge tile and plants a herd of 16 cows. Then the grazing war begins.</p>

<h3>Split, march, claim</h3>
<p>Tap a hex with 2 or more of your cows to pick a herd. Drag the slider to choose how many march out &mdash; at least one always stays to hold the ground. Herds move in straight hex lines and reach exactly as far as the number of cows you sent, so a 6-cow party crosses 6 hexes. Land on an enemy herd and you overrun it. Every hex you hold scores when the round locks up, and the biggest connected block breaks any tie.</p>

<h3>Three ways to play</h3>
<ul>
  <li><strong>Standard Pasture</strong> &mdash; classic territory war, no clock.</li>
  <li><strong>Timed Strategy</strong> &mdash; 60 seconds a turn and 3 hearts. Run out of time and you lose a heart while a random herd scrambles.</li>
  <li><strong>Fence Battle</strong> &mdash; each side owns 3 fences. Drop or move one to block a lane and trap an enemy herd, but it costs your whole turn.</li>
</ul>

<h3>Play your way</h3>
<p>Face the AI on Easy, Medium or Hard &mdash; it follows the same rules you do, it just hits better moves. Or grab a friend for local pass-and-play multiplayer on one device. Pick a Small, Medium or Large pasture to change both the board size and the hex scale.</p>

<h3>Earn and collect</h3>
<p>Win matches to bank coins, finish daily quests for bonus rewards, and spend it all in the shop on cow skins, hats, board themes and tile styles.</p>

<h3>Play offline</h3>
<p>No account and no tracking required &mdash; your progress is saved right on your device, and the whole game plays offline.</p>

<p><strong>Claim the pasture. Battle Cows.</strong></p>
```

---

## 9. Assets you still need to supply

itch.io requires images that this task did not generate. Prepare these in an image editor:

| Asset | Size | Notes |
|---|---|---|
| Cover image | 630 × 500 | Shown on the game page and in browse grids. Use the logo + a cow + a hex board. |
| Screenshots | Any (16:9 or 9:16) | At least 3–4: title screen, tile-placement, mid-match board, shop, challenge picker. |
| Banner (optional) | 1200 × 400 | For embeds/social. |

Suggested source files already in the repo: `assets/images/Background/Logo.png`,
`assets/images/Background/`, and the cows in `assets/images/Cows/`.

---

## 10. Credits / Contact

- **Developer:** Battle Cows (The 356 Company)
- **Contact:** nejiyoussef081@gmail.com
- **Privacy policy:** https://<your-domain>/privacy_policy.html (`docs/privacy_policy.html` in this repo)

---

## 11. "Create a new project" form — field by field

Enter these in the order they appear on the itch.io form.

| Form field | Value |
|---|---|
| Title | `Battle Cows` |
| Project URL | `battle-cows` (fallback `battle-cows-game`) |
| Short description or tagline | `A playful turn-based hex-grid strategy game — build the pasture, split your herd, and out-graze your rivals for every tile.` |
| Classification | **Games** |
| Kind of project | **Downloadable** |
| Release status | **Released** |
| Pricing | `0.00€ or donate` with Suggested donation `2.00€` *(recommended)* — or `No payments` for a plain free download |
| Uploads | Drag in `app-release.apk` (75.35 MB) — or butler: `butler push build/app/outputs/flutter-apk/app-release.apk YOURUSERNAME/battle-cows:android` |
| Description | Paste the HTML from §8 |
| Genre | **Strategy** |
| Tags | The 10 tags in §3 |
| AI generation disclosure | **Yes** (see §3) — confirm first |
| App store links | Only fill Google Play if the game is actually listed there; otherwise leave blank |
| Custom noun | Leave blank (defaults to "game") |
| Community | `Disabled` *(recommended)* or `Comments` |
| Visibility & access | Start at **Draft**, review, then switch to **Public** |
| Cover image | Required — 630 × 500 px (min 315 × 250) |
| Gameplay video / trailer | Leave blank unless you have a YouTube/Vimeo link |
| Screenshots | 3–5 uploads: title screen, tile placement, mid-match board, shop, challenge picker |
