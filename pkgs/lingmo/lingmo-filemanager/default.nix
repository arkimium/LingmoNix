{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook, qtquickcontrols2, kwindowsystem, kio }:

stdenv.mkDerivation {
  pname = "lingmo-filemanager";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-filemanager";
    rev = "0.8.1";
    hash = "sha256-JhMxjJ+cPtslrzEwQofxe7rpqtD21IyUqNQsptp22Vo=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtquickcontrols2 kwindowsystem kio ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "A file manager that simple to use, beautiful, and retain the classic PC interactive design used by LingmoOS.";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
