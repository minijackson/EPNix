{
  services.archiver-appliance = {
    enable = true;
    stores.lts.location = "/srv/lts";
    stores.mts.location = "/srv/mts";

    openFirewall = true;

    settings = {
      EPICS_CA_AUTO_ADDR_LIST = false;
      EPICS_CA_ADDR_LIST = [ "127.0.0.1" ];
    };
  };

  services.tomcat.javaOpts = "-Xmx256m";
}
