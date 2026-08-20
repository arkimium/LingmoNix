#!/usr/bin/env python3
"""Patch calamares-nixos-extensions for LingmoNix:

1. packagechooser.conf — add a "Lingmo" desktop option (before the "No desktop" item).
2. modules/nixos/main.py — add a `cfglingmo` snippet + mapping that:
   - applies the bundled Lingmo overlay,
   - adds the bundled Lingmo module to the `imports` list,
   - copies the bundled LingmoNix source onto the target,
   and add `nix.settings.experimental-features` (nix-command + flakes) to every
   generated configuration.nix.
"""
import sys

LINGMO_ITEM = '''    - id: lingmo
      packages: [ lingmo ]
      name: Lingmo
      description: "Lingmo is a modern, elegant Qt5-based desktop environment — the LingmoNix desktop."
      screenshot: "/run/current-system/sw/share/calamares/images/lingmo.png"

'''

SNIPPETS = '''cfgexperimental = """  # Enable the nix command and flakes (required for LingmoNix).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

"""

cfglingmo = """  # LingmoNix: apply the bundled Lingmo overlay (relative to this file).
  nixpkgs.overlays = [ (import ./lingmonix/overlays/lingmo.nix) ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Lingmo Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.lingmo.enable = true;

"""

'''

LINGMO_MAPPING = '''    elif gs.value("packagechooser_packagechooser") == "lingmo":
        cfg += cfglingmo
        # Add the bundled Lingmo module to the imports list (relative path).
        cfg = cfg.replace(
            "./hardware-configuration.nix\\n    ];",
            "./hardware-configuration.nix\\n      ./lingmonix/nixos/modules/services/desktops/lingmo\\n    ];",
        )
        # Copy the bundled LingmoNix source onto the target.
        try:
            subprocess.check_output(
                ["mkdir", "-p", root_mount_point + "/etc/nixos"], stderr=subprocess.STDOUT
            )
            subprocess.check_output(
                ["cp", "-r", "/run/current-system/sw/share/lingmonix", root_mount_point + "/etc/nixos/lingmonix"],
                stderr=subprocess.STDOUT,
            )
        except subprocess.CalledProcessError as e:
            libcalamares.utils.error("Failed to copy LingmoNix source: {}".format(e.output))
            return (_("LingmoNix source copy failed"), _("Check the installer log for details."))
'''


def patch_packagechooser(path):
    with open(path) as f:
        src = f.read()
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

    # 2. Map the "lingmo" choice to cfglingmo + copy the bundled source.
    old = '    elif gs.value("packagechooser_packagechooser") == "deepin":\n        cfg += cfgdeepin\n'
    if old not in src:
        raise SystemExit("deepin mapping not found in " + path)
    src = src.replace(old, old + LINGMO_MAPPING, 1)

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
