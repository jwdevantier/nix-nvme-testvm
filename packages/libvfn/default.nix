{ stdenv, fetchFromGitHub, pkg-config, meson, ninja, perl }:

stdenv.mkDerivation rec {
  pname = "libvfn";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "OpenMPDK";
    repo = "libvfn";
    rev = "v${version}";
    hash = "sha256-YL6BTaWwfzaD7MwF9TzVG6mtuMKF8Lhq2KKN9T6zXpo=";
  };

  patches = [ ./trace_pl_pathfix.patch ];

  mesonFlags = [ "-Ddocs=disabled" "-Dlibnvme=disabled" "-Dprofiling=false" ];

  nativeBuildInputs = [ meson ninja pkg-config perl ];
}
