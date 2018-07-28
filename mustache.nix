with import <nixpkgs> {};
buildGoPackage rec {
  name = "mustache-unstable-${version}";
  version = "2018-05-25";

  goPackagePath = "github.com/cbroglie/mustache";

  src = fetchFromGitHub {
    owner = "cbroglie";
    repo = "mustache";
    rev = "73b1f3905474dd28d480fbb3f1da71b625a58e76";
    sha256 = "0r8cj3rgys4s99z0vqhf5yqv66p73bqk8pa30nf69bbhysj1ykh5";
  };
}
