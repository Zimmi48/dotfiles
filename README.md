## Setup commands ##

``` shell
git clone git@github.com:Zimmi48/dotfiles ~/dotfiles
cd ~/dotfiles
cp -i -R --preserve=links home/. ..
mkdir ~/git
cd ~/git
git clone-fork git@github.com: NixOS Zimmi48 nixpkgs
cd nixpkgs
```

Still in this repository, after having identified which commits to use for the nixos and nixpkgs "channels":

```
git worktree add ../../dotfiles/nixos <commit-hash>
git worktree add ../../dotfiles/nixpkgs <commit-hash>
cd ../../dotfiles
git submodule init
git submodule update
```
