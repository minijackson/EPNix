epnixLib: final: prev: let
  inherit (final) callPackage;
  # From prev, else it somehow causes an infinite recursion
  inherit (prev) recurseIntoAttrs;
  recurseExtensible = f: recurseIntoAttrs (final.lib.makeExtensible f);
in
  recurseIntoAttrs {
    inherit epnixLib;

    mkEpicsPackage = callPackage ./build-support/mk-epics-package.nix {};

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (final: prev: {
          lewis = final.callPackage ./epnix/tools/lewis {};
          pyepics = final.callPackage ./epnix/python-modules/pyepics {};
          scanf = final.callPackage ./epnix/tools/scanf {};
        })
      ];

    linuxKernel =
      prev.linuxKernel
      // {
        packagesFor = kernel:
          (prev.linuxKernel.packagesFor kernel).extend (final: _prev: {
            mrf = final.callPackage ./epnix/kernel-modules/mrf {};
          });
      };

    epnix = recurseExtensible (self: {
      # EPICS base

      epics-base7 = callPackage ./epnix/epics-base {
        version = "7.0.8.1";
        hash = "sha256-JDSMBwBLZj9aaxJHGg0QmZ1zYTSY8J7+ZGihAwEuz3w=";
      };
      epics-base3 = callPackage ./epnix/epics-base {
        version = "3.15.9";
        hash = "sha256-QWScmCEaG0F6OW6LPCaFur4W57oRl822p7wpzbYhOuA=";
      };
      epics-base = self.epics-base7;

      # EPICS support modules

      support = recurseExtensible (_self: {
        adsDriver = callPackage ./epnix/support/adsDriver {};
        asyn = callPackage ./epnix/support/asyn {};
        autoparamDriver = callPackage ./epnix/support/autoparamDriver {};
        autosave = callPackage ./epnix/support/autosave {};
        busy = callPackage ./epnix/support/busy {};
        calc = callPackage ./epnix/support/calc {};
        devlib2 = callPackage ./epnix/support/devlib2 {};
        epics-systemd = callPackage ./epnix/support/epics-systemd {};
        gtest = callPackage ./epnix/support/gtest {};
        ipac = callPackage ./epnix/support/ipac {};
        modbus = callPackage ./epnix/support/modbus {};
        mrfioc2 = callPackage ./epnix/support/mrfioc2 {};
        opcua = callPackage ./epnix/support/opcua {};
        pvxs = callPackage ./epnix/support/pvxs {};
        seq = callPackage ./epnix/support/seq {};
        snmp = callPackage ./epnix/support/snmp {};
        sscan = callPackage ./epnix/support/sscan {};
        StreamDevice = callPackage ./epnix/support/StreamDevice {};
        twincat-ads = callPackage ./epnix/support/twincat-ads {};
      });

      # EPICS related tools and extensions

      archiver-appliance = callPackage ./epnix/tools/archiver-appliance {};

      ca-gateway = callPackage ./epnix/tools/ca-gateway {};

      inherit (final.python3Packages) lewis pyepics;
      inherit (callPackage ./epnix/tools/lewis/lib.nix {}) mkLewisSimulator;

      pcas = callPackage ./epnix/tools/pcas {};

      phoebus = callPackage ./epnix/tools/phoebus/client {};
      phoebus-alarm-server = callPackage ./epnix/tools/phoebus/alarm-server {};
      phoebus-alarm-logger = callPackage ./epnix/tools/phoebus/alarm-logger {};
      phoebus-archive-engine = callPackage ./epnix/tools/phoebus/archive-engine {};
      phoebus-deps = callPackage ./epnix/tools/phoebus/deps {};
      phoebus-olog = callPackage ./epnix/tools/phoebus/olog {};
      phoebus-pva = callPackage ./epnix/tools/phoebus/pva {};
      phoebus-save-and-restore = callPackage ./epnix/tools/phoebus/save-and-restore {};
      phoebus-scan-server = callPackage ./epnix/tools/phoebus/scan-server {};
      phoebus-setup-hook = callPackage ./epnix/tools/phoebus/setup-hook {};
      procServ = callPackage ./epnix/tools/procServ {};

      # Other utilities

      mariadb_jdbc = callPackage ./epnix/tools/mariadb_jdbc {};

      # EPNix specific packages
      docs = callPackage ./docs {};

      # Documentation support packages
      psu-simulator = callPackage ./doc-support/psu-simulator {};
    });
  }
