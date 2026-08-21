{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, kconfigwidgets, kwin, libepoxy, xorg
}:

stdenv.mkDerivation {
  pname = "lingmo-kwin-plugins-roundedwindow";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-kwin-plugins-roundedwindow";
    rev = "1.0.2"; # Qt5/KF5 branch (1.1.0+ is Qt6/KF6)
    hash = "sha256-IslAIRaYd3conUJBEPYZqbdya0vHcFB7NlnUz4oY9Dw=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ kconfigwidgets kwin libepoxy xorg.libxcb ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Round window corners KWin effect for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
