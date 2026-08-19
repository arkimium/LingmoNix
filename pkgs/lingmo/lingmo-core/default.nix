{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, pkg-config
, qtbase, qtdeclarative, qttools, qtquickcontrols2, qtgraphicaleffects, qtx11extras
, kcoreaddons, kwindowsystem, kidletime, polkit-qt, polkit, xorg
}:

stdenv.mkDerivation {
  pname = "lingmo-core";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-core";
    rev = "2.0.2";
    hash = "sha256-lRQgPwk6KNdpZU2T13cP6z8MHeJ6PUXVUu1WR2gcddE=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook pkg-config ];
  buildInputs = [
    qtbase qtdeclarative qttools qtquickcontrols2 qtgraphicaleffects qtx11extras
    kcoreaddons kwindowsystem kidletime polkit-qt polkit
    xorg.libX11 xorg.libXi xorg.libXext xorg.libSM xorg.libICE xorg.libXrandr xorg.libXtst
    xorg.libXcursor xorg.libxcb xorg.xcbutil xorg.xcbutilimage xorg.xcbutilkeysyms
    xorg.xorgserver xorg.xf86inputlibinput xorg.xf86inputsynaptics
  ];

  # Upstream hardcodes absolute /usr and /etc install paths; nixpkgs' cmake hook
  # rewrites any leftover /usr|/opt to /var/empty (which fails), so redirect under $out.
  # NOTE: runtime /usr paths in .cpp are a later phase (module wiring) concern.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'DESTINATION /etc/' 'DESTINATION etc/' \
      --replace '/usr/bin' 'bin'
    substituteInPlace notificationd/CMakeLists.txt \
      --replace '/usr/bin' 'bin' \
      --replace '/usr/share/lingmo-notificationd/translations' 'share/lingmo-notificationd/translations'
  '';

  meta = with lib; {
    description = "Core components of LingmoOS: system backend and session initiation";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
