{ stdenv, fetchFromGitHub, pkg-config, meson, ninja, python3Packages, libuuid
, libtool, nasm, zlib, liburing, libaio, libvfn, isa-l }:

stdenv.mkDerivation rec {
  pname = "xnvme";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "OpenMPDK";
    repo = "xNVMe";
    rev = "v${version}";
    hash = "sha256-ApqsHmFu6Gp/gJ0CYYEy+LMppegIB06npCVgvHPBtdI=";
  };

  patches = [ ];

  mesonFlags = [ "-Dwith-spdk=false" ];

  nativeBuildInputs =
    [ libvfn meson ninja pkg-config python3Packages.pyelftools ];

  buildInputs = [ libuuid libtool nasm zlib liburing libaio libvfn isa-l ];
}
