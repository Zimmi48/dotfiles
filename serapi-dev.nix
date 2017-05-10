with import <unstable> {};

stdenv.mkDerivation rec {

  name = "serapi-dev-env";

  # Boilerplate for buildable env
  # (nix-build can then be used to create a garbage-collection root)
  # taken from http://datakurre.pandala.org/2015/10/nix-for-python-developers.html
  env = buildEnv { name = name; paths = buildInputs; };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup; ln -s $env $out
  '';

  buildInputs = with ocamlPackages_latest; with janeStreet; [

    # Coq requirements
    ncurses
    ocaml
    findlib
    camlp5_strict

    # Serapi requirements
    ocamlbuild
    ppx_import
    cmdliner
    core_kernel
    sexplib
    ppx_sexp_conv
  ];

  shellHook = ''
    export OCAMLPATH=$HOME/coq:$OCAMLPATH
  '';
}
