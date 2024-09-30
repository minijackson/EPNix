{ pkgs, ... }:

{
  systemd.services.softIoc = {
    wantedBy = [ "multi-user.target" ];

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.epnix.epics-base}/bin/softIoc -S -d ${./test.db}";
      Restart = "always";
      DynamicUser = true;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 5064 ];
    allowedUDPPorts = [ 5064 5065 ];
  };

  environment.systemPackages = with pkgs; [ epnix.epics-base ];
}
