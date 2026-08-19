{ lib, stdenv, fetchFromGitHub, cmake, extra-cmake-modules
, qtbase, qtsensors, qtquickcontrols2
, networkmanager-qt, modemmanager-qt, bluez-qt, libkscreen, kio, libcanberra
, libpulseaudio, sound-theme-freedesktop
}:

stdenv.mkDerivation {
  pname = "liblingmo";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lib_lingmo"; # AUR `liblingmo` -> source repo `lib_lingmo`
    rev = "1.10.1";
    hash = "sha256-iukZFkKWIHrmfVf6pSI9M/IJWVZ3BLpaTflcMQCpEIk=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];
  buildInputs = [
    qtbase qtsensors qtquickcontrols2
    networkmanager-qt modemmanager-qt bluez-qt libkscreen kio libcanberra
    libpulseaudio sound-theme-freedesktop
  ];

  # nixpkgs Qt5's qmake reports the QML dir as an unexpanded placeholder
  # (/build/.../$(out)/$(qtQmlPrefix)), so CMake would install the QML plugins
  # to that literal path instead of $out. Point it at qtbase's real relative prefix.
  postPatch = ''
    sed -i '/execute_process(COMMAND/,/^[[:space:]]*)$/c\set(INSTALL_QMLDIR "${qtbase.qtQmlPrefix}")' CMakeLists.txt
  '';

  dontWrapQtApps = true;

  meta = with lib; {
    description = "System library for Lingmo applications";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
