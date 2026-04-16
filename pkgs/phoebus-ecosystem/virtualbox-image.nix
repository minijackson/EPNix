{ epnixLib }:
let
  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.default
      epnixLib.inputs.self.nixosModules.phoebus-ecosystem
    ];
  };
in
finalSystem.config.system.build.images.virtualbox
