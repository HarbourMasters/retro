# Texture replacement folders

Retro packs an OTR / O2R from a folder of images. The Replace Textures flow can extract a game archive to produce such a folder, but it will pack any folder carrying a `manifest.json`, whether Retro built it or not.

```
MyPack/
  manifest.json
  aliases.json          (optional)
  sprites/npc_sprite_128_raster_48.png
  ui/battle/hud.png
```

Images are found recursively. `.png`, `.jpeg` and `.jpg` are collected and everything else is skipped, though only a texture typed as JPEG is decoded as one. Two toggles on the staging screen change the output: Prepend `alt/` puts the textures under `alt/` so players can switch them off in game, and Compress Files shrinks the archive.

## manifest.json

Maps an archive texture path, without extension, to the original texture's format and size. The key doubles as the image's path within the folder, so `sprites/npc_sprite_128_raster_48` is `sprites/npc_sprite_128_raster_48.png` unless `aliases.json` says otherwise.

```json
{
  "sprites/npc_sprite_128_raster_48": {
    "hash": "2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae",
    "textureType": 3,
    "textureWidth": 32,
    "textureHeight": 24
  }
}
```

- `hash` is the SHA-256 of the original image. An image matching it counts as untouched and is dropped from the archive. Without the originals, use any value your images cannot produce; `""` works.
- `textureType` is the *original* format, not your replacement's. Scale factors are derived from it. Values: 1 RGBA32, 2 RGBA16, 3 CI4, 4 CI8, 5 I4, 6 I8, 7 IA4, 8 IA8, 9 IA16, 10 JPEG (backgrounds).
- `textureWidth` and `textureHeight` are the original size in texels.
- `tileWidth` and `tileHeight` are optional, for the region a game draws when it is smaller than the texture.
- `strips` is optional, see below.

A replacement that isn't the original's size is packed raw as RGBA32 with its scale recorded, except a palettized PNG over a CI original, which keeps its palette format. The renderer truncates a fractional scale, so a replacement that is not a whole multiple of the original is resampled to the nearest one and the resize is logged. Painting at a whole multiple avoids that round trip. A replacement at exactly the original size keeps the original format, except over a CI original, where only a palettized PNG can; other art goes in raw at 1x.

## aliases.json

For packs whose filenames don't match the archive's texture paths. Maps an image path relative to the folder, extension included, to one target or several. A source with no directory matches a file of that name anywhere in the folder. A leading `alt/` on a target is ignored.

```json
{
  "PAPER MARIO#5E6F7A8B#0#2#1A2B3C4D_ciByRGBA.png": "sprites/npc_sprite_128_raster_48",
  "shared/bowser_idle.png": ["sprites/npc_sprite_128_raster_3", "sprites/npc_sprite_128_raster_4"]
}
```

Targets must resolve, either to a `manifest.json` key or through a game's own additive rules. Source names can be anything.

## strips

Texture memory holds 4KB, half of it going to the palette for CI formats. A larger image reaches the hardware a few rows at a time, so an emulator dump records one image per band. The archive holds the whole texture, so the bands have to be reassembled. World Bowser's raster below is 64 texels wide in CI4, which is exactly what fits, so its first 64 rows arrive as one band and the remaining 16 as another.

```json
{
  "sprites/npc_sprite_128_raster_61": {
    "hash": "",
    "textureType": 3,
    "textureWidth": 64,
    "textureHeight": 80,
    "strips": [{ "y": 0, "rows": 64 }, { "y": 64, "rows": 16 }]
  }
}
```

Point an image at a band with `#` and its index:

```json
{
  "dump/bowser_top.png":    "sprites/npc_sprite_128_raster_61#0",
  "dump/bowser_bottom.png": "sprites/npc_sprite_128_raster_61#1"
}
```

`y` and `rows` are the texture rows a band covers. They must start at 0, run consecutively, and total `textureHeight`.

`hashY` and `hashRows` default to `y` and `rows`. They are only needed where a game's upload ran past the rows it draws, leaving the dumped image taller than the band, as Bowser's does above; Retro scales to `hashRows`, then crops back to `y` and `rows`.

An image wider than a tile is cut up sideways as well. `x` and `cols` make a band one tile of a grid. A 150x105 texture drawn in 64x32 tiles has bands `{ "x": 0, "y": 0, "cols": 64, "rows": 32 }`, `{ "x": 64, "y": 0, "cols": 64, "rows": 32 }`, `{ "x": 128, "y": 0, "cols": 22, "rows": 32 }` and so on down the image, twelve in all. A band without `cols` spans the full width.

Bands share one scale, taken from the largest supplied, so paint them at the same multiple. Mixing scales is logged and the smaller bands are enlarged to match. An unsupplied band comes out transparent; to fill it with the original artwork instead, supply it as a band image like any other.

`strips` only describes what a texture *may* be supplied as. A single image aimed at the texture itself, with no `#`, is still packed whole and ignores the band layout, so a pack that already has the full artwork does not need to cut it up.