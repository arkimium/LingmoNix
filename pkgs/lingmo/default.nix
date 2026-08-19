# Component index. `callPackage` is the libsForQt5-scope callPackage, so each
# derivation below sees Qt5/KF5/Plasma5 deps plus base pkgs.
{ lib, callPackage, brandingAssets }:

lib.recurseIntoAttrs (rec {
  # ---- Theming / branding ----
  branding = callPackage ./branding { inherit brandingAssets; };

  # ---- Layer 1: platform ----
  liblingmo = callPackage ./liblingmo { };
  lingmoui = callPackage ./lingmoui { };
  lingmo-qt-plugins = callPackage ./lingmo-qt-plugins { };
  lingmo-kwin-plugins = callPackage ./lingmo-kwin-plugins { };

  # ---- Layer 2: core & session ----
  lingmo-core = callPackage ./lingmo-core { };
  lingmo-screenlocker = callPackage ./lingmo-screenlocker { };
  # NOTE: lingmo-session + lingmo-polkit-agent are bundled inside lingmo-core.

  # ---- Layer 3: shell & panels ----
  lingmo-dock = callPackage ./lingmo-dock { inherit lingmoui; };
  lingmo-launcher = callPackage ./lingmo-launcher { };
  lingmo-statusbar = callPackage ./lingmo-statusbar { };
  lingmo-settings = callPackage ./lingmo-settings { inherit lingmoui; };

  # ---- Layer 4: apps ----
  lingmo-filemanager = callPackage ./lingmo-filemanager { };
  lingmo-screenshots = callPackage ./lingmo-screenshots { };
  lingmo-terminal = callPackage ./lingmo-terminal { inherit lingmoui; };
  lingmo-texteditor = callPackage ./lingmo-texteditor { };
  lingmo-videoplayer = callPackage ./lingmo-videoplayer { };
  lingmo-calculator = callPackage ./lingmo-calculator { };
  # NOTE: no separate daemon layer — all Qt5 daemons are bundled in lingmo-core.
  # velora-* (next-gen, Qt6/Wayland) and apt-centric daemons (lingmo-daemon/QApt,
  # lastore-daemon, lingmo-updator) are out of scope / replaced by Nix-native shims.

  # ---- Layer 5: theming & assets ----
  lingmo-cursor-themes = callPackage ./lingmo-cursor-themes { };
  lingmo-gtk-themes = callPackage ./lingmo-gtk-themes { };
  lingmo-sddm-theme = callPackage ./lingmo-sddm-theme { };
  lingmo-systemicons = callPackage ./lingmo-systemicons { };
  lingmo-wallpapers = callPackage ./lingmo-wallpapers { };
  lingmo-plymouth-theme = callPackage ./lingmo-plymouth-theme { };

  # NOTE: lingmo-appearance + lingmo-installer-firstboot are Qt6/KF6 and live
  # in the separate pkgs.lingmo-qt6 set (see overlays/lingmo.nix).
})
