# BATTLE COWS — 3D Asset Replacement Guide

This document specifies how to supply or replace 3D GLB/glTF assets, textures, and sound files for **Battle Cows**.

---

## 1. Directory Structure

All 3D models should be placed in `assets/models/` and referenced through `lib/assets/asset_registry.dart`.

```text
assets/
  models/
    Cow Pawn .glb
    fence.glb
    flower.glb
    rock.glb
  images/
    Background/
      Background.jpg
      Logo.png
      Table image.jpg
      Title Text.png
    Tile Image/
      Grass Texture.jpg
      Tile Texture.png
  sounds/
    README.md
```

---

## 2. GLB Model Conventions

| Property | Requirement |
| :--- | :--- |
| **Format** | Binary glTF (`.glb`) or glTF (`.gltf` with embedded buffers) |
| **Up Vector** | `+Y` is Up |
| **Forward Vector**| `+Z` is Forward |
| **Origin / Pivot** | Base center `(0, 0, 0)` for ground-standing assets |
| **Scale Units** | 1 unit = 1 meter (Hex radius ~ 1.0 unit) |
| **Materials** | Standard PBR (`MeshStandardMaterial` / Metallic-Roughness) |
| **Polygon Budget**| 500 - 3,000 triangles per model for optimal mobile performance |

---

## 3. Specific Asset Guidelines

### Cow Models (`cow_blue.glb`, `cow_red.glb`, `cow_neutral.glb`)
* **Dimensions**: Approximately `0.7` units width, `0.7` units height.
* **Team Visuals**: Should include team colored accessories (collar, saddle, badge, or horns) rather than whole-body tinting to preserve high visual quality.
* **Optional Animations**:
  * `idle`: subtle breathing / bobbing
  * `walk` or `hop`: forward movement cycle
  * `victory`: happy bounce / spin
  * `defeat`: slight sit / look down

### Hexagon Terrain (`hex_grass.glb`, `hex_blocked.glb`)
* **Geometry**: Regular hexagon flat-topped or pointy-topped with outer radius `1.0`, height `0.25`.
* **Bevel**: Slight beveled top edges to emphasize physical tabletop board pieces.
* **Variations**: Flowers, rocks, dirt patches are spawned as child meshes or terrain variants.

### Fence Obstacle (`fence.glb`)
* **Dimensions**: Fits within a single hex tile width (~`0.8` units), height ~`0.5` units.
* **Appearance**: Stylized chunky wooden farm fence.

### Tabletop (`table.glb`)
* **Dimensions**: Large flat surface (`20.0 x 20.0` units) centered at `Y = -0.15`.
* **Material**: Warm wooden plank texture with subtle grain and ambient occlusion.

---

## 4. Fallback Architecture

If any `.glb` file is missing from `assets/models/`, the game engine automatically uses high-detail procedural 3D fallbacks generated in `lib/game/rendering/procedural_models.dart`. This ensures the game always runs and remains completely playable without external asset dependencies.
