# LingmoNix full live ISO.
#
# Live desktop is Pantheon (a stable desktop to run the installer from); the
# installer (Calamares, branded LingmoNix) installs the Lingmo desktop.
#
# Branding (os-release, plymouth, grub, calamares) is LingmoNix. Nix store
# fetches from the USTC mirror + LingmoNix Cachix.
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

  # ---- LingmoNix branding (os-release) ----
  system.nixos.distroName = "LingmoNix";
  system.nixos.distroId = "lingmonix";
  system.nixos.extraOSReleaseArgs = {
    VERSION_ID = "0.1";
    VERSION = "0.1 (Originium)";
    VERSION_CODENAME = "originium";
    PRETTY_NAME = "LingmoNix 0.1 (Originium)";
    LOGO = "distributor-logo";
  };

  # ---- Live desktop: Pantheon ----
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.pantheon.enable = true;

  # Graphical base ships Firefox by default; use Chromium instead.
  environment.defaultPackages = lib.mkForce (with pkgs; [
    gparted
    vim
    nano
    chromium
    mesa-demos
  ]);

  # ---- Live user (autologin) ----
  users.users.liveuser = {
    isNormalUser = true;
    initialPassword = "lingmo";
    extraGroups = [ "wheel" ];
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "liveuser";
  };

  # ---- Boot branding: plymouth + grub ----
  boot.plymouth.enable = true;
  boot.plymouth.theme = "lingmo-plymouth";
  boot.plymouth.themePackages = [ pkgs.lingmo.lingmo-plymouth-theme ];
  boot.loader.grub.splashImage = "${pkgs.lingmo.lingmo-grub-config}/grub/splash.png";
  boot.loader.grub.theme = "${pkgs.lingmo.lingmo-grub-config}/grub/themes/lingmo";

  # ---- Binary caches: USTC store mirror + LingmoNix Cachix ----
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://lingmonix.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "lingmonix.cachix.org-1:OraUgITDO2Y9T+FJI4VELvooenUR+RiYiTLn+ExC3T3uYuMZsma1jnwNHjirTiPqyMnO/wMdg4Um5zsc7xXzBA=="
  ];

  # ---- Calamares installer (LingmoNix branding) ----
  environment.systemPackages = with pkgs; [
    lingmo.branding                    # distributor-logo (LingmoOS logo)
    lingmo.lingmo-plymouth-theme
    lingmo.lingmo-grub-config
    lingmo.lingmo-calamares-branding   # branding/lingmonix component
    libsForQt5.kpmcore
    calamares-nixos
    calamares-nixos-autostart
    calamares-nixos-lingmonix          # replaces calamares-nixos-extensions
    glibcLocales
  ];

  # Installer needs every locale to choose from.
  i18n.supportedLocales = [ "all" ];

  system.stateVersion = "25.05";
}
