{
  config,
  epnixLib,
  lib,
  modulesPath,
  pkgs,
  external-ports,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/virtualbox-image.nix")
  ];

  image.baseName = "phoebus-ecosystem-epnix-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

  virtualbox = {
    vmName = "Phoebus ecosystem";
    memorySize = 4096;
    params = {
      cpus = 2;

      nat-pf1 = lib.mapAttrsToList (
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
      ) external-ports;
    };

    exportParams = [
      "--vsys=0"
      "--description=VM containing the various services used by the Phoebus client"
      "--vendor=EPNix"
      "--version=${config.system.nixos.label}"
    ];
  };

  # Install the `./configuration` directory into `/etc/nixos`,
  # so that users can rebuild and change the configuration of the VM.
  boot.postBootCommands = ''
    ${lib.getExe (
      pkgs.writeShellApplication {
        name = "install-nixos-config";
        runtimeInputs = [ pkgs.envsubst ];
        runtimeEnv = {
          EPNIX_BRANCH = epnixLib.versions.current-branch;
          # EPNix points Nixpkgs at the same branch than the stable EPNix branch
          EPNIX_STABLE = epnixLib.versions.stable;
          HOSTNAME = config.networking.hostName;
        };

        text = ''
          shopt -s nullglob

          filesInNixOSDir=(/etc/nixos/* /etc/nixos/.*)
          if (( "''${#filesInNixOSDir[@]}" == 0 )); then
            cp -rT --no-preserve=mode ${./configuration} /etc/nixos
            envsubst -i /etc/nixos/flake.nix -o /etc/nixos/flake.nix
          fi
        '';
      }
    )}
  '';
}
