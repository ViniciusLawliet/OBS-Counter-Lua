# OBS-Counter-Lua
Simple counter script for OBS Studio with hotkeys, custom format, and crash-safe persistence.

## Features

- Increment / Decrement / Reset via hotkeys
- Custom display format (e.g. `Deaths: %d`)
- Configurable start value
- Custom step size (e.g. +2, +5, etc.)
- Optional negative values
- Crash-safe (auto-saves counter to file)
- Works with **Text (GDI+)**

## Setup

### 1. Create a Text Source in OBS
- Sources → Add → Text (GDI+)
- Rename it (example): Counter
---
### 2. Load the Script
- Tools → Scripts → + → Add/Select the .lua file
> **Note:** Check the folder where OBS stores scripts ("Add Scripts" path), then copy the `Counter.lua` file from this repository into that folder before adding it.
---
### 3. Configure Script

In the script settings:

- **Text Source Name**
  - Must match EXACTLY your GDI+ source name

- **Display Format**
  - Use `%d` where the number should appear  
  Example:
    - Counter: %d
    - Deaths: %d
    - Score: %d pts

- **Start Value**
  - Value used at startup and when resetting (default: 0)

- **Step**
  - How much the counter increases/decreases

- **Allow Negative Values**
  - If disabled, counter won't go below 0
---
### 4. Assign Hotkeys
  - Go to: Settings → Hotkeys
  - Bind keys to:
    - `Increment`
    - `Decrement`
    - `Reset`
---

## 📄 License

[MIT License](./LICENSE)

---

## 👤 Author

Vinicius Lawliet (2026)
