{
  services.archiver-appliance = {
    enable = true;
    stores.lts.location = "/srv/lts";
    stores.mts.location = "/srv/mts";
  };

  services.tomcat.javaOpts = "-Xmx256m";
}
