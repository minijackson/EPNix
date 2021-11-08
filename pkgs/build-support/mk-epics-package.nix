{ stdenv, lib, runCommand, clang, perl, epnix, buildPackages, pkgsBuildBuild, ... }:

{ pname
, varname
, local_config_site ? { }
, local_release ? { }
, isEpicsBase ? false
, nativeBuildInputs ? [ ]
, buildInputs ? [ ]
, makeFlags ? [ ]
, preBuild ? ""
, ...
} @ attrs:

with lib;
let
  inherit (buildPackages) epnixLib;

  # remove non standard attributes that cannot be coerced to strings
  overridable = builtins.removeAttrs attrs [ "local_config_site" "local_release" ];
  generateConf = (epnixLib.formats.make { }).generate;

  # "build" as in Nix terminology (the build machine)
  build_arch = epnixLib.toEpicsArch stdenv.buildPlatform;
  # "host" as in Nix terminology (the machine which will run the generated code)
  host_arch = epnixLib.toEpicsArch stdenv.hostPlatform;
in
stdenv.mkDerivation (overridable // {
  strictDeps = true;

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = nativeBuildInputs ++ [ perl ];
  buildInputs = buildInputs ++ (optional (!isEpicsBase) [ epnix.epics-base ]);

  makeFlags = makeFlags ++ [
    "INSTALL_LOCATION=${placeholder "out"}"
  ] ++ optional
    (stdenv.buildPlatform != stdenv.hostPlatform)
    "CROSS_COMPILER_TARGET_ARCHS=${host_arch}";

  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  dontConfigure = true;

  # "build" as in Nix terminology (the build machine)
  build_config_site = generateConf
    "CONFIG_SITE.${build_arch}.${build_arch}"
    (with buildPackages.stdenv; {
      CC = "${cc.targetPrefix}cc";
      CCC = "${cc.targetPrefix}c++";
      CXX = "${cc.targetPrefix}c++";

      AR = "${cc.bintools.targetPrefix}ar";
      LD = "${cc.bintools.targetPrefix}ld";
      RANLIB = "${cc.bintools.targetPrefix}ranlib";

      ARFLAGS = "rc";
    } // optionalAttrs stdenv.cc.isClang {
      GNU = "NO";
      CMPLR_CLASS = "clang";
    });

  # "host" as in Nix terminology (the machine which will run the generated code)
  host_config_site = generateConf
    "CONFIG_SITE.${build_arch}.${host_arch}"
    (with stdenv; {
      CC = "${cc.targetPrefix}cc";

      CCC = if stdenv.cc.isClang then "${cc.targetPrefix}clang++" else "${cc.targetPrefix}c++";
      CXX = if stdenv.cc.isClang then "${cc.targetPrefix}clang++" else "${cc.targetPrefix}c++";

      AR = "${cc.bintools.targetPrefix}ar";
      LD = "${cc.bintools.targetPrefix}ld";
      RANLIB = "${cc.bintools.targetPrefix}ranlib";

      ARFLAGS = "rc";
    } // optionalAttrs stdenv.cc.isClang {
      GNU = "NO";
      CMPLR_CLASS = "clang";
    });

  local_config_site = generateConf "CONFIG_SITE.local" local_config_site;

  # Undefine the SUPPORT variable here, since there is no single "support"
  # directory and this variable is a source of conflicts between RELEASE files
  local_release = generateConf "RELEASE.local" (local_release // { SUPPORT = null; });

  preBuild = (optionalString isEpicsBase ''
    cp -fv --no-preserve=mode "$build_config_site" configure/os/CONFIG_SITE.${build_arch}.${build_arch}
    cp -fv --no-preserve=mode "$host_config_site" configure/os/CONFIG_SITE.${build_arch}.${host_arch}
  '') + ''
    cp -fv --no-preserve=mode "$local_config_site" configure/CONFIG_SITE.local
    cp -fv --no-preserve=mode "$local_release" configure/RELEASE.local

    # set to empty if unset
    : ''${EPICS_COMPONENTS=}

    IFS=: read -a components <<<$EPICS_COMPONENTS

    for component in "''${components[@]}"; do
      echo "$component"
      echo "$component" >> configure/RELEASE.local
    done

  '' + preBuild;
})
