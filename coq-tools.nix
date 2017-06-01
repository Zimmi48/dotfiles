{ stdenv, python2, fetchFromGitHub }:

stdenv.mkDerivation rec {

  name = "coq-tools";
  version = "${name}-unstable-2017-06-01";

  src = fetchFromGitHub {
    owner = "JasonGross";
    repo = "coq-tools";
    rev = "f08ec980812eea1d065879bf4d03da8aa9d4d3f1";
    sha256 = "1wsvnczaixj0mjab25yq0f7063b5xax1z3nz0wr98s9pw1x0x1yp";
  };

  buildInputs = [ python2 ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp *.py $out/bin
    mkdir -p $out/share/doc
    cp README.md LICENSE $out/share/doc
  '';

}
