{ config, modulesPath, pkgs, ... }: {
  # Minimal bootable LingmoNix test system (QEMU guest via system.build.vm).
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  # Minimal filesystem + boot config so the toplevel is valid.
  fileSystems."/" = {
    device = "/dev/vda";
    fsType = "ext4";
  };
  boot.loader.grub.devices = [ "nodev" ]; # VM boots via run-nixos-vm, no real bootloader

  services.desktopManager.lingmo.enable = true;

  users.users.demo = {
    isNormalUser = true;
    initialPassword = "demo";
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "25.05";
}
