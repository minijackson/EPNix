{
  lib,
  epnixLib,
  stdenv,
  fetchFromGitHub,
  meson,
  pkg-config,
  ninja,
  perl,
  libevent,
  epnix,
}:
stdenv.mkDerivation (final: {
  pname = "pvxs";
  version = "1.1.2";

  # src = fetchFromGitHub {
  #   owner = "mdavidsaver";
  #   repo = "pvxs";
  #   rev = final.version;
  #   hash = "sha256-CAWajeNxjo/Ayk7a+UeNNQ74s1mUV3/VJih5iaDCZW4=";
  # };

  src = fetchFromGitHub {
    owner = "minijackson";
    repo = "pvxs";
    rev = "67a04f2d122e080e958b9aada6f75be483a73397";
    hash = "sha256-LMHHhukji8rm4dqGvBrBoe476oBfUG0lbvoP6y7r8og=";
  };

  # patches = [./meson.patch];
  patches = [./fix-hook.patch];

  mesonFlags = ["-Depics_install_hierarchy=false"];

  outputs = ["out" "dev" "bin"];

  # epics-base also in nativeBuildInputs because of the Perl scripts run at
  # build-time. It might be cleaner to have a separate output? Not completely
  # sure...
  nativeBuildInputs = [epnix.epics-base meson pkg-config ninja perl];
  buildInputs = [epnix.epics-base libevent];

  # doCheck = true;

  meta = {
    description = "PVA protocol client/server library and utilities";
    homepage = "https://mdavidsaver.github.io/pvxs/";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
})
