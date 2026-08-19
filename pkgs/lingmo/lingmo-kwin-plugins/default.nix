{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules
, qtbase, qtdeclarative
, kconfig, kconfigwidgets, kcoreaddons, kguiaddons, kwindowsystem
, kdecoration, kwayland, plasma-framework, kwin
}:

stdenv.mkDerivation {
  pname = "lingmo-kwin-plugins";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-kwin-plugins";
    rev = "1.2.4";
    hash = "sha256-Zp+TGgqJhDmtBSKliivQaqat+bPsZMKTu0E3c3SQz7k=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [
    qtbase qtdeclarative
    kconfig kconfigwidgets kcoreaddons kguiaddons kwindowsystem
    kdecoration kwayland plasma-framework kwin
  ];

  # Upstream PKGBUILD passes -DCMAKE_PREFIX_PATH=/usr/lib/cmake/plasma5/KDecoration2
  # (Arch-specific split). Nix KF5 setup hooks populate CMAKE_PREFIX_PATH already,
  # so this is normally unnecessary; keep in mind if find_package(KDecoration2) fails.
  # cmakeFlags = [ "-DCMAKE_PREFIX_PATH=${kdecoration}/lib/cmake" ];

  # QT_INSTALL_PLUGINS placeholder in the decoration plugin, plus hardcoded
  # /etc/xdg and /usr/share/kwin install paths in the top-level CMakeLists.
  postPatch = ''
    sed -i '/execute_process(COMMAND/,/^[[:space:]]*)$/c\set(QT_PLUGINS_DIR "${qtbase.qtPluginPrefix}")' plugins/decoration/CMakeLists.txt
    substituteInPlace CMakeLists.txt \
      --replace '/etc/xdg' 'etc/xdg' \
      --replace '/usr/share/kwin/' 'share/kwin/'
  '';

  dontWrapQtApps = true;

  meta = with lib; {
    description = "KWin plugins (decorations/effects) for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
