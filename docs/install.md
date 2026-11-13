# Installing a machine

The PCs run NixOS. The Mac keeps macOS, and nix-darwin applies the config it shares with them.

## SSH keys

Every build fetches `aenix-private` over SSH through the `github-aenyhm` alias, with the personal key. Restore the keys first, with `chmod 600` on the private ones. Add a new key (`ssh-keygen -t ed25519 -f <file>`) to its GitHub account first.

| Session | Key | GitHub account | Used for |
|---|---|---|---|
| personal, and the main account of the Mac | `~/.ssh/id_ed25519` | personal, `Aenyhm` | `github.com` and the `github-aenyhm` alias |
| work | `~/.ssh/id_ed25519` | work | `github.com`, the company repositories |
| work | `~/.ssh/id_ed25519_aenyhm` | personal, `Aenyhm` | the `github-aenyhm` alias |

home-manager writes the alias into `~/.ssh/config`, but the first switch already needs it: write it by hand, with `~/.ssh/id_ed25519_aenyhm` in the work session. GitHub must answer `Hi Aenyhm!`. Another name means the key belongs to another account, and fetching `aenix-private` fails with "Repository not found":
```
printf 'Host github-aenyhm\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/id_ed25519\n  IdentitiesOnly yes\n' >> ~/.ssh/config
ssh -T git@github-aenyhm
```
`IdentitiesOnly` stops ssh from offering another key first.

## NixOS

### Partitions and swap

Swap size and encryption can only be set at install. Use Btrfs with the `home` and `nix` subvolumes. On a work machine, tick disk encryption: the company policy requires it, and it covers the swap.

| RAM | Swap |
|---|---|
| 16 GB or less | the same size as the RAM |
| More than 16 GB | 8 GB |

Hibernation is disabled (the NVIDIA driver resumes badly), so the swap only absorbs peaks and need not match the RAM.

### Steps

1. **Install NixOS from the ISO**, with the partitions above. Any ISO release works: the first switch moves to the nixpkgs of `flake.nix`.
2. **Restore the SSH keys and the alias**, see [SSH keys](#ssh-keys).
3. **Clone the repository** into `~/aenix`, where `update` and `nh` look for it. The fresh system has no git: work in `nix-shell -p git` until the switch of step 7, which needs it too.
   ```
   git clone git@github-aenyhm:Aenyhm/aenix ~/aenix
   ```
4. **Generate the hardware config.** Copy the output of `nixos-generate-config --show-hardware-config` into the `flake.modules.nixos.<host>-hardware` module of `modules/hosts/<host>/hardware.nix`, keeping its nixos-hardware imports. With encryption, also copy the `boot.initrd.luks.devices` line of `/etc/nixos/configuration.nix`, which unlocks the swap: without it, every boot waits 90 s for the swap.
5. **Check `system.stateVersion`** in `modules/hosts/<host>/default.nix`: the nixpkgs release of `flake.nix` at install, never changed afterwards (see [Upgrade NixOS](how-to.md#upgrade-nixos)).
6. **Place the secrets**, kept out of the repository. On a work machine, those of the work module (README of `Aenyhm/aenix-private`). On every host, the NAS account of the music share:
   ```
   sudo install -m 600 /dev/stdin /etc/nas-credentials   # type the two lines below, then Ctrl+D
   username=<NAS user>
   password=<NAS password>
   ```
7. **Build and switch.** A flake only sees files tracked by git, so add new files first. `NIX_CONFIG` enables flakes, off on a fresh system. On an older ISO, `--sudo` is `--use-remote-sudo`:
   ```
   export NIX_CONFIG="experimental-features = nix-command flakes"
   git add -A
   nixos-rebuild switch --flake .#<hostname> --sudo
   ```
   `<hostname>` is the host's `networking.hostName`. Only this first switch needs it, since the installer named the machine `nixos`. After it, `nh os switch` uses the hostname.
8. **Set each user's password**: `sudo passwd <user>`.

### After the first login

Each user does these in their own session: the settings live in the home directory or on remote services.

| Task | How |
|---|---|
| GitHub access for git | `gh auth login` |
| Syncthing | pair the devices from `127.0.0.1:8384`, or the port the host sets for a second session. Each user runs their own Syncthing: share only the folders they need |
| Login screen | apply the session's display settings, see [Change a KDE setting](how-to.md#change-a-kde-setting) |
| Crow Translate | pick a working translation instance, see [When something fails](how-to.md#when-something-fails) |

The work session also needs:

| Task | How |
|---|---|
| Work files | the `work` Syncthing folder at `~/sync/work`, see [Sync the work files](how-to.md#sync-the-work-files). The first switch renamed an existing `~/.claude` to `~/.claude.backup`: move its config to `~/sync/work/claude-config` |
| `.env` files of the repositories | after each clone, link the file kept in `~/sync/work/env/`: `ln -s ~/sync/work/env/<file> ~/github/<repo>/<name>` |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash`, which installs to `~/.local/bin` and keeps it up to date |
| Tools a repository installs outside Nix | the script its README gives |

## The Mac

nix-darwin installs the apps through Homebrew: shared ones in `/Applications`, the main account's own in `~/Applications`. home-manager configures the main account only.

1. **Install Nix.** First give Terminal Full Disk Access (System Settings > Privacy & Security), or the installer fails with `chown: /nix/.Trashes: Operation not permitted`. Then run, and open a new terminal:
   ```
   curl -L https://nixos.org/nix/install | sh
   ```
2. **Install Homebrew**: nix-darwin drives it but does not install it. It brings the Xcode command line tools, git included:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. **Restore the SSH key and the alias**, see [SSH keys](#ssh-keys). Put a passphrase-protected key in the keychain, since Nix runs git without a terminal: `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`.
4. **Clone the repository**: `git clone git@github-aenyhm:Aenyhm/aenix ~/aenix`.
5. **Remove the listed apps installed by hand** (casks of `modules/hosts/mac/default.nix`): drag them from `/Applications` to the Bin. Homebrew does not overwrite an app it did not install, and the activation stops. Their settings in `~/Library` stay.
6. **Build as the user, then activate as root.** If the activation stops on an `/etc` file written by the Nix installer, add the `.before-nix-darwin` suffix it names and run it again:
   ```
   export NIX_CONFIG="experimental-features = nix-command flakes"
   nix build ~/aenix#darwinConfigurations.aenyhm-mac.system
   sudo ./result/activate
   ```
   In a new terminal, `nh darwin switch` then finds `~/aenix` through `NH_FLAKE`.
7. **Use Nix's bash as login shell**: `chsh -s /run/current-system/sw/bin/bash`, then log out and back in.
8. **Log in to GitHub**: `gh auth login`.
9. **Start the Syncthing app**, turn on its launch at login in its preferences, and pair the devices from `127.0.0.1:8384`.
