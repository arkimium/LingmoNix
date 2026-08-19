# Mirrors upstream's own packaging (nix/package.nix in the lingmo-appearance
# repo). lingmo-appearance vendors KStyle (kstyle/ subdir) and KF6KirigamiPlatform
# is shipped inside the `kirigami` framework, so neither is a separate dep.
{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, kcmutils, kcoreaddons, kiconthemes, kwindowsystem, kcolorscheme, kdecoration, kirigami
}:

stdenv.mkDerivation {
  pname = "lingmo-appearance";
  # No git tags upstream; version taken from the repo's VERSION file.
  version = "0.5.25";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-appearance";
    rev = "c16544d3add778d88a34c54a02270ec14309f178";
    hash = "sha256-U6yIsxHd7G9kStPAXYhuTEsQhrfTXzNz5yABvTzfNIM=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [
    qtbase kcmutils kcoreaddons kiconthemes kwindowsystem
    kcolorscheme kdecoration kirigami
  ];

  # Build only the Qt6 style plugin (Qt5 is "legacy/unsupported" upstream).
  cmakeFlags = [ "-DBUILD_QT5=OFF" "-DBUILD_QT6=ON" ];

  meta = with lib; {
    description = "Adaptive Qt style, KWin decoration and settings app for Lingmo (Qt6/KF6)";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
