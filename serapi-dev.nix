{ pkgs ? (import <nixpkgs> {}) }:
with pkgs;

stdenv.mkDerivation rec {

  name = "serapi-dev-env";

  # Boilerplate for buildable env
  # (nix-build can then be used to create a garbage-collection root)
  # taken from http://datakurre.pandala.org/2015/10/nix-for-python-developers.html
  env = buildEnv { name = name; paths = buildInputs; };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup; ln -s $env $out
  '';

  buildInputs = with ocaml-ng.ocamlPackages_4_04; [

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
    yojson
    js_of_ocaml
  ];

  shellHook = ''
    export OCAMLPATH=$HOME/coq-for-serapi:$OCAMLPATH
  '';
}
