let
  unstable = import <unstable> {};
  stable = import <nixpkgs> {};
in

stable.stdenv.mkDerivation {

  name = "env";

  buildInputs = (with stable; [
    stable.ncurses

    # Coq refman dependencies
    transfig
    ghostscript
    hevea
    texlive.combined.scheme-full
    imagemagick

  ]) ++ (with unstable.ocamlPackages_4_02; [
    ocaml
    findlib

    # Dev tools
    merlin
    utop

    # Coq dependencies
    lablgtk
    camlp5_transitional

  ]);

}
