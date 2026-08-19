# LingmoNix full live ISO.
#
# Graphical live base (X11, NetworkManager, guest tools, plymouth) + the full
# Lingmo desktop module. This is the "full live image with desktop".
#
# Calamares (graphical installer) is intentionally NOT wired yet — its config
# needs changes and will be discussed separately.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-base.nix")
  ];

  # Full Lingmo module: SDDM + Lingmo session + all components + branding.
  services.desktopManager.lingmo.enable = true;

  system.stateVersion = "25.05";
}
