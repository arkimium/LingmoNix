{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qttools, kio, solid, kwindowsystem, kconfig, lingmoui, liblingmo
}:

stdenv.mkDerivation {
  pname = "lingmo-desktop";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-desktop";
    rev = "main";
    hash = "sha256-613S8ofX4vbD6+8FyddxTp6sfd3JshVyI92NVtLOavs=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qttools kio solid kwindowsystem kconfig lingmoui liblingmo ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin'
  '';

  meta = with lib; {
    description = "LingmoOS desktop environment (LingmoUI)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
