{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules }:

stdenv.mkDerivation {
  pname = "lingmo-gtk-themes";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-gtk-themes";
    rev = "2.0.2";
    hash = "sha256-lThLcQt2wa/WUlAeGUvzfFtSlmznaTYdJXxDQXJ6me0=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ ];

  meta = with lib; {
    description = "GTK themes for Lingmo OS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
