# AleBar 🍺

> **Own your menu bar.**
> A modern, lightweight, and powerful menu bar organizer and customizer for macOS.

![AleBar Banner](https://img.shields.io/badge/platform-macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI%20%2F%20AppKit-purple)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🌟 Overview

**AleBar** is an advanced menu bar utility for macOS designed to keep your status bar clean, organized, and styled. It gives you complete control over what is displayed and when, with intelligent condition triggers, a keyboard-driven command palette, and a custom menu bar styling engine with notch avoidance.

---

## ✨ Features

### 1. 🗂️ 3-Tier Menu Bar Organization
- **Shown**: Always visible in your primary macOS menu bar.
- **Hidden**: Tucked neatly away into the floating AleBar shelf, revealed only when you need it.
- **Always Hidden**: Kept stashed away in a secondary drawer for zero clutter, accessible via search.
- **Active Process & System Detection**: Automatically discovers running menu bar accessories (`.accessory` policy) and native macOS system controls (Battery, Wi-Fi, Bluetooth, Sound, Focus, Stage Manager, Control Center, Clock, Spotlight, Siri).
- **One-Click Activation**: Click any item in the shelf or Command Bar to focus or open its application.

### 2. 🍺 The AleBar Shelf (Floating Secondary Bar)
- **MacBook Notch Avoidance**: Floats directly beneath the notch or menu bar so items never get hidden behind camera housings.
- **Vibrant Frosted Glass**: Built with native macOS `.ultraThinMaterial`, smooth continuous rounded corners, and soft depth shadows.
- **Top Shelf Live Gauges**: Real-time battery indicator (with charging state), live CPU load %, and physical RAM usage %.
- **Hover Reveal & Auto-Hide**: Hovering cursor reveals the shelf instantly; automatically collapses when the cursor leaves or after a configurable timeout.
- **Always-Hidden Drawer**: One-click disclosure to expand deeply stashed items.

### 3. 🔍 Command Bar / Quick Search
- **Global Hotkey**: **`⌘ + ⌥ + Space`**
- **Keyboard-Driven Palette**: Spotlight/Raycast-style search across all menu bar items, active background utilities, and system settings.
- **Navigation**: Arrow keys (`↑`/`↓`) to navigate, `↵ Return` to activate or launch, `Esc` to close.

### 4. 🎨 Menu Bar Styling Engine
- **Visual Overlays**:
  - **Presets**: *Liquid Glass*, *Floating Island Pill*, *Deep Frosted Night*, *Sunset Gradient*, *Cyber Neon Accent*, and *Clean Minimalist*.
  - **Floating Pill Mode**: Detaches the menu bar from the screen edges with adjustable corner radius and horizontal insets.
  - **Color Tints & Gradients**: Custom hex colors with opacity controls.
  - **Borders & Shadows**: Customizable accent borders and soft drop shadows.
  - **Zero Click Interruption (`ignoresMouseEvents = true`)**: The styling engine floats behind native status items, preserving 100% click responsiveness on the Apple menu, status items, and clock.

### 5. ⚡ Smart Triggers Engine
- **Battery Low Trigger**: Automatically reveals battery controls when battery drops below 20%.
- **Power Connected Trigger**: Momentarily shows power status when AC charger is plugged in.
- **Network Trigger**: Automatically reveals Wi-Fi and network items upon disconnection.
- **Hover Trigger**: Hover cursor over the status icon for 0.3s to reveal hidden items without clicking.

### 6. ⚙️ Preferences & Customization
- **Icon Styles**: Signature Ale Mug (🍺), Minimal Dots (···), Cocktail Glass (🍸), Chevron (`<`/`>`), Star (`✦`), Capsule, and Diamond (`◈`).
- Multi-tab preferences window: **General**, **Menu Items**, **AleBar Shelf**, **Styling**, **Triggers**, **Hotkeys**, and **About**.

---

## ⌨️ Default Shortcuts

| Action | Shortcut |
| :--- | :--- |
| **Toggle AleBar Shelf** | `⌘ + ⌥ + B` (Command + Option + B) |
| **Command Bar (Quick Search)** | `⌘ + ⌥ + Space` (Command + Option + Space) |
| **Left-Click Menu Bar Icon** | Toggle AleBar Shelf |
| **Right-Click Menu Bar Icon** | Open Quick Actions context menu |

---

## 🚀 Installation & Usage

### Running Locally:
```bash
open AleBar.app
```

### Installing into Applications:
```bash
cp -R AleBar.app /Applications/
```

### Building from Source:
```bash
git clone https://github.com/themanoftalent/AleBar.git
cd AleBar
swift build
./create_app_bundle.sh
```

---

## 🔒 Privacy & Permissions
AleBar runs natively using AppKit status items and standard process detection. It does **not** require invasive Screen Recording permissions.

---

---

## ☕ Sponsor or Buy Me a Coffee

If you find this project helpful, consider supporting it or reaching out for collaboration:

[![Buy Me A Coffee](https://img.shields.io/badge/BUY%20ME%20A%20COFFEE-SUPPORT%20PROJECT-green?style=for-the-badge&logo=buymeacoffee)](https://buymeacoffee.com/themanoftalent) [![GitHub Sponsors](https://img.shields.io/badge/SPONSOR-GITHUB%20SPONSORS-ea4aaa?style=for-the-badge&logo=githubsponsors)](https://github.com/sponsors/themanoftalent) [![Let's Connect](https://img.shields.io/badge/LET%27S%20CONNECT-EMAIL-blue?style=for-the-badge&logo=gmail)](mailto:cs.akifcifci@gmail.com)

---

## 📄 License
MIT License. Feel free to use, modify, and contribute.
