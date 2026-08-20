# LingmoNix full live ISO.
#
# Live desktop is Pantheon (a stable desktop to run the installer from); the
# installer (Calamares, branded LingmoNix) installs the Lingmo desktop.
#
# Branding (os-release, plymouth, grub, calamares) is LingmoNix. Nix store
# fetches from the USTC mirror + LingmoNix Cachix.
{ config, lib, pkgs, modulesPath, lingmonix-flake, ... }:

let
  # Bundle the LingmoNix source (module + overlay + packages + assets) so the
  # installer can copy it onto the target's /etc/nixos/lingmonix/.
  lingmonix-source = pkgs.runCommand "lingmonix-source" { } ''
    mkdir -p "$out/share/lingmonix"
    cp -r ${lingmonix-flake.outPath}/nixos "$out/share/lingmonix/nixos"
    cp -r ${lingmonix-flake.outPath}/pkgs "$out/share/lingmonix/pkgs"
    cp -r ${lingmonix-flake.outPath}/overlays "$out/share/lingmonix/overlays"
    cp -r ${lingmonix-flake.outPath}/assets "$out/share/lingmonix/assets"
  '';
  # calamares-nixos-extensions with `branding: lingmonix`, a "Lingmo" desktop
  # option in the package chooser, and experimental-features in the generated config.
  calamares-nixos-lingmonix = pkgs.calamares-nixos-extensions.overrideAttrs (o: {
    nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ pkgs.python3 ];
    postInstall = (o.postInstall or "") + ''
      # Use the LingmoNix branding component.
      sed -i 's/^branding:.*/branding: lingmonix/' "$out/share/calamares/settings.conf"

      # Add the "Lingmo" desktop option (icon + packagechooser item) and emit
      # experimental-features + lingmo desktop into the generated configuration.nix.
      cp "${pkgs.lingmo.lingmo-calamares-branding}/share/calamares/branding/lingmonix/lingmo-logo.png" \
         "$out/share/calamares/images/lingmo.png"
      python3 ${../tools/patch-calamares-nixos.py} \
         "$out/share/calamares/modules/packagechooser.conf" \
         "$out/lib/calamares/modules/nixos/main.py"
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
    LOGO = "lingmo";
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

  # ---- Live user (autologin as the installer's default `nixos` user) ----
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # ---- Boot branding: plymouth + grub ----
  boot.plymouth.enable = true;
  boot.plymouth.theme = "lingmo-plymouth";
  boot.plymouth.themePackages = [ pkgs.lingmo.lingmo-plymouth-theme ];
  boot.loader.grub.splashImage = "${pkgs.lingmo.lingmo-grub-config}/grub/splash.png";
  boot.loader.grub.theme = "${pkgs.lingmo.lingmo-grub-config}/grub/themes/lingmo";

  # ---- Nix: experimental features + binary caches ----------------
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://lingmonix.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "lingmonix.cachix.org-1:1I7WKo+wDzI62DyDBGhslINuPwoH37DV2DkhgiXiR78="
  ];

  # ---- Calamares installer (LingmoNix branding) ----
  environment.systemPackages = with pkgs; [
    lingmo.branding                    # distributor-logo (LingmoOS logo)
    lingmo.lingmo-plymouth-theme
    lingmo.lingmo-grub-config
    lingmo.lingmo-calamares-branding   # branding/lingmonix component
    lingmonix-source                   # Lingmo module+overlay for the installer
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
