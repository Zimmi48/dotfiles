with import <nixpkgs> {};

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
    unstable.ncurses

    # Coq refman dependencies
    transfig
    ghostscript
    hevea
    texlive.combined.scheme-full
    imagemagick

  ] ++ (with unstable.ocamlPackages_latest; [
    ocaml
    findlib

    # Coq dependencies
    lablgtk
    camlp5_strict

  ]);

  shellHook = ''
    export PATH=`pwd`/bin:$PATH
  '';
}
