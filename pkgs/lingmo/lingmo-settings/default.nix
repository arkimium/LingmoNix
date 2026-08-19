{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, pkg-config
, qtbase, qtdeclarative, qtquickcontrols2, qttools, qtx11extras
, freetype, fontconfig, kconfig, icu, libxcrypt
, networkmanager-qt, modemmanager-qt, lxqt, lingmoui, xorg
}:

stdenv.mkDerivation {
  pname = "lingmo-settings";
  version = "2.1.7";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-settings";
    rev = "2.1.7";
    hash = "sha256-ac2TQ7DRGRFpDX3PRcNrc90f3eQXokBV9vMQlw0CnZw=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook pkg-config ];
  buildInputs = [
    qtbase qtdeclarative qtquickcontrols2 qttools qtx11extras
    freetype fontconfig kconfig icu libxcrypt
    networkmanager-qt modemmanager-qt lxqt.libqtxdg lingmoui
    xorg.libX11 xorg.libXi xorg.libXcursor
  ];

  meta = with lib; {
    description = "The system settings (control center) for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
