# AeNix

Nix configuration of my machines: PCs on NixOS, with a personal and a work session, and a Mac on macOS, where nix-darwin installs the apps through Homebrew and applies the same user config as on Linux.

| Document | For |
|---|---|
| [docs/install.md](docs/install.md) | installing a machine |
| [docs/how-to.md](docs/how-to.md) | updating, changing a setting, syncing the work files, fixing failures, upgrading NixOS |

## Layout

import-tree loads every file under `modules/`. A file holds both the NixOS and home-manager parts of a feature. A host imports its features and users, and each user lists its home-manager profiles.

| Path | Holds |
|---|---|
| `modules/hosts/<host>/` | a machine: `default.nix` imports its features and users, `hardware.nix` comes from `nixos-generate-config`. `mac` holds the whole Mac |
| `modules/users/<user>.nix` | a user and the profiles they get |
| `modules/apps/` | the `apps` profile of every NixOS user. The apps the Mac shares have their own module, which `apps` imports |
| `modules/flake-parts.nix` | values shared by every module: palette, font, default browser |

Kept out of this public repository:

| Where | What |
|---|---|
| `Aenyhm/aenix-private`, a private flake input | personal values and the work module |
| `~/sync/work`, the `work` Syncthing folder | work files, linked from the home directory and the repositories |
