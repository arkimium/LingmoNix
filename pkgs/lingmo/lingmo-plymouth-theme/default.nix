{ lib, stdenvNoCC, fetchFromGitHub }:

# Pure data (plymouth theme = script + images), so stdenvNoCC suffices.
stdenvNoCC.mkDerivation {
  pname = "lingmo-plymouth-theme";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-plymouth-theme";
    rev = "2.0.1";
    hash = "sha256-TaSX8dHk4dKPr+elqmTi/5qSCl/ie0XmcRNco46xzz0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/plymouth/themes"
    cp -r lingmo-plymouth "$out/share/plymouth/themes/"
    cp -r lingmo-text "$out/share/plymouth/themes/"

    # The graphical theme's .plymouth descriptor hardcodes /usr paths for
    # ImageDir/ScriptFile — point them at this store path.
    substituteInPlace "$out/share/plymouth/themes/lingmo-plymouth/lingmo-plymouth.plymouth" \
      --replace '/usr/share/plymouth/themes/lingmo-plymouth' "$out/share/plymouth/themes/lingmo-plymouth"

    runHook postInstall
  '';

  meta = with lib; {
    description = "LingmoOS Plymouth boot theme (graphical + text)";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
