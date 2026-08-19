{ lib, stdenvNoCC, brandingAssets }:

# Ships the LingmoOS logo as the system's default "distributor-logo" icon,
# so Qt/KDE/GTK apps, the launcher, and the control center's "About" show it.
stdenvNoCC.mkDerivation {
  pname = "lingmo-branding";
  version = "1.0.0";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons/hicolor/scalable/apps" \
             "$out/share/icons/hicolor/symbolic/apps" \
             "$out/share/icons/hicolor/256x256/apps" \
             "$out/share/pixmaps"

    # Distribution logo (clean icon, no text): icon name "lingmo".
    cp "${brandingAssets}/lingmo-logo.png" \
       "$out/share/icons/hicolor/256x256/apps/lingmo.png"

    # Freedesktop distributor-logo (vector + symbolic) from the Lingmo plymouth logo
    cp "${brandingAssets}/lingmo-logo.svg" \
       "$out/share/icons/hicolor/scalable/apps/distributor-logo.svg"
    ln -s ../../scalable/apps/distributor-logo.svg \
          "$out/share/icons/hicolor/symbolic/apps/distributor-logo-symbolic.svg"

    # Raster fallback for panels/pixmaps
    cp "${brandingAssets}/lingmo-text-logo.png" \
       "$out/share/pixmaps/distributor-logo.png"

    runHook postInstall
  '';

  meta = with lib; {
    description = "LingmoOS branding — LingmoNix distributor logo";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
