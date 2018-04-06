# Coq aliases
alias coqtop='rlwrap coqtop'
alias coqtop-master='rlwrap ~/coq/bin/coqtop'
alias coqtop-8.7='rlwrap ~/dotfiles/nix-builds/coq-8-7/bin/coqtop'
alias coqtop-8.6='rlwrap ~/dotfiles/nix-builds/coq-8-6/bin/coqtop'
alias coqtop-8.5='rlwrap ~/dotfiles/nix-builds/coq-8-5/bin/coqtop'
alias coqtop-8.4='rlwrap ~/dotfiles/nix-builds/coq-8-4/bin/coqtop'

alias coq-env='nix-shell -I ~/dotfiles/unstable -p coq_8_8'

alias matplotlib-env='nix-shell -p "python3Packages.matplotlib.override {enableQt=true;}"'

alias kinea-run='nix-shell ~/dotfiles/pykinea.nix --run "python src/kinea.py"'


# Auto-completion of git aliases
function _git_delete() {
  _git_branch
}
