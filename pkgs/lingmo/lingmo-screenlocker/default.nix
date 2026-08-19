{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qttools, qtx11extras, dbus, pam, xorg
}:

stdenv.mkDerivation {
  pname = "lingmo-screenlocker";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-screenlocker";
    rev = "2.0.2";
    hash = "sha256-wM7WxY9vFuTCTGdS/2Iicyos8Mb9ND1Fq/XnBIo56e4=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qttools qtx11extras dbus pam xorg.libX11 ];

  # Upstream hardcodes /usr for the translations install dir (and the runtime
  # lookup path). Redirect both under $out — nixpkgs' cmake hook rewrites any
  # leftover /usr to /var/empty, which would fail the install.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share/lingmo-screenlocker/translations' 'share/lingmo-screenlocker/translations'
    substituteInPlace screenlocker/main.cpp \
      --replace '/usr/share/lingmo-screenlocker/translations/' "$out/share/lingmo-screenlocker/translations/"
  '';

  meta = with lib; {
    description = "Screenlocker for LingmoOS";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
