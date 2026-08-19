{
  description = "LingmoNix — the LingmoOS desktop environment on NixOS";

  # Binary caches: USTC mirror of the nix store + LingmoNix Cachix.
  nixConfig = {
    extra-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://lingmonix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "lingmonix.cachix.org-1:OraUgITDO2Y9T+FJI4VELvooenUR+RiYiTLn+ExC3T3uYuMZsma1jnwNHjirTiPqyMnO/wMdg4Um5zsc7xXzBA=="
    ];
  };

  inputs = {
    # Pinned because nixos-25.05 is the last release line that still ships
    # Qt5 / KDE Frameworks 5 / Plasma 5 (KWin 5), which LingmoOS is built on.
    # Fetched from the USTC mirror (channel source) instead of GitHub.
    nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixos-25.05/nixexprs.tar.xz";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      overlays.default = import ./overlays/lingmo.nix;

      nixosModules = {
        lingmo = import ./nixos/modules/services/desktops/lingmo;
        default = self.nixosModules.lingmo;
      };

      packages.${system} = {
        inherit (pkgs.lingmo)
          branding
          lingmo-calamares-branding
          liblingmo
          lingmoui
          lingmo-qt-plugins
          lingmo-kwin-plugins
          lingmo-core
          lingmo-screenlocker
          lingmo-dock
          lingmo-launcher
          lingmo-statusbar
          lingmo-settings
          lingmo-filemanager
          lingmo-screenshots
          lingmo-terminal
          lingmo-texteditor
          lingmo-videoplayer
          lingmo-calculator
          lingmo-cursor-themes
          lingmo-gtk-themes
          lingmo-sddm-theme
          lingmo-systemicons
          lingmo-wallpapers
          lingmo-plymouth-theme
          lingmo-grub-config;
        inherit (pkgs.lingmo-qt6)
          lingmo-appearance
          lingmo-installer-firstboot;

        # ISOs — `nix build .#iso` (minimal) / `nix build .#iso-live` (full live).
        iso = self.nixosConfigurations.lingmonix-iso-minimal.config.system.build.isoImage;
        iso-live = self.nixosConfigurations.lingmonix-iso-live.config.system.build.isoImage;
      };

      # Example bootable system (for `nix build .#nixosConfigurations.lingmonix.config.system.build.vm`)
      nixosConfigurations = {
        lingmonix = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.lingmo
            ./nixos/example.nix
            # Make pkgs.lingmo / pkgs.lingmo-qt6 available to the module.
            { nixpkgs.overlays = [ self.overlays.default ]; }
          ];
        };

        # Minimal ISO: minimal installer base + full Lingmo module (nixos/iso-minimal.nix).
        lingmonix-iso-minimal = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.lingmo
            ./nixos/iso-minimal.nix
            { nixpkgs.overlays = [ self.overlays.default ]; }
          ];
        };

        # Full live ISO: graphical base + full Lingmo desktop (nixos/iso-live.nix).
        lingmonix-iso-live = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.lingmo
            ./nixos/iso-live.nix
            {
              nixpkgs.overlays = [ self.overlays.default ];
              # Expose the flake source so the installer can bundle the Lingmo
              # module + overlay onto the target system.
              _module.args.lingmonix-flake = self;
            }
          ];
        };
      };
    };
}
