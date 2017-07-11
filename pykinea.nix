with import <unstable> {};

stdenv.mkDerivation rec {

  name = "pykinea-env";

  # Boilerplate for buildable env
  # (nix-build can then be used to create a garbage-collection root)
  # taken from http://datakurre.pandala.org/2015/10/nix-for-python-developers.html
  env = buildEnv { name = name; paths = buildInputs; };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup; ln -s $env $out
  '';

  buildInputs = with python3Packages; [
    flask
    itsdangerous
    jinja2
    markdown
    markdownsuperscript
    markupsafe
    setuptools
    werkzeug
    wheel
  ];
}
