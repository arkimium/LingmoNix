{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, qtbase, qtdeclarative, qtquickcontrols2, qtx11extras, qttools, qtgraphicaleffects, lingmoui }:

stdenv.mkDerivation {
  pname = "lingmo-terminal";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-terminal";
    rev = "2.0.0";
    hash = "sha256-ZpYgWN3WVDpuRhaz70RtNgMJEQzJlFzC4emzimZZRh8=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qtx11extras qttools qtgraphicaleffects lingmoui ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "Terminal emulator using LingmoUI as interface style on LingmoOS.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
