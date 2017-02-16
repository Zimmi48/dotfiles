# Colors in the terminal
export LS_COLORS=$LS_COLORS:'di=1;44:'

# Coq aliases
alias coqtop='rlwrap coqtop'
alias coqtop-trunk='rlwrap ~/coq/bin/coqtop.byte'
alias coqtop-8.5='rlwrap ~/nix-builds/coq-8-5/bin/coqtop'
alias coqtop-8.4='rlwrap ~/nix-builds/coq-8-4/bin/coqtop'

# Development aliases
alias coq-dev='nix-shell ~/nix-builds/coq-dev.drv'
alias coq-env='nix-shell -p unstable.coq_8_6'
