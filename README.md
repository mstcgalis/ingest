# ingest

Copy photos from an SD card or camera to a date-organised folder structure, skip duplicates, and optionally clean up the card and eject it when done.

```
~/Pictures/
  2026/
    2026-05-01_DigimaxA6/
      STA60029.JPG
    2026-05-02_Canon-EOS-R5/
      IMG_0042.JPG
      RAW/
        IMG_0042.CR3
```

## Install

```sh
brew install mstcgalis/tap/ingest
```

Requires [exiftool](https://exiftool.org) (`brew install exiftool`).

## Usage

Plug in your camera or SD card and run:

```sh
ingest
```

ingest auto-detects the volume (it must contain a `DCIM/` folder). Pass a path explicitly if auto-detection picks the wrong one:

```sh
ingest /Volumes/CANON
```

### Options

| Flag | Description |
|------|-------------|
| `-d PATH` | Destination root (default: `~/Photos`, or `DEST_ROOT` in config) |
| `-n` | Dry run — show what would happen, copy nothing |
| `-e` | Eject the volume after a clean ingest |
| `-x` | Delete files from the source after copying |
| `-u` | Upload to Immich after copying |
| `-h` | Show help |

### Duplicate detection

Every imported file is hashed (SHA-256) and recorded in `~/.local/share/ingest/imported.sha256`. Re-running ingest on the same card skips files already in the database — by filename collision or content hash — so it is safe to run multiple times.

## Configuration

Copy the example config and edit it:

```sh
mkdir -p ~/.config/ingest
cp "$(brew --prefix)/share/ingest/config.example" ~/.config/ingest/config
```

`~/.config/ingest/config` (all keys optional):

```sh
# Where to put imported photos
DEST_ROOT="$HOME/Photos"

# Subfolder for RAW files within each date+camera dir
RAW_SUBDIR="RAW"

# Separator between date and camera name in directory name
CAMERA_SEPARATOR="_"          # e.g. 2026-05-01_Canon-EOS-R5

# Extensions to silently skip (space-separated, case-insensitive)
SKIP_EXTENSIONS="THM LRV"

# Delete source files from the card after a successful copy
DELETE_FROM_SOURCE=false

# Eject the card after a clean ingest (no failures)
EJECT_AFTER=false

# Immich — upload after copying
IMMICH_UPLOAD=false
IMMICH_SERVER="http://YOUR_IMMICH_HOST:2283"
IMMICH_API_KEY="your-api-key-here"
IMMICH_ALBUM=""               # leave empty to skip album assignment

# Log and hash-database location
LOG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ingest"
```

## Output structure

```
$DEST_ROOT/
  YYYY/
    YYYY-MM-DD_Camera-Model/
      photo.jpg
      RAW/
        photo.CR3
```

Dates come from EXIF (`DateTimeOriginal`), falling back to the file's modification time. Camera names come from the EXIF `Model` tag; files with no model tag go into a `…_unknown` folder.

## Logs

Each run writes a log to `~/.local/share/ingest/ingest_YYYYMMDD_HHMMSS.log`.

## License

MIT
