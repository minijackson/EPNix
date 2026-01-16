{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage (finalAttrs: {
  pname = "RecCaster";
  version = "1.9.2";
  varname = "RECCASTER";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "recsync";
    tag = finalAttrs.version;
    hash = "sha256-Iq+w0QV02tVsaVIQu+mWU4h8L0c7QXi9pB8P0nQmVmg=";
  };

  sourceRoot = "${finalAttrs.src.name}/client";

  patches = [ ./fix-example-shebang.patch ];

  meta = {
    description = "Informs ChannelFinder of the state of the IOC and the list of PVs contained in that IOC";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
