# Coq aliases
alias coqtop='rlwrap coqtop'
alias coqtop-master='rlwrap ~/coq/bin/coqtop'
alias coqtop-8.6='rlwrap ~/dotfiles/nix-builds/coq-8-6/bin/coqtop'
alias coqtop-8.5='rlwrap ~/dotfiles/nix-builds/coq-8-5/bin/coqtop'
alias coqtop-8.4='rlwrap ~/dotfiles/nix-builds/coq-8-4/bin/coqtop'

# Development aliases
alias coq-dev='nix-shell ~/coq --arg pkgs "import <unstable> {}"'
# alias serapi-dev='nix-shell ~/dotfiles/serapi-dev.nix --arg pkgs "import <unstable> {}"'
alias coq-env='nix-shell -p "(import <unstable> {}).coq_8_7" --command "echo \"Coq 8.7 environment\"; return"'
alias mathcomp-env='nix-shell -p "(import <unstable> {}).coqPackages_8_7.mathcomp"'

alias kinea-run='nix-shell ~/dotfiles/pykinea.nix --arg pkgs "import <unstable> {}" --run "python src/kinea.py"'

# Auto-completion of git aliases
function _git_delete() {
  _git_branch
}
