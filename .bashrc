
# Coq aliases
alias coqide='nix-shell -I ~ -p coq_8_6 --run coqide'
alias coqtop='nix-shell -I ~ -p coq_8_6 --run "rlwrap coqtop"'

alias coqide-8.5='nix-shell -I ~ -p coq_8_5 --run coqide'
alias coqtop-8.5='nix-shell -I ~ -p coq_8_5 --run "rlwrap coqtop"'

# Nix aliases
alias nix-shell='nix-shell -I ~'
alias nix-env='nix-env -I ~'
alias nix-instantiate='nix-instantiate -I ~'

