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
}
