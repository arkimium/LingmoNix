{ lib, stdenv, fetchFromGitHub, cmake, wrapQtAppsHook, qtbase, qttools }:

stdenv.mkDerivation {
  pname = "lingmo-installer-firstboot";
  # Project version in CMakeLists; no git tags upstream.
  version = "1.0";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-installer-firstboot";
    rev = "134ef5871ee35151eab402f67ef90cea1aeb008b";
    hash = "sha256-vpdwjYEaVMioduiaNTDDXXYeowzKy0/gRznRgQ4S1Nk=";
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook qttools ]; # qttools -> Qt6 LinguistTools
  buildInputs = [ qtbase ];

  # Upstream installs to absolute /etc, /lib and /usr paths — redirect under $out.
  # (The NixOS module can later wire autostart/systemd units from there.)
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '/etc/xdg/autostart' 'etc/xdg/autostart' \
      --replace '/etc/polkit-1/rules.d' 'etc/polkit-1/rules.d' \
      --replace '/lib/systemd/system' 'lib/systemd/system' \
      --replace '/usr/lib/lingmo-oobe' 'lib/lingmo-oobe' \
      --replace '/usr/share/xsessions' 'share/xsessions' \
      --replace '/usr/share/wayland-sessions' 'share/wayland-sessions'
  '';

  meta = with lib; {
    description = "First-boot OOBE wizard for Lingmo OS (Qt6)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
