{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, qtbase, qtdeclarative, qtquickcontrols2, qtgraphicaleffects, qttools, lingmoui }:

stdenv.mkDerivation {
  pname = "lingmo-screenshots";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-screenshots";
    rev = "2.0.0";
    hash = "sha256-+QWxQkZOKKrQJGMZ8N9RFdof2jFYdnUZs4Q6N6zxQ/Y=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qtgraphicaleffects qttools lingmoui ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "Screenshot tool for LingmoOS.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
