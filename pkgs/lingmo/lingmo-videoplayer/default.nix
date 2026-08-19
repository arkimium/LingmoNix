{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, mpv, qtbase, qtquickcontrols2, qttools }:

stdenv.mkDerivation {
  pname = "lingmo-videoplayer";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-videoplayer";
    rev = "2.0.1";
    hash = "sha256-zFWyx2bO3pM6UAZcTfIDo3a5x93Gr1kI5EmcKIBdLpQ=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ mpv qtbase qtquickcontrols2 qttools ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "Open source video player built using Qt/QML and libmpv.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
