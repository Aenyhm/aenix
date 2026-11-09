# Installing a machine

The two PCs run NixOS. The Mac keeps macOS, and nix-darwin applies the part of the config it shares with them.

## SSH keys

Every build fetches `aenix-private` over SSH through the `github-aenyhm` alias, with the personal key. Restore the keys first, `chmod 600` on the private ones. A new key (`ssh-keygen -t ed25519 -f <file>`) has to be added to its GitHub account first.

| Session | Key | GitHub account | Used for |
|---|---|---|---|
| personal, and the main account of the Mac | `~/.ssh/id_ed25519` | personal, `Aenyhm` | `github.com` and the `github-aenyhm` alias |
| work | `~/.ssh/id_ed25519` | work | `github.com`, the company repositories |
| work | `~/.ssh/id_ed25519_aenyhm` | personal, `Aenyhm` | the `github-aenyhm` alias |

home-manager writes the alias into `~/.ssh/config` at the first switch, which needs it already. Until then, write it by hand with the key of the alias (`~/.ssh/id_ed25519_aenyhm` for the work session), then check that GitHub answers `Hi Aenyhm!`. Any other name means the key belongs to another account, and the fetch of `aenix-private` fails with "Repository not found":
```
printf 'Host github-aenyhm\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/id_ed25519\n  IdentitiesOnly yes\n' >> ~/.ssh/config
ssh -T git@github-aenyhm
```
`IdentitiesOnly` keeps ssh from offering another key first.

## NixOS

### Partitions and swap

The installer partitions the disk once, so the swap size and the encryption are decided here. Use Btrfs with the `home` and `nix` subvolumes. On a work machine, tick the disk encryption: the company policy requires it, and the swap is encrypted with the rest.

| RAM | Swap |
|---|---|
| 16 GB or less | the same size as the RAM |
| More than 16 GB | 8 GB |

zswap compresses the pages in RAM first, so the swap only absorbs peaks: above 16 GB of RAM, 8 GB of swap filled means a leaking application, and a killed application beats a frozen desktop. Hibernation is disabled in the configuration, since it needs a swap at least as large as the RAM and the NVIDIA driver resumes badly from it. Suspend to RAM covers the need.

### Steps

1. **Install NixOS from the ISO**, with the partitions above. The release of the ISO is unimportant: from the first switch on, the machine runs the nixpkgs of `flake.nix`.
2. **Restore the SSH keys and the alias**, see [SSH keys](#ssh-keys).
3. **Clone the repository** into `~/aenix`, where `update` and `nh` look for it. The fresh system has no git: open `nix-shell -p git` and stay in it until the first switch of step 7, which runs git too.
   ```
   git clone git@github-aenyhm:Aenyhm/aenix ~/aenix
   ```
4. **Generate the hardware config.** Copy the output of `nixos-generate-config --show-hardware-config` into `modules/hosts/<host>/hardware.nix`, inside the `flake.modules.nixos.<host>-hardware` module. Keep the nixos-hardware imports already in the file. With encryption ticked, the installer unlocks the swap from `/etc/nixos/configuration.nix`, not from the hardware config: copy its `boot.initrd.luks.devices` line too, or every boot waits 90 s for the swap.
5. **Check `system.stateVersion`** in `modules/hosts/<host>/default.nix`: the nixpkgs release of `flake.nix` at this first install, never changed afterwards (see [Upgrade NixOS](how-to.md#upgrade-nixos)).
6. **Place the secrets**, kept out of the repository. On a work machine, those of the work module, see the README of `Aenyhm/aenix-private`. On every host, the NAS account that reads the music share, mounted for every user:
   ```
   sudo install -m 600 /dev/stdin /etc/nas-credentials   # type the two lines below, then Ctrl+D
   username=<NAS user>
   password=<NAS password>
   ```
7. **Build and switch.** A flake only sees files tracked by git, so add new files first. The fresh system has flakes disabled, `NIX_CONFIG` enables them for this first build. An older ISO names `--sudo` `--use-remote-sudo`:
   ```
   export NIX_CONFIG="experimental-features = nix-command flakes"
   git add -A
   nixos-rebuild switch --flake .#<hostname> --sudo
   ```
   The configuration is named after the `networking.hostName` of the host. Only this first switch names it, since the installer called the machine `nixos`. From then on, `nh os switch` finds it from the hostname.
8. **Set a password for each user**, created without one: `sudo passwd <user>`.

### After the first login

Each user finishes its own session, since these settings live in the home directory or on remote services.

| Task | How |
|---|---|
| GitHub access for git | `gh auth login` |
| Syncthing | pair with the other devices from `127.0.0.1:8384`, or the port the host sets for a second session. Each user runs its own Syncthing: share with it only the folders it needs |
| Login screen | give it the display settings of the session, see [Change a KDE setting](how-to.md#change-a-kde-setting) |
| Crow Translate | pick a working translation instance, see [When something fails](how-to.md#when-something-fails) |

The work session needs more:

| Task | How |
|---|---|
| Work files | the `work` Syncthing folder at `~/sync/work`, see [Sync the work files](how-to.md#sync-the-work-files). The first switch renamed an existing `~/.claude` to `~/.claude.backup`: move its config into `~/sync/work/claude-config` |
| `.env` files of the repositories | after each clone, link the file kept in `~/sync/work/env/`: `ln -s ~/sync/work/env/<file> ~/github/<repo>/<name>` |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash`. The official installer keeps it up to date in `~/.local/bin` |
| Tools of a repository outside Nix | the install script its README gives |

## The Mac

`aenyhm-mac` keeps macOS. nix-darwin installs the apps through Homebrew: the shared ones in `/Applications` for both accounts, the others in `~/Applications` for the main account only. home-manager writes the config of that account only.

1. **Install Nix.** First add Terminal under System Settings > Privacy & Security > Full Disk Access: the installer changes the owner of every file on the Nix volume, which macOS refuses otherwise (`chown: /nix/.Trashes: Operation not permitted`). Then run, and open a new terminal once it is done:
   ```
   curl -L https://nixos.org/nix/install | sh
   ```
2. **Install Homebrew**, which nix-darwin drives but does not install. It brings the Xcode command line tools, and with them git:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. **Restore the SSH key and the alias**, see [SSH keys](#ssh-keys). A key protected by a passphrase goes into the macOS keychain, since Nix runs git without a terminal to ask it: `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`.
4. **Clone the repository**: `git clone git@github-aenyhm:Aenyhm/aenix ~/aenix`.
5. **Uninstall the apps installed by hand** among the casks of `modules/hosts/mac/default.nix`, by dragging them from `/Applications` to the Bin. Homebrew refuses to overwrite an app it did not install, and the activation stops. Their settings, kept in `~/Library`, stay in place.
6. **Build as the user, then activate as root.** If the activation stops on a file of `/etc` that the Nix installer wrote, rename it with the `.before-nix-darwin` suffix it names and run it again:
   ```
   export NIX_CONFIG="experimental-features = nix-command flakes"
   nix build ~/aenix#darwinConfigurations.aenyhm-mac.system
   sudo ./result/activate
   ```
   Open a new terminal: from then on, `nh darwin switch` finds `~/aenix` through `NH_FLAKE`.
7. **Take the bash of Nix as login shell**, for Terminal and Ghostty: `chsh -s /run/current-system/sw/bin/bash`, then log out and back in.
8. **Log in to GitHub** for git: `gh auth login`. home-manager installs gh with git.
9. **Pair Syncthing** with the other devices from `127.0.0.1:8384`.
