# Coq aliases
alias coqtop='rlwrap coqtop'

# Auto-completion of git aliases
function _git_delete() {
  _git_branch
}
function _git_delete_hard() {
  _git_branch
}

export EDITOR=emacs
