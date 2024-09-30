{ epnixLib }:
let
  ports = {
    archiver-appliance = 8080;
    alarm-logger = 8081;
    save-restore = 8082;
    olog = 8083;

    apache-kafka = 9092;
  };

  args = { inherit ports; };

  # TODO: documenter
  # - redémarrer VirtualBox entièrement si problème de NAT
  # - vérifier si aucun programme n'écoute sur les ports listés

  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.nixos
      (import ./configuration.nix args)

      (import ./archiver-appliance.nix args)
      (import ./phoebus-alarm.nix args)
      (import ./phoebus-services.nix args)
      (import ./ioc.nix args)

      (import ./vm-image.nix args)
    ];
  };

  image = finalSystem.config.system.build.virtualBoxOVA;
in
image
