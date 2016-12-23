# Colors in the terminal
export LS_COLORS=$LS_COLORS:'di=1;44:'

# Coq aliases
alias coqtop-trunk='rlwrap ~/coq/bin/coqtop'
alias coqtop='rlwrap ~/nix-builds/coq-8-6/bin/coqtop'
alias coqtop-8.5='rlwrap ~/nix-builds/coq-8-5/bin/coqtop'

# Development aliases
alias coq-dev='nix-shell ~/dotfiles/coq-dev.nix -I ~'

# Nix aliases
alias nix-shell='nix-shell -I ~'
alias nix-env='nix-env -f ~/nixpkgs'
alias nix-build='nix-build -I ~'
alias nix-repl='nix-repl -I ~'

