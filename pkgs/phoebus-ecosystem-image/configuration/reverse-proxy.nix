{
  external-ports,
  internal-ports,
  lib,
  ...
}:
{
  services.caddy = {
    enable = true;
    virtualHosts = lib.mapAttrs' (name: port: {
      name = "http://${name}.localhost:${toString external-ports.reverse-proxy.port}";
      value.extraConfig = ''
        reverse_proxy localhost:${toString port.port}
      '';
    }) internal-ports;
  };

  networking.firewall.allowedTCPPorts = [ external-ports.reverse-proxy.port ];
}
