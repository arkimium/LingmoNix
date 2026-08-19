#!/usr/bin/env bash
# Convert a LingmoOS AUR PKGBUILD into a nixpkgs derivation (libsForQt5 scope).
#
# Usage:
#   tools/pkgbuild2nix.sh path/to/PKGBUILD [repo] [owner]
#
# The PKGBUILDs are uniform (cmake + make install, GitHub release tarball), so
# this emits a ready-to-review default.nix. Unmappable deps become TODO comments.
set -euo pipefail

PKGBUILD=${1:?usage: pkgbuild2nix.sh PKGBUILD [repo] [owner]}
OWNER=${3:-LingmoOS}

# Arch package name -> nixpkgs attr (resolved inside the libsForQt5 scope, with
# base pkgs as fallback, so stdenv/cmake/fetch* also work).
declare -A MAP=(
  # Qt5
  [qt5-base]=qtbase [qt5-tools]=qttools [qt5-declarative]=qtdeclarative
  [qt5-quickcontrols2]=qtquickcontrols2 [qt5-quickcontrols]=qtquickcontrols
  [qt5-x11extras]=qtx11extras
  [qt5-graphicaleffects]=qtgraphicaleffects [qt5-sensors]=qtsensors
  [qt5-location]=qtlocation [qt5-multimedia]=qtmultimedia
  [qt5-webengine]=qtwebengine [qt5-svg]=qtsvg
  # KF5 / Plasma 5
  [extra-cmake-modules]=extra-cmake-modules
  [networkmanager-qt5]=networkmanager-qt [networkmanager-qt]=networkmanager-qt
  [modemmanager-qt5]=modemmanager-qt [modemmanager-qt]=modemmanager-qt
  [bluez-qt5]=bluez-qt [bluez-qt]=bluez-qt
  [libkscreen5]=libkscreen [libkscreen]=libkscreen
  [kio5]=kio [kio]=kio
  [kwindowsystem5]=kwindowsystem [kwindowsystem]=kwindowsystem
  [kcoreaddons5]=kcoreaddons [kcoreaddons]=kcoreaddons
  [kconfig5]=kconfig [kconfig]=kconfig
  [kconfigwidgets5]=kconfigwidgets [kconfigwidgets]=kconfigwidgets
  [kguiaddons5]=kguiaddons [kguiaddons]=kguiaddons
  [kidletime5]=kidletime [kidletime]=kidletime
  [kdecoration5]=kdecoration [kdecoration]=kdecoration
  [syntax-highlighting5]=syntax-highlighting [syntax-highlighting]=syntax-highlighting
  [plasma-framework5]=plasma-framework [plasma-framework]=plasma-framework
  [kwayland]=kwayland [kwin]=kwin [polkit-qt5]=polkit-qt
  # Xorg / misc
  [libqt5xdg]=libqtxdg [libqtxdg]=libqtxdg [libdbusmenu-qt5]=libdbusmenu-qt
  [libx11]=xorg.libX11 [libxcb]=xorg.libxcb [libxcursor]=xorg.libxcursor
  [xorg-server-devel]=xorg.xorgserver
  [xf86-input-libinput]=xorg.xf86inputlibinput
  [xf86-input-synaptics]=xorg.xf86inputsynaptics
  [freetype2]=freetype [fontconfig]=fontconfig [dbus]=dbus [polkit]=polkit
  [mpv]=mpv [sddm]=sddm
  # Lingmo-internal
  [lingmoui]=lingmoui [liblingmo]=liblingmo
)

# Evaluate the PKGBUILD in a clean bash and dump fields (Arch-compatible).
eval_fields() {
  local f=$1
  bash -c 'source "$1"
    printf "pkgname=%s\n" "${pkgname:-}"
    printf "pkgver=%s\n" "${pkgver:-}"
    printf "pkgdesc=%s\n" "${pkgdesc:-}"
    printf "sha256=%s\n" "${sha256sums[0]:-}"
    printf "license=%s\n" "${license[0]:-}"
    printf "depends=%s\n" "${depends[*]:-}"
    printf "makedeps=%s\n" "${makedepends[*]:-}"' _ "$f"
}

declare -A F
while IFS='=' read -r k v; do F[$k]=$v; done < <(eval_fields "$PKGBUILD")

pkgname=${F[pkgname]:-}
pkgver=${F[pkgver]:-}
pkgdesc=${F[pkgdesc]:-}
sha256=${F[sha256]:-}
license=${F[license]:-}
REPO=${2:-$pkgname}   # override for renames, e.g. liblingmo -> lib_lingmo

# Emit canonical SRI (sha256-...) when nix is available; else keep the hex.
if command -v nix >/dev/null 2>&1 && [[ -n "$sha256" ]]; then
  sri=$(nix hash convert --hash-algo sha256 --to sri "$sha256" 2>/dev/null) && sha256=$sri
fi

buildInputs=(); nativeInputs=(); unresolved=()
for d in ${F[depends]:-}; do
  m=${MAP[$d]:-}
  if [[ -n "$m" ]]; then buildInputs+=("$m"); else unresolved+=("$d"); fi
done
for d in ${F[makedeps]:-}; do
  m=${MAP[$d]:-}
  if [[ -n "$m" ]]; then nativeInputs+=("$m"); else unresolved+=("$d"); fi
done
[[ " ${nativeInputs[*]} " == *" extra-cmake-modules "* ]] || nativeInputs+=(extra-cmake-modules)

case "$license" in
  GPL|GPL3|GPL-3|GPL-3.0) nixlicense=gpl3Only ;;
  GPL2|GPL-2|GPL-2.0)     nixlicense=gpl2Only ;;
  LGPL|LGPL3|LGPL-3.0)    nixlicense=lgpl3Only ;;
  LGPL2|LGPL-2.1)         nixlicense=lgpl21Only ;;
  *)                       nixlicense=free ;;
esac

# Deduped function args
args=( lib stdenv fetchFromGitHub cmake "${nativeInputs[@]}" "${buildInputs[@]}" )
mapfile -t args < <(printf '%s\n' "${args[@]}" | awk '!seen[$0]++')

{
  printf -v argsline '%s, ' "${args[@]}"; argsline=${argsline%, }
  echo "{ $argsline }:"
  echo
  echo "stdenv.mkDerivation {"
  echo "  pname = \"$pkgname\";"
  echo "  version = \"$pkgver\";"
  echo
  echo "  src = fetchFromGitHub {"
  echo "    owner = \"$OWNER\";"
  echo "    repo = \"$REPO\";"
  echo "    rev = \"$pkgver\";"
  echo "    hash = \"$sha256\";"
  echo "  };"
  echo
  echo "  nativeBuildInputs = [ cmake $(printf '%s ' "${nativeInputs[@]}")];"
  echo "  buildInputs = [ $(printf '%s ' "${buildInputs[@]}")];"
  echo
  if (( ${#unresolved[@]} )); then
    echo "  # TODO: unresolved Arch deps — map manually:"
    printf '  #   %s\n' "${unresolved[@]}"
  fi
  echo "  meta = with lib; {"
  echo "    description = \"$pkgdesc\";"
  echo "    license = licenses.$nixlicense;"
  echo "    platforms = platforms.linux;"
  echo "  };"
  echo "}"
}
