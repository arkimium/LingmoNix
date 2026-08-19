{ config, lib, pkgs, ... }:

let
  cfg = config.services.desktopManager.lingmo;
  inherit (lib) mkEnableOption mkIf mkOption types;
  # "originium" -> "Originium" for human-readable os-release fields.
  capitalize = s: lib.toUpper (lib.substring 0 1 s) + lib.substring 1 (lib.stringLength s) s;
in
{
  options.services.desktopManager.lingmo = {
    enable = mkEnableOption "the Lingmo desktop environment (LingmoNix)";

    brandingName = mkOption {
      type = types.str;
      default = "LingmoNix";
      description = "Distro name used in os-release and branding.";
    };

    version = mkOption {
      type = types.str;
      default = "0.1";
      description = "Distro version (os-release VERSION_ID).";
    };

    codename = mkOption {
      type = types.str;
      default = "originium";
      description = "Distro release codename (os-release VERSION_CODENAME).";
    };
  };

  config = mkIf cfg.enable {
    # ---- Distro branding: os-release name = LingmoNix ----------------
    system.nixos.distroName = cfg.brandingName; # NAME / PRETTY_NAME base
    system.nixos.distroId = "lingmonix";        # ID

    # ---- Version + codename: LingmoNix 0.1 "originium" ---------------
    # `release`/`codeName` are read-only (nixpkgs 25.05 "Emu"), so override the
    # generated os-release fields via the official extraOSReleaseArgs escape hatch.
    system.nixos.extraOSReleaseArgs = {
      VERSION_ID = cfg.version;
      VERSION = "${cfg.version} (${capitalize cfg.codename})";
      VERSION_CODENAME = lib.toLower cfg.codename;
      PRETTY_NAME = "${cfg.brandingName} ${cfg.version} (${capitalize cfg.codename})";
      # freedesktop icon name for the OS logo (shipped by the branding pkg).
      LOGO = "distributor-logo";
    };

    # ---- Display stack: X11 first (Lingmo is X11-centric; Wayland later) ----
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    # Theme "lingmo" is provided by pkgs.lingmo.lingmo-sddm-theme, which is in
    # environment.systemPackages below (SDDM looks in /run/current-system/sw/share/sddm/themes).
    services.displayManager.sddm.theme = "lingmo";

    # ---- Plymouth boot splash (Lingmo branding) ----
    boot.plymouth.enable = true;
    boot.plymouth.theme = "lingmo-plymouth";
    boot.plymouth.themePackages = [ pkgs.lingmo.lingmo-plymouth-theme ];

    # ---- GRUB boot splash + theme (Lingmo branding) ----
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

    # ---- Desktop session entry ----
    services.xserver.displayManager.session = [{
      name = "lingmo";
      desktopNames = [ "Lingmo" ];
      manage = "desktop";
      # lingmo-core ships `lingmo-session` (D-Bus com.lingmo.Session), which sets
      # the Lingmo environment and launches the shell components.
      # TODO(phase 5): full env/XDG wiring + launching dock/statusbar/daemons.
      start = ''
        export QT_QPA_PLATFORMTHEME=lingmo
        exec ${pkgs.lingmo.lingmo-core}/bin/lingmo-session
      '';
    }];

    # ---- Components ----
    environment.systemPackages = with pkgs.lingmo; [
      branding           # distributor-logo (LingmoOS logo) + branding
      liblingmo
      lingmoui
      lingmo-qt-plugins
      lingmo-kwin-plugins
      lingmo-core
      lingmo-screenlocker
      lingmo-dock
      lingmo-launcher
      lingmo-statusbar
      lingmo-settings
      lingmo-filemanager
      lingmo-screenshots
      lingmo-terminal
      lingmo-texteditor
      lingmo-videoplayer
      lingmo-calculator
      lingmo-cursor-themes
      lingmo-gtk-themes
      lingmo-sddm-theme
      lingmo-systemicons
      lingmo-wallpapers
      lingmo-plymouth-theme
      lingmo-grub-config
      pkgs.lingmo-qt6.lingmo-appearance
      pkgs.lingmo-qt6.lingmo-installer-firstboot
    ];

    # ---- Qt environment ----
    environment.variables = {
      QT_QPA_PLATFORMTHEME = "lingmo";
      # QT_PLUGIN_PATH is *additional* to Qt's built-in paths.
      QT_PLUGIN_PATH = lib.makeSearchPath
        "${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
        [ pkgs.lingmo.lingmo-qt-plugins ];
    };
    # NOTE: XDG_DATA_DIRS does not need manual config — the NixOS `xdg` module
    # auto-adds `$out/share` of every systemPackages entry, which includes
    # `branding` (icons/hicolor/.../distributor-logo.svg).
  };
}
