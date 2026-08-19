{
  description = "LingmoNix — the LingmoOS desktop environment on NixOS";

  # Binary cache for pre-built LingmoNix artifacts (Cachix).
  nixConfig = {
    extra-substituters = [ "https://lingmonix.cachix.org" ];
    extra-trusted-public-keys = [ "lingmonix.cachix.org-1:OraUgITDO2Y9T+FJI4VELvooenUR+RiYiTLn+ExC3T3uYuMZsma1jnwNHjirTiPqyMnO/wMdg4Um5zsc7xXzBA==" ];
  };

  inputs = {
    # Pinned because nixos-25.05 is the last release line that still ships
    # Qt5 / KDE Frameworks 5 / Plasma 5 (KWin 5), which LingmoOS is built on.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
          lingmo-plymouth-theme;
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
            { nixpkgs.overlays = [ self.overlays.default ]; }
          ];
        };
      };
    };
}
