{
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  ipAddress = "192.168.200.1";

  ports = {
    alarm-logger = 8080;
    save-restore = 8081;

    apache-kafka = 9092;
  };

  kafkaListenSockAddr = "${ipAddress}:${toString ports.apache-kafka}";
  kafkaControllerListenSockAddr = "${ipAddress}:9093";
in {
  imports = [
    (modulesPath + "/virtualisation/virtualbox-image.nix")
  ];

  # Services

  services = {
    # Phoebus services

    phoebus-alarm-server = {
      enable = true;
      openFirewall = true;
      settings."org.phoebus.applications.alarm/server" = kafkaListenSockAddr;
    };

    phoebus-alarm-logger.settings = {
      "server.port" = ports.alarm-logger;
      "bootstrap.servers" = kafkaListenSockAddr;
    };

    phoebus-save-and-restore = {
      enable = true;
      settings."server.port" = ports.save-restore;
      openFirewall = true;
    };

    # Phoebus dependencies

    apache-kafka = {
      enable = true;
      # Randomly generated uuid got by running:
      # nix shell 'nixpkgs#apacheKafka' -c kafka-storage.sh random-uuid
      clusterId = "8MEBIhkRS963am5l4DsQlQ";
      formatLogDirs = true;
      settings = {
        listeners = [
          "PLAINTEXT://${kafkaListenSockAddr}"
          "CONTROLLER://${kafkaControllerListenSockAddr}"
        ];
        # Adapt depending on your security constraints
        "listener.security.protocol.map" = [
          "PLAINTEXT:PLAINTEXT"
          "CONTROLLER:PLAINTEXT"
        ];
        "controller.quorum.voters" = [
          "1@${kafkaControllerListenSockAddr}"
        ];
        "controller.listener.names" = ["CONTROLLER"];

        "node.id" = 1;
        "process.roles" = [
          "broker"
          "controller"
        ];

        "log.dirs" = ["/var/lib/apache-kafka"];
        "offsets.topic.replication.factor" = 1;
        "transaction.state.log.replication.factor" = 1;
        "transaction.state.log.min.isr" = 1;
      };
    };

    elasticsearch = {
      enable = true;
      package = pkgs.elasticsearch7;
    };
  };

  systemd.services.apache-kafka.unitConfig.StateDirectory = "apache-kafka";

  users.users.root.initialHashedPassword = "";

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "elasticsearch"
    ];

  # Networking

  networking.useDHCP = false;
  networking.interfaces.enp0s3 = {
    ipv4.addresses = [
      {
        address = ipAddress;
        prefixLength = 24;
      }
    ];
  };

  # VirtualBox image configuration

  virtualbox = {
    vmName = "Phoebus ecosystem training";
    memorySize = 2048;
    params = {
      nat-net1 = "192.168.200.0/24";
      nat-pf1 = let
        forwarded-ports = [
          {
            name = "phoebus-alarm-logger";
            guest-port = toString ports.alarm-logger;
          }

          {
            name = "phoebus-save-and-restore";
            guest-port = toString ports.save-restore;
          }

          {
            name = "apache-kafka";
            guest-port = toString ports.apache-kafka;
          }
        ];
      in
        lib.map (
          forwarded-port:
            lib.concatStringsSep "," [
              forwarded-port.name
              forwarded-port.protocol or "tcp"
              forwarded-port.host-ip or ""
              forwarded-port.host-port or forwarded-port.guest-port
              forwarded-port.guest-ip or ipAddress
              forwarded-port.guest-port
            ]
        )
        forwarded-ports;
    };
  };

  system.stateVersion = lib.trivial.release;
}
