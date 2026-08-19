# LingmoNix minimal ISO.
#
# Minimal installer base + the full Lingmo desktop module
# (`services.desktopManager.lingmo`), so it boots into a Lingmo desktop on a
# minimal image. The upstream NixOS ISO config is imported as-is (no overrides
# of its naming/volume options). Calamares/installer branding is deferred.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  # Full Lingmo module: SDDM + Lingmo session + all components + branding.
  services.desktopManager.lingmo.enable = true;

  system.stateVersion = "25.05";
}
