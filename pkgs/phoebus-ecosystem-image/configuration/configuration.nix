{
  config,
  epnixLib,
  lib,
  ...
}: {
  imports = [
    ./archiver-appliance.nix
    ./phoebus-alarm.nix
    ./phoebus-services.nix
    ./ioc.nix
  ];

  _module.args.ports = {
    archiver-appliance.port = 8080;
    alarm-logger.port = 8081;
    save-restore.port = 8082;
    olog.port = 8083;

    apache-kafka.port = 9092;

    ioc = {
      port = 5064;
      proto = "tcp";
    };
    ioc-udp = {
      port = 5064;
      proto = "udp";
    };
  };

  networking.hostName = "phoebus-ecosystem";

  users.users.root.initialHashedPassword = "";

  services.getty = {
    greetingLine = ''<< Phoebus ecosystem VM, on NixOS with EPNix ${config.system.nixos.label} (\m) - \l >>'';
    helpLine = ''

      See the EPNix documentation for more information (TODO).'';
  };

  system.nixos.label = let
    inherit (epnixLib.inputs) self;
    rev = self.dirtyShortRev or self.shortRev or "unknown";
  in "${config.system.nixos.release}-${rev}";

  system.stateVersion = lib.trivial.release;
}
