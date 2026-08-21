{ lib, libsForQt5, gsettings-qt, lingmo-wayland-protocols, python3, xorg, fetchFromGitHub }:

# Lingmo's fork of KWin 5.27.2 (Qt5/KF5). Reuse nixpkgs' kwin derivation
# (same deps), just swap in the Lingmo fork source.
libsForQt5.kwin.overrideAttrs (o: {
  pname = "lingmo-kwin";
  version = "5.27.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-kwin";
    rev = "main";
    hash = "sha256-3P4EuKJmprPDL+YoM3ZFsQjEAhE77mJcrzBswYMEU2c=";
  };

  # nixpkgs' kwin patches target 5.27.11 and don't all apply to the 5.27.2 fork
  # (e.g. 0002-xwayland). Drop them; the fork carries its own fixes.
  patches = [ ];

  # The fork needs gsettings-qt + Lingmo/Deepin wayland protocols in addition to
  # the standard plasma-wayland-protocols. python3 is needed so patchShebangs can
  # resolve strip-effect-metadata.py's `#!/usr/bin/env python3`.
  nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ python3 ];
  buildInputs = (o.buildInputs or [ ]) ++ [ gsettings-qt lingmo-wayland-protocols xorg.libXtst ];

  # The fork's Qt5 build assumes a forked KWayland with send_warp (the "v20 patch").
  # Define BUILD_WITHOUT_V20_PATCH to skip it and build against nixpkgs' KWayland.
  CXXFLAGS = (o.CXXFLAGS or [ ]) ++ [ "-DBUILD_WITHOUT_V20_PATCH" ];

  # The fork references Deepin protocols in src/wayland unconditionally, but the
  # Qt5/v20 branch only finds PlasmaWaylandProtocols. Find DeepinWaylandProtocols
  # too and point PLASMA_WAYLAND_PROTOCOLS_DIR at it (it contains every protocol).
  postPatch = (o.postPatch or "") + ''
    # patchShebangs doesn't resolve `#!/usr/bin/env python3` reliably here; fix it
    # directly and make it executable.
    sed -i "1s|.*|#!${python3}/bin/python3|" src/effects/strip-effect-metadata.py
    chmod +x src/effects/strip-effect-metadata.py
    sed -i '/find_package(PlasmaWaylandProtocols 1.9.0 CONFIG)/a\    find_package(DeepinWaylandProtocols 1.9.0 CONFIG)\n    set(PLASMA_WAYLAND_PROTOCOLS_DIR ''${DEEPIN_WAYLAND_PROTOCOLS_DIR})' CMakeLists.txt
  '';
})
