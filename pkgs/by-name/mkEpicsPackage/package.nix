{
  stdenv,
  lib,
  makeWrapper,
  perl,
  epnix,
  buildPackages,
  readline,
  ...
}:

let
  generateConf = (buildPackages.epnixLib.formats.make { }).generate;
in
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [ "isEpicsBase" ];
  extendDrvArgs =
    finalAttrs:
    {
      varname,
      epics-base ? epnix.epics-base,
      local_config_site ? { },
      local_release ? { },
      isEpicsBase ? false,

      depsBuildBuild ? [ ],
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      shellHook ? "",
      ...
    }@attrs:
    let
      varname' = finalAttrs.varname or varname;
      epics-base' = finalAttrs.epics-base or epics-base;
      local_config_site' = finalAttrs.local_config_site or local_config_site;
      local_release' = finalAttrs.local_release or local_release;
    in
    {
      __structuredAttrs = true;

      strictDeps = true;

      # When cross-compiling,
      # epics will build every project twice,
      # once "build -> build", and once "build -> host",
      # so we need a compiler for the "build -> build" compilation.
      depsBuildBuild = depsBuildBuild ++ [ buildPackages.stdenv.cc ];

      nativeBuildInputs = nativeBuildInputs ++ [
        makeWrapper
        perl
        readline
        epnix.epicsSetupHook
      ];

      # Also add perl into the non-native build inputs
      # so that shebangs gets patched
      buildInputs =
        buildInputs
        ++ [
          perl
          readline
        ]
        ++ (lib.optional (!isEpicsBase) epics-base');

      setupHook = ./setup-hook.sh;

      local_config_site_text = generateConf local_config_site';
      local_release_text = generateConf local_release';

      env = {
        # Make sure to put the `varname` inside `env`,
        # else it doesn't get exported
        # and the `setupHook` can't see it.
        # It can't also be named `varname`,
        # since it will clash with the `varname` passed
        # to the toplevel derivation arguments.
        component_varname = varname';
      };

      doCheck = attrs.doCheck or true;
      checkTarget = "runtests";

      shellHook = ''
        ${lib.optionalString (!isEpicsBase) ''
          # epics-base is considered a "buildInputs",
          # not a "nativeBuildInputs",
          # so it needs to be manually added in to the PATH
          # in a development shell,
          addToSearchPath PATH "${epics-base'}/bin"
        ''}

        ${shellHook}
      '';
    };
}
