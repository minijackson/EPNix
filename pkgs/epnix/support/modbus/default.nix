{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
}:
mkEpicsPackage rec {
  pname = "modbus";
  version = "3-3";
  varname = "MODBUS";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = pname;
    rev = "R${version}";
    hash = "sha256-KPk+SKR/Mpwg2xCkf9k8v2CYz+IvEa/6ceWMtYX+fLQ=";
  };

  propagatedBuildInputs = with epnix.support; [asyn];

  meta = {
    description = "EPICS support for communication with PLCs and other devices via the Modbus protocol";
    homepage = "https://epics-modbus.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
