{ lib, pkgs, ports, ... }:
{
  services = {
    # Phoebus services

    phoebus-olog = {
      enable = true;
      settings = {
        "server.http.enable" = true;
        "server.http.port" = ports.olog.port;

        "demo_auth.enabled" = true;
      };
    };

    phoebus-save-and-restore = {
      enable = true;
      settings = {
        "server.port" = ports.save-restore.port;
        "auth.impl" = "demo";
      };
      openFirewall = true;
    };

    # Phoebus dependencies

    elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch7;
      extraJavaOptions = ["-Xmx256m"];
    };

    # Kafka specified in ./phoebus-alarm.nix
  };

  networking.firewall.allowedTCPPorts = [
    ports.olog.port
    ports.save-restore.port
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];
}
