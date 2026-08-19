{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qtquickcontrols2, qttools
}:

stdenv.mkDerivation {
  pname = "lingmo-calculator";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-calculator";
    rev = "0.6.3";
    hash = "sha256-Ml82Ps5gF/aWZ5LpteHn9mIgRi22ToM+FEx7y4l8BoQ=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qttools ];

  # Upstream hardcodes /usr install paths; nixpkgs' cmake hook rewrites leftover
  # /usr to /var/empty (which fails the install) — redirect under $out.
  # NOTE: runtime paths (translations in main.cpp, .desktop Exec) are Phase 5.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin'
  '';

  meta = with lib; {
    description = "A simple calculator for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
