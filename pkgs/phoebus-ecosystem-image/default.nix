{epnixLib}: let
  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.nixos
      ./configuration.nix
    ];
  };

  image = finalSystem.config.system.build.virtualBoxOVA;
in
  image
