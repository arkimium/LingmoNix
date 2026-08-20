{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qttools, qtquickcontrols2, qtgraphicaleffects, kwindowsystem, lingmoui, liblingmo
}:

stdenv.mkDerivation {
  pname = "lingmo-launcher";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-launcher";
    rev = "2.0.2";
    hash = "sha256-pkjs0nxaI/+SPGQRqBSU+aAw4/Gt5daG6JZQswrv+8E=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qttools qtquickcontrols2 qtgraphicaleffects kwindowsystem lingmoui liblingmo ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "Application launcher for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
