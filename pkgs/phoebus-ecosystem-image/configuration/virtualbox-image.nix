{
  config,
  lib,
  modulesPath,
  pkgs,
  ports,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/virtualbox-image.nix")
  ];

  virtualbox = {
    vmName = "Phoebus ecosystem";
    vmFileName = "phoebus-ecosystem-epnix-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.ova";
    memorySize = 4096;
    params = {
      cpus = 2;

      nat-pf1 =
        lib.mapAttrsToList (
          name: cfg:
            lib.concatStringsSep "," [
              name
              cfg.proto or "tcp"
              # host ip
              ""
              # host port
              (toString cfg.port)
              # guest ip
              ""
              # guest port
              (toString cfg.port)
            ]
        )
        ports;
    };

    exportParams = [
      "--vsys=0"
      "--description=VM containing the various services used by the Phoebus client"
      "--vendor=EPNix"
      "--version=${config.system.nixos.label}"
    ];
  };
}
