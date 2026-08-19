{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules
, qtbase, qtdeclarative, qtquickcontrols2, qttools, qtx11extras
, kwindowsystem, lxqt, libdbusmenu, xorg
}:

stdenv.mkDerivation {
  pname = "lingmo-qt-plugins";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-qt-plugins";
    rev = "2.0.1";
    hash = "sha256-JxDsdppnakYqPToVC9r4+nTeLftWZrlo3uP2t8B3vUI=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qttools qtx11extras kwindowsystem lxqt.libqtxdg_3_12 libdbusmenu xorg.libxcb ];

  # QT_INSTALL_PLUGINS is also an unexpanded placeholder in nixpkgs Qt5.
  # platformtheme/ uses `qmake -query`; widgetstyle/ uses ECM's ecm_query_qt.
  postPatch = ''
    sed -i '/execute_process(COMMAND/,/^[[:space:]]*)$/c\set(QT_PLUGINS_DIR "${qtbase.qtPluginPrefix}")' platformtheme/CMakeLists.txt
    substituteInPlace widgetstyle/CMakeLists.txt \
      --replace 'ecm_query_qt(CMAKE_INSTALL_QTPLUGINDIR QT_INSTALL_PLUGINS)' \
                'set(CMAKE_INSTALL_QTPLUGINDIR "${qtbase.qtPluginPrefix}")'
  '';

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Unify Qt application style of LingmoOS (platform theme/plugins)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
