{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qttools, qtquickcontrols2, qtx11extras, kwindowsystem
}:

stdenv.mkDerivation {
  pname = "lingmo-statusbar";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-statusbar";
    rev = "2.0.1";
    hash = "sha256-syZMSLeIwQIJgpMnre7xjmvznqIgMzOFEq0eUUCf+6A=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qttools qtquickcontrols2 qtx11extras kwindowsystem ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "The status bar for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
