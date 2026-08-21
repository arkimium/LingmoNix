{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qtquickcontrols2, qttools, kwindowsystem, lingmoui, liblingmo
}:

stdenv.mkDerivation {
  pname = "lingmo-system-monitor";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-system-monitor-new"; # upstream repo name
    rev = "1.0.2-1_lingmo3";
    hash = "sha256-UoO8hAYWSlOkMq5dLmbktyUApceUICIZeUUPn2ONlm4=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qttools kwindowsystem lingmoui liblingmo ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin'
  '';

  meta = with lib; {
    description = "System monitor for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
