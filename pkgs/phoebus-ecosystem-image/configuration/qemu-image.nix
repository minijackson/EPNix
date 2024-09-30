{
  lib,
  ports,
  ...
}: {
  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 2;
    msize = 16384 * 4;

    forwardPorts =
      lib.mapAttrsToList (_name: cfg: {
        host.port = cfg.port;
        guest.port = cfg.port;
        proto = cfg.proto or "tcp";
      })
      ports;
  };
}
