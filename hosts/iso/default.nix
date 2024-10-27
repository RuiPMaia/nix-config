{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = "experimental-features = nix-command flakes";
  };

  services = {
    qemuGuest.enable = true;
    openssh.settings.PermitRootLogin = lib.mkForce "yes";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [
      "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"
    ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "pt-latin1";
    earlySetup = true;
  };

  networking = {
    hostName = "iso";
  };

  # gnome power settings do not turn off screen
  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  users.extraUsers.root.password = "nixos";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    password = "nixos";
    shell = pkgs.zsh;
  };
  
  security.sudo.wheelNeedsPassword = false;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.nixos = import ./home.nix;
  };

  programs.zsh.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;   
  services.blueman.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.startx.enable = true;
  # Configure keymap in X11
  services.xserver.xkb.layout = "pt";
  services.xserver.autoRepeatDelay = 300;
  services.xserver.autoRepeatInterval = 20;

  services.getty.autologinUser = "nixos";
}
