{ ports, ... }:
{ lib, pkgs, ... }:
{
  services = {
    # Phoebus services

    phoebus-save-and-restore = {
      enable = true;
      settings."server.port" = ports.save-restore;
      openFirewall = true;
    };

    phoebus-olog = {
      enable = true;
      settings = {
        "server.http.enable" = true;
        "server.http.port" = ports.olog;

        "demo_auth.enabled" = true;
      };
    };

    # Phoebus dependencies

    elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch7;
    };

    # Kafka specified in ./phoebus-alarm.nix
  };

  networking.firewall.allowedTCPPorts = [
    ports.olog
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];
}
