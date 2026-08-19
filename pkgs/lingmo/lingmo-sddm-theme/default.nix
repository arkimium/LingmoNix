{ lib, stdenvNoCC, fetchFromGitHub, cmake }:

# Pure QML + config data (no compiled code), so stdenvNoCC suffices.
# The theme name as seen by SDDM is "lingmo" (share/sddm/themes/lingmo).
stdenvNoCC.mkDerivation {
  pname = "lingmo-sddm-theme";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-sddm-theme";
    rev = "2.7.0";
    hash = "sha256-yxZ3gkZz2ihGc8xY1xyUxODWzdhqwDd1lTMtRwa/vCM=";
  };

  nativeBuildInputs = [ cmake ];

  # Upstream CMake installs to absolute /usr and /etc paths — redirect under $out.
  # (Order matters: /etc/sddm.conf.d/ must be handled before the bare /etc/.)
  # Also disable compiler probing: this is a pure-QML/data package (stdenvNoCC).
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'project(lingmo-sddm-theme)' 'project(lingmo-sddm-theme NONE)' \
      --replace '/usr/share/sddm/themes/lingmo' 'share/sddm/themes/lingmo' \
      --replace '/etc/sddm.conf.d/' 'etc/sddm.conf.d/' \
      --replace 'DESTINATION /etc/' 'DESTINATION etc/'
  '';

  meta = with lib; {
    description = "SDDM theme for LingmoOS (theme name: lingmo)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
