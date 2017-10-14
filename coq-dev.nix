{ pkgs? (import <nixpkgs> {}) }:
with pkgs;

stdenv.mkDerivation rec {

  name = "coq-dev-env";

  # Boilerplate for buildable env
  # (nix-build can then be used to create a garbage-collection root)
  # taken from http://datakurre.pandala.org/2015/10/nix-for-python-developers.html
  env = buildEnv { name = name; paths = buildInputs; };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup; ln -s $env $out
  '';

  buildInputs = [
    ncurses

    # Coq refman dependencies
    transfig
    hevea
    texlive.combined.scheme-full
    imagemagick

    # Jason Gross' coq-tools
    (callPackage ./coq-tools.nix {})

    # Now useful for several make / coq_makefile targets
    python3

  ] ++ (with ocaml-ng.ocamlPackages_4_04; [
    ocaml
    findlib

    # Coq dependencies
    lablgtk
    camlp5_strict

  ]);

  shellHook = ''
    export PATH=`pwd`/bin:$PATH
    if [ ! -e config/coq_config.ml ]; then ./configure -local -annotate -native-compiler no; fi
  '';
}
