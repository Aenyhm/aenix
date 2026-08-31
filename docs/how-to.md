# How-to

## Update the machine

nh and `nixos-rebuild --sudo` build as your user, whose SSH key fetches the private repository, then activate as root.

| Task | Command |
|---|---|
| Apply a config change | `nh os switch`, which lists the package changes before activating |
| Update everything | `update`: flake inputs, system, then firmware and BIOS. Commit the new `flake.lock` afterwards |
| Try a change without keeping it at boot | `nh os test` |
| Undo a broken update | pick the previous generation in the GRUB menu, or `nixos-rebuild switch --rollback --sudo`, then `git checkout flake.lock` |
| Format the Nix files | `treefmt` |

## Find where a value lives

The README maps each directory. What the tree does not tell:

| Value | Where |
|---|---|
| Emails, name of the work session on the login screen, what only `work` runs | `Aenyhm/aenix-private`, then `nix flake update private` |
| `.desktop` names, for the launchers and the default applications | `ls /run/current-system/sw/share/applications ~/.nix-profile/share/applications` |
| Packages taken from unstable, with the condition to return to stable | `grep -rn TODO modules` |

## Change a KDE setting

A setting declared in `modules/system/desktop.nix` is written back at each rebuild, the others stay as set from the KDE interface. Try a setting by hand first, declare it to keep it across reinstalls. `nix run github:nix-community/plasma-manager` prints the current KDE settings in Nix, ready to copy into `programs.plasma.configFile`.

The login screen runs its own KWin, on the monitor's preferred mode, and the monitor goes black at login while it switches to the mode of the session. After the first login and after each change of the display settings, give the login screen the session's ones: System Settings, Colours & Themes, Login Screen (SDDM), "Apply Plasma Settings". The copy lands in `/var/lib/sddm/.config` and survives rebuilds.

The panel is rebuilt from scratch each time its declaration changes. The wallpaper chosen in KDE lives in the same file as the panel, so two startup scripts of `desktop.nix` save it at each login and set it again when the rebuild lost it.

## Sync the work files

The work files go from device to device through Syncthing, so nothing of the company reaches GitHub. One `work` folder on the NAS is shared with the work laptop and with the `fnouaillat` session of `home`, at `~/sync/work`.

| Inside `~/sync/work` | Content |
|---|---|
| `notes/` | work notes |
| `scripts/` | `bastion-start`, `bastion-stop`, `config_set.sh`, `runtests.sh`, and `aliases.sh`, loaded by the bash of the `fnouaillat` profile, which also puts the folder in the PATH |
| `claude-config/` | `CLAUDE.md`, `settings.json`, `skills/`. The `fnouaillat` profile links `~/.claude` to it |
| `env/` | the `.env` files of the repositories and the AWS SSO profiles, linked from the repositories and `~/.aws/config` |

Claude Code also keeps its history, sessions and cache in `~/.claude`, and those belong to each machine, like the open panes of Obsidian. The ignore rules that keep them there are in `.stglobalignore`, a synced file at the root of the folder. Syncthing never transfers a `.stignore`, so on each device, **before** adding the folder, create `~/sync/work/.stignore` holding the single line `#include .stglobalignore`. On the NAS, the Exclusions tab of the interface holds that line.

The link goes from `~/.claude` to the synced folder and not the other way round: Syncthing copies a link as a link, without what it points to.

## When something fails

| Symptom | Fix |
|---|---|
| A binary built for another distribution fails with "No such file or directory" although it exists | it looks for the loader and libraries at the standard Linux paths, which nix-ld answers in `modules/system/base.nix`. A library still missing goes into `programs.nix-ld.libraries` |
| A script starting with `#!/bin/bash` or calling `/usr/bin/<tool>` fails | envfs serves those paths from the PATH, so the tool is missing from it: install it |
| GitHub refuses a clone or a push as the wrong user | the account comes from the key: company repositories go through `github.com`, personal ones through the `github-aenyhm` alias (`modules/apps/ssh.nix`), so set the remote to `git@github-aenyhm:Aenyhm/<repo>` |
| The Syncthing tray shows nothing | configure it from its GUI, then `rm ~/.config/syncthingtray.ini` and `systemctl --user restart syncthingtray` |

## Upgrade NixOS

A NixOS release comes out every six months. Two version numbers are involved, and only one of them moves.

| Value | Where | Meaning | When it changes |
|---|---|---|---|
| nixpkgs release | `flake.nix`, the `nixpkgs` and `home-manager` URLs | the software every host runs | at each upgrade, the two URLs together, since flake inputs accept literal strings only |
| `system.stateVersion` | `modules/hosts/<host>/default.nix` | the release whose defaults created the data of this host: data paths, database formats | never |

To upgrade, change the release in both URLs, run `update`, then return to stable the unstable packages whose `TODO` condition is met.

`stateVersion` is per host, so two hosts installed under different releases run the same nixpkgs from the same flake. Raising it on an installed host switches its services to the defaults of the newer release, and the data created under the old defaults is no longer found where the service looks. home-manager reads the same value for the per-user state.
