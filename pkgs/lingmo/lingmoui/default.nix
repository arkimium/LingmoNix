{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules
, qtbase, qtdeclarative, qtquickcontrols2, qtx11extras, kwindowsystem
}:

stdenv.mkDerivation {
  pname = "lingmoui";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "LingmoUI";
    rev = "2.3.0";
    hash = "sha256-Ata6DgNgQc5cuGvISDh1JlMyOQBWz2hRSq57FbRDf6E=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qtx11extras kwindowsystem ];

  # Same nixpkgs Qt5 qmake-placeholder issue as liblingmo (QML install dir),
  # plus an absolute /etc install for the version marker.
  postPatch = ''
    sed -i '/execute_process(COMMAND/,/^[[:space:]]*)$/c\set(INSTALL_QMLDIR "${qtbase.qtQmlPrefix}")' CMakeLists.txt
    substituteInPlace CMakeLists.txt \
      --replace '/etc/LingmoUI/' 'share/LingmoUI/'
  '';

  dontWrapQtApps = true;

  meta = with lib; {
    description = "GUI library based on Qt Quick Controls 2; every Lingmo app uses it";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
