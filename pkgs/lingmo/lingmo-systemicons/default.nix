{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules }:

stdenv.mkDerivation {
  pname = "lingmo-systemicons";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-systemicons";
    rev = "2.0.5";
    hash = "sha256-5Sromgk2vBWRtyTBmTabaU2tbj4+AX+4uJ0bSPIJowM=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ ];

  # The theme declares `Inherits=Adwaita`, and many of its symlinks point to
  # icons supplied by that inherited theme (e.g. user-trash.svg, system-search.svg).
  # Nix's broken-symlink check only inspects this single output, so disable it —
  # the links resolve correctly once Adwaita is present on the system.
  dontCheckForBrokenSymlinks = true;

  meta = with lib; {
    description = "Default icon theme for Lingmo.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
