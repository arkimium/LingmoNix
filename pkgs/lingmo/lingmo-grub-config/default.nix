{ lib, stdenvNoCC, fetchFromGitHub }:

# Pure data (GRUB theme + splash image), so stdenvNoCC + manual install.
stdenvNoCC.mkDerivation {
  pname = "lingmo-grub-config";
  version = "2.0.0-lingmo-a4";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-grub-config";
    rev = "2.0.0-lingmo-a4";
    hash = "sha256-+x0x5JmdCitTkp4RyxsSkvCGhTXs9USM2rk/DEBFlNs=";
  };

  # Upstream CMake installs `boot/` to `/`; instead install under $out/grub,
  # matching NixOS's `boot.loader.grub.theme` convention (theme dir + splash).
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/grub"
    cp -r boot/grub/themes "$out/grub/themes"
    cp boot/grub/splash.png "$out/grub/splash.png"
    runHook postInstall
  '';

  meta = with lib; {
    description = "LingmoOS GRUB theme (boot splash + theme)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
