# Aerial

Headless agent host. Ryzen 7 7800X3D, 64 GB, Radeon RX 7900 XTX (ROCm), 1 TB NVMe for
NixOS (LUKS2 + TPM2, Secure Boot via lanzaboote, btrfs with an ephemeral root). The 2 TB
NVMe holds Windows with BitLocker and is not managed by this config, but its boot manager
lives on Aerial's ESP.

Install-time files live in `~/.local/share/aerial-install` on the Mac:
`root/persist/etc/ssh/ssh_host_ed25519_key` (host key, matches `my.secrets.sshKey`),
`esp/Microsoft` (Windows boot manager backup), `disk.key` (LUKS passphrase).

## Install

1. Save the Windows BitLocker recovery key. Changing Secure Boot keys makes Windows ask
   for it once.
2. `agenix rekey -a` (YubiKey) and commit `secrets/rekeyed/aerial`. The only secrets are the
   restic password and rclone config for the daily host-key backup.
3. Remove the old `aerial` machine from the Tailscale admin console.
4. Firmware setup: Security > Secure Boot > Secure Boot Mode `Custom`, then Key Management
   > "Reset To Setup Mode". Optional: disable the iGPU (Advanced > AMD CBS > NBIO > GFX
   Configuration), otherwise ROCm also lists the unsupported gfx1036 iGPU.
5. Build on the old system (the Mac cannot evaluate catppuccin's IFD) and install:

   ```sh
   d=~/.local/share/aerial-install
   read -rs pw && printf %s "$pw" > $d/disk.key && unset pw
   rsync -a --delete --exclude .git ./ stu@aerial:/tmp/nixcfg/
   ssh stu@aerial 'cd /tmp/nixcfg && git init -q && git add -A'
   build() { ssh stu@aerial "cd /tmp/nixcfg && nix build --no-link --print-out-paths .#nixosConfigurations.aerial.config.system.build.$1"; }
   disko=$(build diskoScript) && system=$(build toplevel)
   nix copy --no-check-sigs --from ssh-ng://stu@aerial $disko $system
   nix run github:nix-community/nixos-anywhere -- --target-host root@aerial \
     --store-paths $disko $system \
     --disk-encryption-keys /tmp/disk.key $d/disk.key \
     --extra-files $d/root
   ```

   The flake has a private input (`cliproxyapi`); if Aerial can't fetch it, first run
   `nix flake archive --json | jq -r '.. | .path? // empty' | xargs nix copy --to ssh-ng://stu@aerial`.

6. At the console, unlock with the passphrase. The first boot generates Secure Boot keys and
   reboots; systemd-boot enrolls them. Unlock again, then:

   ```sh
   ssh-keygen -R aerial
   scp -r ~/.local/share/aerial-install/esp/Microsoft root@aerial:/boot/EFI/
   ssh root@aerial
   bootctl status            # Secure Boot: enabled (user)
   systemd-cryptenroll --recovery-key /dev/disk/by-partlabel/disk-system-root   # store it
   systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-system-root
   tailscale up
   rocminfo | grep gfx1100
   ```

7. Clone the flake to `/home/stu/nix`, then delete `~/.local/share/aerial-install`.

## TPM unlock stopped working

PCR 7 changes when Secure Boot keys or firmware Secure Boot settings change (BIOS updates
often reset them). Unlock with the passphrase, re-enroll keys if `sbctl status` shows them
missing (`sbctl enroll-keys --microsoft`), then rebind:

```sh
systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-system-root
```
