{
  config,
  epnixLib,
  lib,
  pkgs,
  external-ports,
  ...
}:
{
  imports = [
    ./archiver-appliance.nix
    ./phoebus-alarm.nix
    ./phoebus-services.nix
    ./ports.nix
    ./reverse-proxy.nix
    ./ioc.nix
  ];

  networking.hostName = "phoebus-ecosystem";

  users.users.root.initialHashedPassword = "";

  environment.epics = {
    ca_addr_list = [ "127.0.0.1" ];
    ca_auto_addr_list = false;
  };

  environment.systemPackages = with pkgs; [
    htop
    tmux
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;
  };

  services.openssh = {
    enable = true;
    ports = [ external-ports.ssh.port ];
    settings = {
      PermitRootLogin = "yes";
      PermitEmptyPasswords = "yes";
    };
  };
  security.pam.services.sshd.allowNullPassword = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  swapDevices = lib.mkVMOverride [
    {
      device = "/var/swapfile";
      size = 2048; # MiB
    }
  ];

  boot.initrd.systemd.enable = true;
  boot.kernel.sysfs.module.zswap.parameters.enabled = true;

  services.getty = {
    greetingLine = ''<< Phoebus ecosystem VM, on NixOS with EPNix ${config.system.nixos.label} (\m) - \l >>'';
    helpLine = ''

      See the EPNix documentation for more information (TODO).'';
  };

  system.nixos.label =
    let
      inherit (epnixLib.inputs) self;
      rev = self.dirtyShortRev or self.shortRev or "unknown";
    in
    "${config.system.nixos.release}-${rev}";

  system.stateVersion = lib.trivial.release;
}
