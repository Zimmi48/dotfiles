# Installing a new machine

All the machines present in this repository use an Impermanence-based layout, with a tmpfs root and a persistent `/persist` directory. However, users and passwords are managed in a mutable way (not declaratively, like most other Impermanence users would do).

This is the procedure that was used to install `dell-precision-theo` (2026-09).
It installs the *final* configuration directly: there is no throwaway intermediate
system, and no USB stick is required.

The tricky parts, which this document exists to remember, are:

- the Nix store must not land on the tmpfs root during installation;
- `/persist/etc/shadow` must be seeded by hand, otherwise the machine is
  unloginable after the first reboot.

## 0. Prerequisites

- Secure Boot disabled in the BIOS (required by kexec, and by the NixOS installer
  in general).
- The machine can reach the network.
- Anything worth keeping on the disk has been backed up: the disk is wiped.

## 1. Boot the NixOS installer without a USB stick

If the machine already runs some Linux distribution (for instance, on the Télécom Paris network, booting with the ethernet connected will offer the option to boot into a live Ubuntu installer), boot the installer from
inside it, as root:

```sh
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz \
  | tar -xzf- -C /root
/root/kexec/run
```

The running kernel is replaced by a NixOS installer that lives entirely in RAM,
so the disk it came from can be repartitioned. It starts `sshd`, keeps the
previous host keys and `/root/.ssh/authorized_keys`. Download a public SSH key and add it to `/root/.ssh/authorized_keys` if it is not already there.

If the machine has no Linux on it, use the BIOS `UEFI HTTPs Boot` entry pointed
at `netboot.xyz.efi` and chain the netboot iPXE script from `nixos-images`.

Wi-Fi is *not* carried over by kexec; reconnect with `iwctl` if needed.

On the Télécom network, machines on different client subnets cannot reach each
other directly, but the campus jump host can:

```sh
ssh -J ssh.enst.fr root@<installer-ip>
```

## 2. Partition, encrypt, format

Layout: an EFI system partition, and a single LUKS2 container holding an LVM
volume group with a swap and a data logical volume. Everything is in one LUKS
container so that only one passphrase is asked at boot, while still allowing a
real swap partition (needed for hibernation, which wants swap >= RAM).

```sh
DISK=/dev/nvme0n1

wipefs -a $DISK
sgdisk --zap-all $DISK
sgdisk -n1:0:+2G -t1:ef00 -c1:ESP  $DISK
sgdisk -n2:0:0   -t2:8309 -c2:luks $DISK
partprobe $DISK

cryptsetup luksFormat --type luks2 ${DISK}p2   # interactive passphrase
cryptsetup open ${DISK}p2 cryptroot

pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -L 20G     -n swap    vg
lvcreate -l 100%FREE -n persist vg

mkfs.fat -F32 -n ESP ${DISK}p1
mkfs.ext4 -L persist /dev/vg/persist
mkswap -L swap /dev/vg/swap
```

## 3. Mount, emulating the impermanence layout

The installed system has a tmpfs root and keeps everything under `/persist`,
including the Nix store (`/nix` is bind-mounted from `/persist/nix` by
Impermanence). The same shape has to be reproduced by hand under `/mnt`,
otherwise `nixos-install` copies ~30 GB into a 3 GB tmpfs and fails.

```sh
mount -t tmpfs -o size=3G,mode=755 none /mnt
mkdir -p /mnt/persist /mnt/boot /mnt/nix
mount /dev/vg/persist /mnt/persist
mkdir -p /mnt/persist/nix /mnt/persist/etc
mount --bind /mnt/persist/nix /mnt/nix
mount ${DISK}p1 /mnt/boot
swapon /dev/vg/swap
```

## 4. Write the host configuration

Create `<host>.nix` from an existing host file, and add the host to
`flake.nix`. What is machine specific:

- `boot.initrd.luks.devices."cryptroot".device` and `fileSystems."/boot".device`,
  from `blkid -s UUID -o value ${DISK}p2` and `blkid -s UUID -o value ${DISK}p1`;
- `boot.initrd.availableKernelModules`. **Do not copy this from another host.**
  Run `nixos-generate-config --show-hardware-config --no-filesystems` on the
  target and use what it reports. On the Precision 7560 this is where `vmd`
  came from, which is needed because Intel RST/VMD is enabled in its BIOS;
  without it the NVMe is invisible at boot.

Transfer the repository to the installer, `.git` included, because the flake
refers to `self.dirtyShortRev`:

```sh
tar -cz --exclude='dotfiles/nix-builds' dotfiles | ssh <installer> 'tar -xzf- -C /root'
ssh <installer> 'chown -R root:root /root/dotfiles'   # else libgit2 refuses to open the repo
```

## 5. Install

```
nixos-install --root /mnt --flake /root/dotfiles#<host> --no-root-password
```

## 6. Seed `/persist/etc/shadow`

Passwords are not managed declaratively; `/etc/shadow` is a symlink to
`/persist/etc/shadow`. After `nixos-install` that file is **empty**: the accounts
exist in `/etc/passwd` but no hash was ever written to the persistent
filesystem. Rebooting in that state leaves no way to log in.

`nixos-enter` re-runs the activation script on *every* invocation, and activation
recreates `/etc/shadow` as a symlink, discarding whatever a previous invocation
wrote. So all of the following must happen in a **single** `nixos-enter`:

```sh
nixos-enter --root /mnt -c 'rm -f /etc/shadow
  install -m600 /dev/null /etc/shadow
  pwconv
  passwd root
  passwd <user>
  cp /etc/shadow /persist/etc/shadow
  chmod 600 /persist/etc/shadow'
```

(The first three commands could be removed to only start at `passwd root`.)

To check the result before rebooting, verify the hashes with the same helper
that `pam_unix` uses, running it as root, and sending the password
NUL-terminated the way PAM does:

```sh
nixos-enter --root /mnt -c 'read -rsp "password: " P; echo
  printf "%s\0" "$P" | $(ls /nix/store/*linux-pam*/bin/unix_chkpwd | head -1) root nullok
  echo "rc=$?"'   # rc=0 means the password matches
```

Note that `su` cannot be used for this check inside `nixos-enter`: `/run/wrappers`
does not exist there, so neither the setuid `su` nor the setuid `unix_chkpwd` is
available and authentication always fails, whatever the password.

## 7. Reboot

```sh
sync; swapoff -a; umount -R /mnt; systemctl reboot
```

## Afterwards

- `passwd` on the running system replaces the `/etc/shadow` symlink with a real
  file on the tmpfs. After every password change:
  `sudo cp /etc/shadow /persist/etc/shadow`.
- Clone this repository into `~/git/dotfiles` (persisted) and use `./build.sh`
  for subsequent changes.
- If a boot ever fails to let you log in, boot the installer again as in step 1,
  `cryptsetup open` the container, mount `/dev/vg/persist` and fix
  `etc/shadow` there. Only the LUKS passphrase is unrecoverable.
