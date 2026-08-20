{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules, wrapQtAppsHook
, qtbase, qtdeclarative, qttools, qtquickcontrols2, qtgraphicaleffects, qtx11extras, kwindowsystem, lingmoui
}:

stdenv.mkDerivation {
  pname = "lingmo-dock";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-dock";
    rev = "2.0.3";
    hash = "sha256-kd/uvX5ajY/+26d8iVVi1hxcD+/vbNc/xSI6K9dx8Gk=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative qttools qtquickcontrols2 qtgraphicaleffects qtx11extras kwindowsystem lingmoui ];

  # Upstream hardcodes absolute /usr and /etc install paths; nixpkgs' cmake hook
  # rewrites leftover /usr|/opt to /var/empty (build failure) — redirect under $out.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/usr/share' 'share' \
      --replace '/usr/bin' 'bin' \
      --replace 'DESTINATION /etc' 'DESTINATION etc'
  '';

  meta = with lib; {
    description = "The dock component of LingmoOS, built on LingmoUI";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
