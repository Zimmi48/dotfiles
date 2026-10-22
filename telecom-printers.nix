# Central Télécom Paris printers (via the papercups.enst.fr print server), set
# up declaratively following the "local CUPS server" variant of
# https://doc.telecom-paris.fr/impression/linux.html#vous-etes-administrateur-de-votre-poste
{ pkgs, ... }:

let
  # Télécom Paris login, used by the print server to attribute the jobs.
  login = "tzimmermann";

  fetchPpd =
    { name, hash }:
    pkgs.fetchurl {
      url = "https://doc.telecom-paris.fr/_downloads/${hash.path}/${name}.ppd";
      sha256 = hash.sha256;
    };

  printers = [
    {
      name = "Central_NB";
      hash = {
        path = "624be7146adc769d1168d7a6c1ae7dd4";
        sha256 = "025nflmxnpm1bdwwgnpagjxjz5glm8cfl10j2yv0rxwd6rziv44s";
      };
    }
    {
      name = "Central_Couleurs";
      hash = {
        path = "ac7c19cbeda36aae3ccdcfb229244b6c";
        sha256 = "1nh09w45a3x042wp7pj9bbfw6jcl3kf6b7g1fyb88cqn7qm9f6a3";
      };
    }
  ];

  # PPDs exposed under share/cups/model, where `lpadmin -m` looks for them.
  ppds = pkgs.runCommand "telecom-paris-ppds" { } ''
    mkdir -p $out/share/cups/model/telecom-paris
    ${pkgs.lib.concatMapStrings (p: ''
      cp ${fetchPpd p} $out/share/cups/model/telecom-paris/${p.name}.ppd
    '') printers}
  '';
in
{
  services.printing.drivers = [ ppds ];

  hardware.printers.ensurePrinters = map (p: {
    inherit (p) name;
    deviceUri = "ipps://papercups.enst.fr/printers/${p.name}";
    model = "telecom-paris/${p.name}.ppd";
  }) printers;

  # Per-user rather than system-wide (`services.printing.clientConf`): with a
  # system-wide `User`, root's `lpadmin` in `ensure-printers.service` would
  # authenticate as this login and be rejected by cupsd ("Non autorisé").
  home-manager.users.theo.home.file.".cups/client.conf".text = ''
    ServerName localhost
    Encryption Required
    User ${login}
  '';
}
