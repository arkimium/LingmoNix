{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qtquickcontrols2, qttools, knotifications, lingmoui, liblingmo
}:

stdenv.mkDerivation {
  pname = "lingmo-clock";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-clock";
    rev = "1.0.3-2_lingmo3";
    hash = "sha256-wLKZvHIRId/mARhTfegOgrEFNTiBqyibPGayoJa41ek=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qtquickcontrols2 qttools knotifications lingmoui liblingmo ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin'
  '';

  meta = with lib; {
    description = "Clock application for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
