{ epnixLib }:
let
  # TODO: documenter
  # - redémarrer VirtualBox entièrement si problème de NAT
  # - vérifier si aucun programme n'écoute sur les ports listés
  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.phoebus-ecosystem
      ./virtualbox-configuration.nix
    ];
  };

  image = finalSystem.config.system.build.virtualBoxOVA;
in
image
