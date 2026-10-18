# KurtumiShell

A customizable desktop shell for Linux, built with Quickshell and QML, featuring a Kuromi-inspired aesthetic.

## Features

- Custom desktop bar.
- Modular QML components and panels.
- Calendar and Pomodoro timer.
- Customizable theme and visual elements.
- Desktop hotspots.

## Preview

_Screenshots coming soon._

## Requirements

- Linux with a Wayland compositor.
- [Quickshell](https://quickshell.org/).
- A compatible environment for the shell's window management and desktop integrations.

Additional dependencies will be documented once verified.

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/QuanticDemon/KurtumiShell.git
cd KurtumiShell
```

### 2. Install dependencies

Install Quickshell and any additional dependencies required by the components you intend to use. The exact package names depend on your Linux distribution.

### 3. Run the shell

```bash
qs -p shell.qml
```

If your Quickshell installation uses a different command or requires additional configuration, adjust this step accordingly.

## Project Structure

```text
KurtumiShell/
├── Themes/
├── assets/
├── components/
├── hotspots/
├── panels/
├── services/
└── shell.qml
```

- `Themes/` — Theme definitions and visual styling.
- `assets/` — Images and other visual resources.
- `components/` — Reusable UI components.
- `hotspots/` — Interactive desktop areas.
- `panels/` — Desktop panels and popups.
- `services/` — Shared services and system integrations.
- `shell.qml` — Main shell entry point.

## Customization

Explore the `Themes/` directory to find the theme definitions and adjust the appearance to your preferences.

## Contributing

Issues and suggestions are welcome. Feel free to open an issue or submit a pull request.

