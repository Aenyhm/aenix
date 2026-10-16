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
2. **Clone the repository** into `~/aenix`, where `update` and `nh` look for it, with an SSH key that can read `Aenyhm/aenix-private`.
3. **Generate the hardware config.** Copy the output of `nixos-generate-config --show-hardware-config` into `modules/hosts/<host>/hardware.nix`, inside the `flake.modules.nixos.<host>-hardware` module. On `work`, keep the nixos-hardware imports already there.
4. **Check `system.stateVersion`** in `modules/hosts/<host>/default.nix`: the nixpkgs release of `flake.nix` at this first install, never changed afterwards (see [Upgrade NixOS](how-to.md#upgrade-nixos)).
5. **On `work`, enable the host** by uncommenting `flake.nixosConfigurations.fnouaillat-work` in `modules/hosts/work/default.nix`.
6. **Place the secrets**, kept out of the repository. On `work`, the Vanta key shown in the "Install Vanta Agent" task of the onboarding on `app.eu.vanta.com`:
   ```
   sudo install -m 600 /dev/stdin /etc/vanta-key   # paste the key, then Ctrl+D
   ```
   On both hosts, the DSM account that reads the `music` share of the NAS, mounted at `/mnt/aenas2` and linked as `~/Musique/aenas2` for every user:
   ```
   sudo install -m 600 /dev/stdin /etc/nas-credentials   # type the two lines below, then Ctrl+D
   username=aenyhm
   password=<DSM password>
   ```
7. **Build and switch.** A flake only sees files tracked by git, so add new files first. `--sudo` builds as your user, whose SSH key fetches the private repository, and activates as root:
   ```
   git add -A
   nixos-rebuild switch --flake .#<hostname> --sudo
   ```
   The configuration is named after the `networking.hostName` of the host (`aenyhm-home-linux`, `fnouaillat-work`). Only this first switch names it, since the installer called the machine `nixos`. From then on, `nh os switch` finds it from the hostname.
8. **Set a password for each user**, created without one: `sudo passwd <user>`.

## After the first login

Each user finishes its own session, since these settings live in the home directory or on remote services.

| Task | How |
|---|---|
| SSH keys | copy `~/.ssh/id_ed25519` and its `.pub` from the previous install (`chmod 600` on the private key), or `ssh-keygen -t ed25519` and add the public key to GitHub |
| GitHub access for git | `gh auth login` |
| Syncthing | pair with the other devices from `127.0.0.1:8384`, or `127.0.0.1:8385` for `fnouaillat` on `home`. Each user runs its own Syncthing: share with it only the folders it needs |
| Music | Rhythmbox reads `~/Musique`, NAS included |
| Firmware and BIOS | `update` installs them along with the system |

The work session (`fnouaillat`, on both hosts) needs three more steps:

| Task | How |
|---|---|
| Work files | the `work` Syncthing folder at `~/sync/work`, see [Sync the work files](how-to.md#sync-the-work-files). The first switch renamed an existing `~/.claude` to `~/.claude.backup`: move its `CLAUDE.md`, `settings.json` and `skills/` into `~/sync/work/claude-config` |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash`. The official installer keeps it up to date in `~/.local/bin` |
| vite-plus | its install script, from the esgc-front README. It provides Node.js, `vp` and `vpr` |
