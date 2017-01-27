with import <unstable> {};

stdenv.mkDerivation {

  name = "env";

  buildInputs = [
    ncurses

    # Coq refman dependencies
    transfig
    ghostscript
    hevea
    # These two are also required but I have them installed already
    # texlive.combined.scheme-full
    # imagemagick

  ] ++ (with ocamlPackages_4_03; [
    ocaml
    findlib

    # Coq dependencies
    lablgtk
    camlp5_transitional

  ]);

}
