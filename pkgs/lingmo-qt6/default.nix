# Qt6 / KDE Frameworks 6 components. These are NOT Qt5 — lingmo-appearance and
# lingmo-installer-firstboot upstream target Qt6/KF6/KDecoration3 (KWin 6), so
# they must be built in the `kdePackages` scope, separate from pkgs.lingmo.
{ lib, callPackage }:

lib.recurseIntoAttrs {
  lingmo-appearance = callPackage ./lingmo-appearance { };
  lingmo-installer-firstboot = callPackage ./lingmo-installer-firstboot { };
}
