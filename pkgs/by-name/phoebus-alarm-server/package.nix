{
  lib,
  epnixLib,
  stdenv,
  maven,
  makeWrapper,
  phoebus-deps,
  phoebus-setup-hook,
}:
let
  buildDate = "2022-02-24T07:56:00Z";
in
stdenv.mkDerivation {
  pname = "phoebus-alarm-server";
  inherit (phoebus-deps) version src;

  # Use larger heap size, necessary for building the alarm server
  MAVEN_OPTS = "-Xmx1G";

  nativeBuildInputs = [
    maven
    makeWrapper
    phoebus-setup-hook
  ];

  buildPhase = ''
    runHook preBuild

    # Copy deps to a writable directory, due to the usage of "install-jars"
    local deps=$PWD/deps
    cp -r --no-preserve=mode "${phoebus-deps}" $deps

    # TODO: tests fail
    mvn package \
      --projects "./services/alarm-server" \
      --also-make \
      --offline \
      -Dmaven.javadoc.skip=true -Dmaven.source.skip=true -Dmaven.test.skip \
      -Dproject.build.outputTimestamp=${buildDate} \
      -Dmaven.repo.local="$deps"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    installPhoebusJar \
      "services/alarm-server" \
      "service-alarm-server-$version.jar" \
      "phoebus-alarm-server" \
      "org.phoebus.applications.alarm.server.AlarmServerMain"

    runHook postInstall
  '';

  meta = {
    description = "Monitor a configurable set of PVs and track their alarm state";
    homepage = "https://control-system-studio.readthedocs.io/en/latest/services/alarm-server/doc/index.html";
    mainProgram = "phoebus-alarm-server";
    license = lib.licenses.epl10;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (phoebus-setup-hook.meta) platforms;
  };
}
