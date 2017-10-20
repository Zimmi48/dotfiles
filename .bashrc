# Colors in the terminal
export LS_COLORS=$LS_COLORS:'di=1;44:'

# Coq aliases
alias coqtop='rlwrap coqtop'
alias coqtop-master='rlwrap ~/coq/bin/coqtop'
alias coqtop-8.6='rlwrap ~/dotfiles/nix-builds/coq-8-6/bin/coqtop'
alias coqtop-8.5='rlwrap ~/dotfiles/nix-builds/coq-8-5/bin/coqtop'
alias coqtop-8.4='rlwrap ~/dotfiles/nix-builds/coq-8-4/bin/coqtop'

# Development aliases
alias coq-dev='nix-shell ~/dotfiles/coq-dev.nix'
alias serapi-dev='nix-shell ~/dotfiles/serapi-dev.nix --arg pkgs "import <unstable> {}"'
alias coq-env='nix-shell -p coq_8_6 --command "echo \"Coq 8.6.1 environment\"; return"'
alias mathcomp-env='nix-shell -p coqPackages_8_6.mathcomp'

alias kinea-run='nix-shell ~/dotfiles/pykinea.nix --arg pkgs "import <unstable> {}" --run "python src/kinea.py"'

# Auto-completion of git aliases
function _git_delete() {
  _git_branch
}
