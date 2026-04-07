{ epnixLib }:
let
  finalSystem = epnixLib.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      epnixLib.inputs.self.nixosModules.default
      epnixLib.inputs.self.nixosModules.phoebus-ecosystem
      ./virtualbox-configuration.nix
    ];
  };

  image = finalSystem.config.system.build.virtualBoxOVA;
in
image
// {
  passthru = image.passthru or { } // {
    inherit (finalSystem) config;
  };
}
