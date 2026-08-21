# LingmoNix overlay: exposes `pkgs.lingmo.<component>`.
#
# Everything is built inside the `libsForQt5` scope because LingmoOS targets
# Qt5 / KDE Frameworks 5 / Plasma 5 (see PLAN.md). The scope's callPackage
# resolves both Qt5 packages and the base nixpkgs (stdenv, cmake, fetch*).
final: prev: {
  lingmo = final.libsForQt5.callPackage ../pkgs/lingmo {
    # Flake-source-relative asset dir (Lingmo logo etc.) for the branding pkg.
    brandingAssets = ../assets;
  };

  # Qt6 / KF6 components (lingmo-appearance, lingmo-installer-firstboot).
  lingmo-qt6 = final.kdePackages.callPackage ../pkgs/lingmo-qt6 { };

  # PyQt5 fluent widgets library (lingmo-qt-widgets) + its frameless-window dep.
  lingmo-qt-widgets = final.python3Packages.callPackage ../pkgs/python/lingmo-qt-widgets {
    pyqt5-frameless-window = final.python3Packages.callPackage ../pkgs/python/pyqt5-frameless-window { };
  };

  # Lingmo's fork of KWin 5.27.2 (Qt5/KF5).
  lingmo-kwin = final.callPackage ../pkgs/lingmo/lingmo-kwin {
    inherit (final) libsForQt5;
    lingmo-wayland-protocols = final.lingmo.lingmo-wayland-protocols;
  };
}
