{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, qtbase }:

# Lingmo's fork of plasma-wayland-protocols, adding Deepin/Lingmo protocols
# (client-management.xml etc.) needed by lingmo-kwin.
stdenv.mkDerivation {
  pname = "lingmo-wayland-protocols";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-wayland-protocols";
    rev = "main";
    hash = "sha256-RE4vHAAzIfuemxytsNDceVo7eBRCIQUk88btRs8V+cM=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ qtbase ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Lingmo Wayland protocols (fork of plasma-wayland-protocols)";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
