# LingmoNix

A LingmoOS-like GNU/Linux distribution built on NixOS: the Lingmo desktop
(core, DE, dock, launcher, control center, KWin plugins, Qt plugins, apps,
daemons, theming) packaged as a Nix flake + NixOS module.

## Layout

```
flake.nix                     flake entrypoint (overlay + module + example system)
overlays/lingmo.nix           pkgs.lingmo.* overlay (libsForQt5 scope)
pkgs/lingmo/<name>/           one derivation per Lingmo component (Qt5)
pkgs/lingmo-qt6/<name>/       Qt6/KF6 components (appearance, installer-firstboot)
nixos/modules/.../lingmo/     services.desktopManager.lingmo module
nixos/example.nix             example NixOS VM config
nixos/iso-minimal.nix         minimal ISO (installer base + Lingmo desktop)
nixos/iso-live.nix            full live ISO (graphical base + Lingmo desktop)
dist/                         production artifacts (built ISOs; git-ignored)
assets/                       Lingmo logo assets (distributor-logo source)
tools/pkgbuild2nix.sh         AUR PKGBUILD -> Nix derivation converter
```

## Status

- [x] Phase 0/1: inventory, flake + overlay + module scaffold, logo assets
- [x] Phase 1: Nix installed on dev machine
- [x] Full AUR component set added: apps (filemanager, terminal, texteditor,
      screenshots, videoplayer) + theming/assets (wallpapers, systemicons,
      gtk-themes, cursor-themes, sddm-theme)
- [x] Qt6/KF6 components: lingmo-appearance, lingmo-installer-firstboot
      (separate `lingmo-qt6` scope — upstream targets Qt6, not Qt5)
- [x] Phase 2: platform layer builds (liblingmo, lingmoui, qt-plugins, kwin-plugins)
- [x] Phase 3: core & session builds (lingmo-core incl. session/polkit-agent/daemons,
      lingmo-screenlocker)
- [x] Phase 4: shell + apps build (dock, launcher, statusbar, settings,
      filemanager, terminal, texteditor, screenshots, videoplayer)
- [ ] Phase 5–7: module wiring (session/daemon units, PAM, SDDM), ISO, CI

## Bootstrap (needs sudo — run in your own terminal)

```bash
sudo pacman -S --needed nix && sudo systemctl enable --now nix-daemon
echo 'experimental-features = nix-command flakes' | sudo tee /etc/nix/nix.conf
```

then, from this repo:

```bash
nix flake check          # validate
nix build .#liblingmo    # build first package
nix build .#iso          # minimal ISO (installer base + Lingmo desktop)
nix build .#iso-live     # full live ISO (graphical base + Lingmo desktop)
```

## Binary cache

Pre-built LingmoNix packages are published to the Cachix binary cache
**`lingmonix`** (check [LingmoNix's Cachix Repo](https://lingmonix.cachix.org) for the public key),
declared in `flake.nix` (`nixConfig`), so `nix build` fetches pre-built artifacts
automatically.

```bash
# Auth (one-time):
cachix authtoken <token>        # https://cachix.org -> account -> auth token

# Push the Lingmo package set after a rebuild:
nix build --no-link --print-out-paths \
  .#branding .#liblingmo .#lingmoui .#lingmo-qt-plugins .#lingmo-kwin-plugins \
  .#lingmo-core .#lingmo-screenlocker .#lingmo-dock .#lingmo-launcher .#lingmo-statusbar \
  .#lingmo-settings .#lingmo-filemanager .#lingmo-screenshots .#lingmo-terminal \
  .#lingmo-texteditor .#lingmo-videoplayer .#lingmo-cursor-themes .#lingmo-gtk-themes \
  .#lingmo-sddm-theme .#lingmo-systemicons .#lingmo-wallpapers \
  .#lingmo-appearance .#lingmo-installer-firstboot \
  | xargs cachix push lingmonix
```

Note: the ISO images are **not** pushed to the cache — they are production
artifacts copied to `dist/` instead.

## Licensing

LingmoOS components are GPL-3.0 (per-component LICENSE files should be
confirmed as each package lands). Face-recognition (`seetaface-*`) has
commercial terms and will be optional/unfree.
