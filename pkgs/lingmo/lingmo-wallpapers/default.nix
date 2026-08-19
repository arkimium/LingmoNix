{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules }:

stdenv.mkDerivation {
  pname = "lingmo-wallpapers";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-wallpapers";
    rev = "3.0.1";
    hash = "sha256-kIZndzHA7AjuX2aeWUprG0IUj+KltgRSREWswMLc6sU=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ ];

  # Upstream installs backgrounds to absolute /usr/share/backgrounds/lingmoos.
  postPatch = ''
    substituteInPlace sources/CMakeLists.txt \
      --replace '/usr/share/backgrounds/lingmoos' 'share/backgrounds/lingmoos'
  '';

  meta = with lib; {
    description = "Built-in wallpapers for LingmoOS.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
