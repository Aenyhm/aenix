# How-to

## Update the machine

nh and `nixos-rebuild --sudo` build as your user, whose SSH key fetches the private repository, and activate as root.

| Task | Command |
|---|---|
| Apply a config change | `nh os switch`, which lists the package changes first. On the Mac, `nh darwin switch`, which also upgrades the Homebrew apps and uninstalls those not in `homebrew.casks`: add apps there, not with `brew install` |
| Update everything | `update`: flake inputs, system, then firmware and BIOS. Commit the new `flake.lock` |
| Try a change until the next boot | `nh os test` |
| Undo a broken update | boot the previous generation from GRUB, or `nixos-rebuild switch --rollback --sudo`, then `git checkout flake.lock` |
| Format the Nix files | `treefmt` |

## Find where a value lives

The README maps the directories. Beyond that:

| Value | Where |
|---|---|
| Private values and what only the work host runs | `Aenyhm/aenix-private`, then `nix flake update private` |
| `.desktop` names, for the launchers and the default applications | `ls /run/current-system/sw/share/applications ~/.nix-profile/share/applications` |
| Packages from unstable, and when to move them back to stable | `grep -rn TODO modules` |

## Change a KDE setting

Each rebuild rewrites the settings declared in `modules/system/kde.nix`; the others keep what the KDE interface set. Try a setting by hand, then declare it to keep it across reinstalls. `nix run github:nix-community/plasma-manager` prints the current KDE settings as Nix, ready for `programs.plasma.configFile`.

The login screen runs its own KWin in the monitor's preferred mode, so the screen goes black at login while switching to the session's mode. After the first login and each display change, copy the session's settings to it: System Settings > Colours & Themes > Login Screen (SDDM) > "Apply Plasma Settings". The copy is stored in `/var/lib/sddm/.config` and survives rebuilds.

A change to the panel's declaration rebuilds it from scratch, and erases the wallpaper stored in the same file. Two startup scripts in `kde.nix` save the wallpaper at each login and restore it.

## Sync the work files

Work files move between devices through Syncthing, so nothing of the company reaches GitHub. A `work` folder on the NAS is shared with the work session of each host, at `~/sync/work`.

| Inside `~/sync/work` | Content |
|---|---|
| `notes/` | work notes |
| `scripts/` | scripts and aliases, in the PATH and loaded by bash in the work profile |
| `claude-config/` | the Claude Code config. The work profile links `~/.claude` to it |
| `env/` | the AWS SSO profiles (`aws-config`). Secrets stay in each machine's keyring, read by `secretspec` |

Claude Code also keeps its history, sessions and cache in `~/.claude`, which stay on each machine. The synced file `.stglobalignore` excludes them. Syncthing never syncs a `.stignore`, so on each device, **before** adding the folder, create `~/sync/work/.stignore` with the single line `#include .stglobalignore`. On the NAS, put that line in the Exclusions tab.

The link goes from `~/.claude` to the synced folder, not the reverse: Syncthing copies a link as a link, without its target.

## When something fails

| Symptom | Fix |
|---|---|
| A binary built for another distribution fails with "No such file or directory" although it exists | it expects the loader and libraries at standard Linux paths, served by nix-ld in `modules/system/base.nix`. Add a missing library to `programs.nix-ld.libraries` |
| A script starting with `#!/bin/bash` or calling `/usr/bin/<tool>` fails | envfs serves those paths from the PATH: the tool is not installed |
| GitHub refuses a clone or a push as the wrong user | the key sets the account: company repositories use `github.com`, personal ones the `github-aenyhm` alias (`modules/apps/ssh.nix`). Set the remote to `git@github-aenyhm:Aenyhm/<repo>` |
| Crow Translate gives an instance error (HTTP 429) | the Mozhi instance relaying to Google is rate limited: Paramètres > Mozhi > URL > Détecter plus rapidement picks a working one |
| The Syncthing tray shows nothing | configure it from its GUI, then `rm ~/.config/syncthingtray.ini` and `systemctl --user restart syncthingtray` |

## Upgrade NixOS

NixOS releases every six months. Two versions are involved, and only one moves.

| Value | Where | Meaning | When it changes |
|---|---|---|---|
| nixpkgs release | `flake.nix`, the `nixpkgs` and `home-manager` URLs | the software every host runs | at each upgrade, both URLs, since flake inputs only take literal strings |
| `system.stateVersion` | `modules/hosts/<host>/default.nix` | the release whose defaults created the host's data: paths, database formats | never |

To upgrade, change the release in both URLs, run `update`, then move back to stable the unstable packages whose `TODO` condition is met.

Raising `stateVersion` on an installed host switches its services to newer defaults, and they no longer find their data.
