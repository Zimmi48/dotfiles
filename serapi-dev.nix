# Does not work yet

with import <nixpkgs> {};

stdenv.mkDerivation {

  name = "env";

  buildInputs = with ocamlPackages_4_02; [

    # Override the default Coq 8.6 derivation which is built with OCaml 4.01
    (coq_8_6.override {
      inherit ocaml findlib;
      camlp5 = camlp5_transitional;
      # CoqIDE is not needed
      lablgtk = null;
    })

    ocaml
    findlib
    camlp5_transitional

    # Dev tools
    merlin
    utop

    # Serapi requirements
    ppx_import
    cmdliner
    core_kernel
    sexplib
    ppx_sexp_conv
  ];

}
