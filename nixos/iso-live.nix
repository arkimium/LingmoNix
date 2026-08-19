# LingmoNix full live ISO.
#
# Graphical live base (X11, NetworkManager, guest tools, plymouth) + the full
# Lingmo desktop module + the Calamares graphical installer, branded LingmoNix.
#
# Calamares: we reuse NixOS's calamares-nixos + calamares-nixos-extensions
# (the NixOS install modules), but point its branding at our "lingmonix"
# component (see pkgs/lingmo/lingmo-calamares-branding).
{ config, lib, pkgs, modulesPath, ... }:

let
  # calamares-nixos-extensions with `branding: lingmonix` selected instead of
  # the stock "nixos" branding.
  calamares-nixos-lingmonix = pkgs.calamares-nixos-extensions.overrideAttrs (o: {
    postInstall = (o.postInstall or "") + ''
      sed -i 's/^branding:.*/branding: lingmonix/' "$out/share/calamares/settings.conf"
    '';
  });

  calamares-nixos-autostart = pkgs.makeAutostartItem {
    name = "io.calamares.calamares";
    package = pkgs.calamares-nixos;
  };
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-base.nix")
  ];

  # Full Lingmo module: SDDM + Lingmo session + all components + branding.
  services.desktopManager.lingmo.enable = true;

  # ---- Calamares installer (LingmoNix branding) ----
  environment.systemPackages = with pkgs; [
    libsForQt5.kpmcore
    calamares-nixos
    calamares-nixos-autostart
    calamares-nixos-lingmonix           # replaces calamares-nixos-extensions
    lingmo.lingmo-calamares-branding    # branding/lingmonix component
    glibcLocales
  ];

  # Installer needs every locale to choose from.
  i18n.supportedLocales = [ "all" ];

  # Live user + auto-login so the installer (autostart) can run on the desktop.
  # NOTE: lingmo-session XDG-autostart handling is still Phase 5; the autostart
  # item is provided here and will take effect once the session runs it.
  users.users.nixos = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [ "wheel" ];
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  system.stateVersion = "25.05";
}
