#!/usr/bin/env python3
"""Patch calamares-nixos-extensions for LingmoNix:

1. packagechooser.conf — add a "Lingmo" desktop option (before the "No desktop" item).
2. modules/nixos/main.py — add a `cfglingmo` desktop config snippet + a mapping,
   and add `nix.settings.experimental-features` (nix-command + flakes) to every
   generated configuration.nix.
"""
import sys

LINGMO_ITEM = '''    - id: lingmo
      packages: [ lingmo ]
      name: Lingmo
      description: "<html>Lingmo is a modern, elegant Qt5-based desktop environment — the LingmoNix desktop.<br/>"
                    "<br/>"
                    "Learn more at <a href=\\"https://lingmo.org/\\">lingmo.org</a></html>"
      screenshot: "/run/current-system/sw/share/calamares/images/lingmo.png"

'''

SNIPPETS = '''cfgexperimental = """  # Enable the nix command and flakes (required for LingmoNix).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

"""

cfglingmo = """  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Lingmo Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.lingmo.enable = true;

"""

'''


def patch_packagechooser(path):
    with open(path) as f:
        src = f.read()
    # Insert the Lingmo item right before the special "no desktop" (id "") item.
    marker = '    - id: ""\n'
    if marker not in src:
        raise SystemExit(f"marker not found in {path}")
    src = src.replace(marker, LINGMO_ITEM + marker, 1)
    with open(path, "w") as f:
        f.write(src)
    print("patched packagechooser:", path)


def patch_main(path):
    with open(path) as f:
        src = f.read()

    # 1. Define the new config snippets right before the first function.
    src = src.replace("def env_is_set(name):", SNIPPETS + "def env_is_set(name):", 1)

    # 2. Map the "lingmo" choice to cfglingmo (after the deepin mapping).
    old = '    elif gs.value("packagechooser_packagechooser") == "deepin":\n        cfg += cfgdeepin\n'
    new = old + '    elif gs.value("packagechooser_packagechooser") == "lingmo":\n        cfg += cfglingmo\n'
    if old not in src:
        raise SystemExit("deepin mapping not found in " + path)
    src = src.replace(old, new, 1)

    # 3. Emit experimental features into every generated configuration.nix.
    old = "    cfg += cfgtail\n"
    if old not in src:
        raise SystemExit("cfgtail not found in " + path)
    src = src.replace(old, "    cfg += cfgexperimental\n" + old, 1)

    with open(path, "w") as f:
        f.write(src)
    print("patched main.py:", path)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: patch-calamares-nixos.py <packagechooser.conf> <main.py>")
    patch_packagechooser(sys.argv[1])
    patch_main(sys.argv[2])
