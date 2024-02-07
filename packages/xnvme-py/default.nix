{ python3Packages, xnvme, substituteAll }:
let
  buildPythonPackage = python3Packages.buildPythonPackage;
  fetchPypi = python3Packages.fetchPypi;

in buildPythonPackage rec {
  pname = "xnvme";
  version = "${xnvme.version}";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-eK92ijOrVMw4lmh9G8Pg3mVD4OvzQsNmOQBN2p3dNNs=";
  };

  patches = [
    # in nix, we resolve paths to libraries at build-time
    # this ensures the package functions the same regardless of the (dev/os)environment
    (substituteAll {
      src = ./load-xnvme-library.patch;
      libxnvme = "${xnvme}/lib/libxnvme.so";
    })
  ];

  doCheck = false;

  propagatedBuildInputs =
    [ python3Packages.python python3Packages.pytest xnvme ];

  meta = {
    description = "python bindings for xnvme";
    homepage = "https://www.xnvme.io";
  };
}
