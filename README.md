## Setup commands

    git clone https://github.com/Zimmi48/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    git submodule update --init
    cp -i -R --preserve=links home/. ..
    ./build.sh
