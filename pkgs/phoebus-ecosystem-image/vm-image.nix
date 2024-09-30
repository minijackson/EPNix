{ ports, ... }:

{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/virtualbox-image.nix")
  ];

  virtualbox = {
    # TODO: change that
    vmName = "Phoebus services ecosystem";
    memorySize = 4096;
    params = {
      cpus = 2;

      nat-pf1 =
        let
          forwarded-ports =
            (lib.mapAttrsToList (name: port: {
              inherit name;
              guest-port = toString port;
            }) ports)
            ++ [
              {
                name = "ioc";
                guest-port = "5064";
                protocol = "tcp";
              }

              {
                name = "ioc-udp";
                guest-port = "5064";
                protocol = "udp";
              }

              # {
              #   name = "ioc-beacon";
              #   guest-port = "5065";
              #   protocol = "udp";
              # }
            ];
        in
        lib.map (
          forwarded-port:
          lib.concatStringsSep "," [
            forwarded-port.name
            forwarded-port.protocol or "tcp"
            forwarded-port.host-ip or ""
            forwarded-port.host-port or forwarded-port.guest-port
            forwarded-port.guest-ip or ""
            forwarded-port.guest-port
          ]
        ) forwarded-ports;
    };

    exportParams = [
      "--vsys=0"
      "--description=VM containting the various services used by the Phoebus client"
      "--vendor=EPNix"
      # TODO: move that to somewhere in epnixLib
      "--version=24.11"
    ];
  };

  system.stateVersion = lib.trivial.release;
}
