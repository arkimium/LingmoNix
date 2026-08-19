{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules }:

stdenv.mkDerivation {
  pname = "lingmo-cursor-themes";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-cursor-themes";
    rev = "2.0.2";
    hash = "sha256-NitgBQX1VsbmKRMNR72ipzlUkTns/kpetFx8hccg+7M=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ ];

  # Upstream installs cursor-selection config to absolute /etc/X11/cursors —
  # redirect under $out (the NixOS module sets the default cursor declaratively).
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/etc/X11/cursors' 'share/lingmo-cursor-themes'
  '';

  meta = with lib; {
    description = "Lingmo OS Cursor Themes";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
