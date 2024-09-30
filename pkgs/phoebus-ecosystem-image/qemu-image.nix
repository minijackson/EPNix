{epnixLib}: let
  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.phoebus-ecosystem
      ./configuration/qemu-image.nix
    ];
  };

  image = finalSystem.config.system.build.vm;
in
  image
