# Colors in the terminal
export LS_COLORS=$LS_COLORS:'di=1;44:'

# Coq aliases
alias coqide='nix-shell -I ~ -p coq_8_6 --run coqide'
alias coqtop='nix-shell -I ~ -p coq_8_6 --run "rlwrap coqtop"'

alias coqide-8.5='nix-shell -I ~ -p coq_8_5 --run coqide'
alias coqtop-8.5='nix-shell -I ~ -p coq_8_5 --run "rlwrap coqtop"'

# Nix aliases
alias nix-shell='nix-shell -I ~'
alias nix-env='nix-env -f ~'
alias nix-instantiate='nix-instantiate -I ~'
alias nix-repl='nix-repl -I ~'

