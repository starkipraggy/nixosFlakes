# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/microsoft/surface-pro/9>
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  time.hardwareClockInLocalTime = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  i18n.inputMethod = {
   type = "fcitx5";
   enable = true;
   fcitx5.addons = with pkgs; [
     fcitx5-mozc
     fcitx5-gtk
     fcitx5-chinese-addons
   ];
 };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fezirix = {
    isNormalUser = true;
    description = "fezirix";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      ((pkgs.vivaldi.overrideAttrs (oldAttrs: {
        buildPhase = builtins.replaceStrings
          ["for f in libGLESv2.so libqt5_shim.so ; do"]
          ["for f in libGLESv2.so libqt5_shim.so libqt6_shim.so ; do"]
          oldAttrs.buildPhase
        ;
      })).override {
        qt5 = pkgs.qt6;
        commandLineArgs = [ "--ozone-platform=wayland" ];
        # The following two are just my preference, feel free to leave them out
        proprietaryCodecs = true;
        enableWidevine = true;
      })
      telegram-desktop



    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    maliit-keyboard
    maliit-framework
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  systemd.user.services.virtualKeyboardAutoswitch = {
    description = "...";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      #!/usr/bin/env bash
      switch() {
          echo "Starting $1"
          kwriteconfig6 --file kwinrc --group Wayland --key InputMethod "$1"
          busctl --user emit /kwinrc org.kde.kconfig.notify ConfigChanged "a{saay}" 1 Wayland 1 11 73 110 112 117 116 77 101 116 104 111 100
      }

      busctl --user monitor --match "type='signal',interface='org.kde.KWin.TabletModeManager',member='tabletModeChanged'" | \
      while read -r line; do
          if [[ $line == *"true"* ]]; then
              switch /usr/share/applications/com.github.maliit.keyboard.desktop
          elif [[ $line == *"false"* ]]; then
              switch /usr/share/applications/fcitx5-wayland-launcher.desktop
          fi
      done
    '';
    wantedBy = [ "multi-user.target" ]; # starts after login
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
