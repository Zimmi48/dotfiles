# If not running interactively, don't load anything
if [[ -z $PS1 ]]; then return; fi
# Or in the nix-shell
if [[ -n $IN_NIX_SHELL ]]; then return; fi

# Coq aliases
alias coqtop='rlwrap coqtop'
alias coqtop-master='rlwrap ~/dotfiles/nix-builds/coq-master/bin/coqtop'
alias coqtop-v8.8='rlwrap ~/dotfiles/nix-builds/coq-v8.8/bin/coqtop'
alias coqtop-8.7='rlwrap ~/dotfiles/nix-builds/coq-8-7/bin/coqtop'
alias coqtop-8.6='rlwrap ~/dotfiles/nix-builds/coq-8-6/bin/coqtop'
alias coqtop-8.5='rlwrap ~/dotfiles/nix-builds/coq-8-5/bin/coqtop'
alias coqtop-8.4='rlwrap ~/dotfiles/nix-builds/coq-8-4/bin/coqtop'

alias matplotlib-env='nix-shell -p "python3Packages.matplotlib.override {enableQt=true;}" graphviz'

alias kinea-run='nix-shell ~/dotfiles/pykinea.nix --run "python src/kinea.py"'

# Auto-completion of git aliases
function _git_delete() {
  _git_branch
}
function _git_delete-hard() {
  _git_branch
}

export EDITOR=emacs
