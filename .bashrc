# If not running interactively, don't load anything
if [[ -z $PS1 ]]; then return; fi
# Or in the nix-shell
if [[ -n $IN_NIX_SHELL ]]; then return; fi

# Coq aliases
alias coqtop='rlwrap coqtop'
alias coqtop-master='rlwrap ~/dotfiles/nix-builds/coq-master/bin/coqtop'
alias coqtop-8.12='rlwrap ~/dotfiles/nix-builds/coq-8-12/bin/coqtop'
alias coqtop-8.11='rlwrap ~/dotfiles/nix-builds/coq-8-11/bin/coqtop'
alias coqtop-8.10='rlwrap ~/dotfiles/nix-builds/coq-8-10/bin/coqtop'
alias coqtop-8.9='rlwrap ~/dotfiles/nix-builds/coq-8-9/bin/coqtop'
alias coqtop-8.8='rlwrap ~/dotfiles/nix-builds/coq-8-8/bin/coqtop'
alias coqtop-8.7='rlwrap ~/dotfiles/nix-builds/coq-8-7/bin/coqtop'
alias coqtop-8.6='rlwrap ~/dotfiles/nix-builds/coq-8-6/bin/coqtop'

alias matplotlib-env='nix-shell -p "python3Packages.matplotlib.override {enableQt=true;}" graphviz'

alias kinea-run='nix-shell ~/dotfiles/pykinea.nix --run "python src/kinea.py"'

# Auto-completion of git aliases
function _git_delete() {
  _git_branch
}
function _git_delete-hard() {
  _git_branch
}
# Keep auto-completion working in cached-nix-shell
alias cached-nix-shell='cached-nix-shell --keep XDG_DATA_DIRS'

export EDITOR=emacs
