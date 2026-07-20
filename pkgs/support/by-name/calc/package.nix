{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  sscan,
}:
mkEpicsPackage (finalAttrs: {
  pname = "calc";
  version = "3-7-5";
  varname = "CALC";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "calc";
    tag = "R${finalAttrs.version}";
    sha256 = "sha256-S40HtO7HXDS27u7wmlxuo7oV1abtj1EaXfIz0Kj1IM0=";
  };

  propagatedBuildInputs = [ sscan ];

  meta = {
    description = "Support for run-time expression evaluation";
    homepage = "https://epics-modules.github.io/calc/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
