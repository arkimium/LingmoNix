{ lib, stdenvNoCC, brandingAssets }:

# Pure data: the Calamares "lingmonix" branding (branding.desc + logo images).
stdenvNoCC.mkDerivation {
  pname = "lingmo-calamares-branding";
  version = "0.1";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    dir="$out/share/calamares/branding/lingmonix"
    mkdir -p "$dir"
    cp "${./branding.desc}" "$dir/branding.desc"
    cp "${brandingAssets}/lingmo-logo.svg" "$dir/lingmo-logo.svg"
    runHook postInstall
  '';

  meta = with lib; {
    description = "LingmoNix Calamares installer branding";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
