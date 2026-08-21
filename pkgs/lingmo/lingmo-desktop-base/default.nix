{ lib, stdenvNoCC, fetchFromGitHub }:

# Distro identity metadata (desktop-version, lsb-release, distribution info).
stdenvNoCC.mkDerivation {
  pname = "lingmo-desktop-base";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-desktop-base";
    rev = "main";
    hash = "sha256-PVkJ5CuVD13RSHdN+fvvjiYbPARPkpNVDZLlts7Ax64=";
  };

  buildPhase = ''
    runHook preBuild
    sed -e "s|@@VERSION@@|0.1|g" -e "s|@@RELEASE@@||g" files/desktop-version.in > desktop-version
    sed -e "s|@@VERSION@@|0.1|g" -e "s|@@RELEASE@@||g" files/lsb-release.in > lsb-release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/lingmo" "$out/etc"
    cp desktop-version "$out/share/lingmo/desktop-version"
    cp lsb-release "$out/etc/lsb-release"
    cp files/appstore.json "$out/share/lingmo/appstore.json" 2>/dev/null || true
    runHook postInstall
  '';

  meta = with lib; {
    description = "LingmoOS desktop base (distribution identity metadata)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
