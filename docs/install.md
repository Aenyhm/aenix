# Installing a machine

## Partitions and swap

The installer partitions the disk once, so the swap size and the encryption are decided here. Use Btrfs with the `home` and `nix` subvolumes. On `work`, tick the disk encryption: the company policy requires it, and the swap is encrypted with the rest.

| RAM | Swap |
|---|---|
| 16 GB or less | the same size as the RAM |
| More than 16 GB | 8 GB |

zswap compresses the pages in RAM first, so the swap only absorbs peaks: above 16 GB of RAM, 8 GB of swap filled means a leaking application, and a killed application beats a frozen desktop. Hibernation is disabled in the configuration, since it needs a swap at least as large as the RAM and the NVIDIA driver of `home` resumes badly from it. Suspend to RAM covers the need.

## Steps

1. **Install NixOS from the ISO**, with the partitions above. The release of the ISO is unimportant: from the first switch on, the machine runs the nixpkgs of `flake.nix`.
2. **Restore the SSH keys**, `chmod 600` on the private ones. A new one (`ssh-keygen -t ed25519 -f <file>`) has to be added to its GitHub account first.

   | Key | GitHub account | Used for |
   |---|---|---|
   | `~/.ssh/id_ed25519` | work, `fnouaillat` | `github.com`, the company repositories. `fnouaillat` only |
   | `~/.ssh/id_ed25519_aenyhm` | personal, `Aenyhm` | the `github-aenyhm` alias: this repository and `aenix-private`, which every build fetches |

   home-manager writes the alias into `~/.ssh/config` at the first switch, which needs it already. Until then, write it by hand:
   ```
   printf 'Host github-aenyhm\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/id_ed25519_aenyhm\n  IdentitiesOnly yes\n' > ~/.ssh/config
   ```
   `IdentitiesOnly` keeps ssh from offering the work key first, which would log in as `fnouaillat`. `ssh -T git@github-aenyhm` answers `Hi Aenyhm!` once it works.
3. **Clone the repository** into `~/aenix`, where `update` and `nh` look for it. The fresh system has no git: open `nix-shell -p git` and stay in it until the first switch of step 7, which runs git too.
   ```
   git clone git@github-aenyhm:Aenyhm/aenix ~/aenix
   ```
4. **Generate the hardware config.** Copy the output of `nixos-generate-config --show-hardware-config` into `modules/hosts/<host>/hardware.nix`, inside the `flake.modules.nixos.<host>-hardware` module. On `work`, keep the nixos-hardware imports already there. With encryption ticked, the installer unlocks the swap from `/etc/nixos/configuration.nix`, not from the hardware config: copy its `boot.initrd.luks.devices` line too, or every boot waits 90 s for the swap.
5. **Check `system.stateVersion`** in `modules/hosts/<host>/default.nix`: the nixpkgs release of `flake.nix` at this first install, never changed afterwards (see [Upgrade NixOS](how-to.md#upgrade-nixos)).
6. **Place the secrets**, kept out of the repository. On `work`, those of the `company` module, see the README of `Aenyhm/aenix-private`. On both hosts, the DSM account that reads the `music` share of the NAS, mounted at `/mnt/aenas2` and linked as `~/Musique/aenas2` for every user:
   ```
   sudo install -m 600 /dev/stdin /etc/nas-credentials   # type the two lines below, then Ctrl+D
   username=aenyhm
   password=<DSM password>
   ```
7. **Build and switch.** A flake only sees files tracked by git, so add new files first. The fresh system has flakes disabled, `NIX_CONFIG` enables them for this first build. An older ISO names `--sudo` `--use-remote-sudo`:
   ```
   export NIX_CONFIG="experimental-features = nix-command flakes"
   git add -A
   nixos-rebuild switch --flake .#<hostname> --sudo
   ```
   The configuration is named after the `networking.hostName` of the host (`aenyhm-home-linux`, `fnouaillat-work`). Only this first switch names it, since the installer called the machine `nixos`. From then on, `nh os switch` finds it from the hostname.
8. **Set a password for each user**, created without one: `sudo passwd <user>`.

## After the first login

Each user finishes its own session, since these settings live in the home directory or on remote services.

| Task | How |
|---|---|
| GitHub access for git | `gh auth login` |
| Syncthing | pair with the other devices from `127.0.0.1:8384`, or `127.0.0.1:8385` for `fnouaillat` on `home`. Each user runs its own Syncthing: share with it only the folders it needs |
| Login screen | give it the display settings of the session, see [Change a KDE setting](how-to.md#change-a-kde-setting) |
| Crow Translate | pick a working translation instance, see [When something fails](how-to.md#when-something-fails) |

The work session (`fnouaillat`, on both hosts) needs more:

| Task | How |
|---|---|
| Work files | the `work` Syncthing folder at `~/sync/work`, see [Sync the work files](how-to.md#sync-the-work-files). The first switch renamed an existing `~/.claude` to `~/.claude.backup`: move its `CLAUDE.md`, `settings.json` and `skills/` into `~/sync/work/claude-config` |
| `.env` files of the repositories | after each clone, link the file kept in `~/sync/work/env/`: `ln -s ~/sync/work/env/esgc-dbs-and-apis.env ~/github/esgc-dbs-and-apis/.env`, `ln -s ~/sync/work/env/esgc-front.env.local ~/github/esgc-front/.env.local` |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash`. The official installer keeps it up to date in `~/.local/bin` |
| vite-plus | its install script, from the esgc-front README. It provides Node.js, `vp` and `vpr` |
