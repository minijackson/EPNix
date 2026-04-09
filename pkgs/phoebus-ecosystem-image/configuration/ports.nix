{
  _module.args = {
    # These will be exposed as-is outside of the VM
    external-ports = {
      # N  i  x
      # 14 9  24
      reverse-proxy.port = 14924;

      apache-kafka.port = 9092;

      ioc = {
        port = 5064;
        proto = "tcp";
      };
      ioc-udp = {
        port = 5064;
        proto = "udp";
      };

      ssh.port = 2222;
    };

    # These will get reverse-proxied
    # for example to "archiver-appliance.localhost:14924"
    internal-ports = {
      archiver-appliance.port = 8080;
      alarm-logger.port = 8081;
      save-restore.port = 8082;
      olog.port = 8083;
      channel-finder.port = 8084;
    };
  };
}
