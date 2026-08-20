{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, qtbase, qtdeclarative, qtquickcontrols, qtquickcontrols2, qttools, syntax-highlighting, lingmoui }:

stdenv.mkDerivation {
  pname = "lingmo-texteditor";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-texteditor";
    rev = "2.0.1";
    hash = "sha256-BmkF1gCCyRRsYV9gCYzILEX3hizrSTckCYOB2xKjt38=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols qtquickcontrols2 qttools syntax-highlighting lingmoui ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "An easy-to-use and aesthetically pleasing text editor for Lingmo OS.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
