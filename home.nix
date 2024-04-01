{ user, home, stateVersion, unstable, unfree-stable, unfree-unstable, extraImports ? [] }:

{ config, lib, pkgs, vscode-extensions, ... }:

{
  imports = extraImports;

  programs = {
    # Bash configuration
    bash = {
      enable = true;
      historyControl = ["ignorespace"];
      initExtra = ''
        # Auto-completion of git aliases
        function _git_delete() {
          _git_branch
        }
        function _git_delete_hard() {
          _git_branch
        }
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Emacs configuration
    emacs = {
      enable = true;
      extraConfig = ''
        (electric-indent-mode -1) ; Disable eletric ident
        (setq-default indent-tabs-mode nil) ; Never use tabs
        (tool-bar-mode -1) ; Disable the tool bar
        (setq initial-scratch-message nil) ; Disable the scratch message
        (setq column-number-mode t) ; Show the column number
        (setq show-paren-mode t) ; Match parentheses
        (setq save-abbrevs 'silently)
        (setq org-cycle-separator-lines 1) ; Org mode: add a line between headings
      '';
    };

    # gh configuration
    gh = {
      enable = true;
      package = unstable.gh;
      settings.git_protocol = "ssh";
    };

    # Git configuration
    git = {
      enable = true;
      lfs.enable = true;
      package = unstable.git;
      userName = "Théo Zimmermann";
      userEmail = "theo.zimmermann@telecom-paris.fr";
      signing.key = "F1744A0942F536C7";
      aliases = {
        fix = "commit -a --amend --no-edit";
        newbranch = "checkout -b";
        clone-fork = "! ${./git-clone-fork.sh}";
        delete = "! f() { git branch -d $1 && git push origin -d $1; }; f";
        delete-hard = "! f() { git branch -D $1 && git push origin -d $1; }; f";
      };
      extraConfig = {
        log.mailmap = true;
        pull.ff = "only";
        push.default = "current";
        remote.pushdefault = "origin";
        init.defaultBranch = "main";
      };
    };

    # Thunderbird configuration
    thunderbird = {
      enable = true;
      profiles.default.isDefault = true;
      settings = {
        "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";
        "mail.identity.default.archive_granularity" = 0; # Use a single flat archive folder
        "mail.pane_config.dynamic" = 0; # Classic layout
        "mailnews.tags.1_closed.color" = "#986a44";
        "mailnews.tags.1_closed.tag" = "1_closed";
        "mailnews.tags.2_assign.color" = "#9141ac";
        "mailnews.tags.2_assign.tag" = "2_assign";
        "mailnews.tags.3_mention.color" = "#e01b24";
        "mailnews.tags.3_mention.tag" = "3_mention";
        "mailnews.tags.4_team_mention.color" = "#ff7800";
        "mailnews.tags.4_team_mention.tag" = "4_team_mention";
        "mailnews.tags.5_review_requested.color" = "#f6d32d";
        "mailnews.tags.5_review_requested.tag" = "5_review_requested";
        "mailnews.tags.6_author.color" = "#33d17a";
        "mailnews.tags.6_author.tag" = "6_author";
        "mailnews.tags.version" = 2;
        "spellchecker.dictionary" = "en-US,fr";
      };
    };

    # urxvt configuration
    urxvt = {
      enable = true;
      scroll.bar.enable = false;
      fonts = [ "xft:DejaVu Sans Mono:size=11" ];
      extraConfig = {
        perl-ext-common = "default,matcher,font-size";
        url-launcher = "firefox";
        "matcher.button" = "1";
      };
    };

    # VS Code configuration with free and non-free Microsoft extensions
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      package = unfree-unstable.vscode;
      extensions = (with unstable.vscode-extensions; [
          eamodio.gitlens
          foam.foam-vscode
          github.vscode-pull-request-github
          james-yu.latex-workshop
          jnoortheen.nix-ide
          maximedenes.vscoq
          mkhl.direnv
          ms-python.python
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.vscode-jupyter-slideshow
          ocamllabs.ocaml-platform
          yzhang.markdown-all-in-one # Recommended by Foam
        ]) ++ (with unfree-unstable.vscode-extensions; [
          github.codespaces
          github.copilot
          github.copilot-chat
          ms-python.vscode-pylance
          ms-vscode-remote.remote-ssh
          ms-vsliveshare.vsliveshare
        ]) ++ (with vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
          ejgallego.coq-lsp
          elm-land.elm-land
        ]);
      keybindings = [
        {
          key = "ctrl+enter";
          command = "editor.debug.action.selectionToRepl";
        }
        {
          key = "ctrl+q";
          command = "-workbench.action.quit";
        }
      ];
      userSettings = {
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "git.postCommitCommand" = "sync";
        "editor.wordWrap" = "on";
        "editor.unicodeHighlight.nonBasicASCII" = false;
        "editor.inlineSuggest.enabled" = true; # Copilot
        "github.copilot.enable" = {
            "*" = true;
            plaintext = true;
            markdown = true;
            scminput = false;
            yaml = true;
        };
        "coq-lsp.updateIgnores" = false;
        "[python]"."editor.formatOnType" = true;
        "notebook.output.scrolling" = true;
        "terminal.integrated.defaultProfile.linux" = "bash";
        "latex-workshop.view.pdf.viewer" = "tab";
        "window.restoreWindows" = "none";
        "workbench.colorTheme" = "Default Dark Modern";
        "extensions.autoUpdate" = false;
      };
    };
  };

  services = {
    blueman-applet.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gtk2";
    };

    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
      xautolock.enable = false; # means use xss-lock
      xss-lock.extraOptions = [
        "--notifier=${pkgs.xsecurelock}/libexec/xsecurelock/dimmer"
        "-l" # prevents suspend before locker is started
      ];
    };
  };

  xsession = {
    enable = true;
    initExtra = ''
      rfkill block bluetooth
      echo -e '[org/blueman/plugins/powermanager]\nauto-power-on=@mb false' | dconf load /
    '';
    windowManager.i3 = {
      enable = true;
      config = {
        defaultWorkspace = "workspace number 1";
        modifier = "Mod4";
        menu = "i3-dmenu-desktop";
        terminal = "urxvt";
        workspaceAutoBackAndForth = true;
        keybindings = lib.mkOptionDefault {
          "Mod4+p" = "exec xset s activate";
        };
        startup = [
          { command = "${pkgs.xfce.xfce4-volumed-pulse}/bin/xfce4-volumed-pulse &"; }
          { command = "nm-applet &"; }
          { command = "${pkgs.caffeine-ng}/bin/caffeine &"; }
          { command = "languagetool-http-server --allow-origin \"*\" &"; }
        ];
        floating.criteria = [
          { window_role = "alert"; }
        ];
      };
    };
  };

  xdg.desktopEntries = {
    # Desktop entries for CoqIDE
    coq_8_6 = {
      name = "CoqIDE 8.6";
      exec = "${unstable.coq_8_6}/bin/coqide";
    };
    coq_8_7 = {
      name = "CoqIDE 8.7";
      exec = "${unstable.coq_8_7}/bin/coqide";
    };
    coq_8_8 = {
      name = "CoqIDE 8.8";
      exec = "${unstable.coq_8_8}/bin/coqide";
    };
    coq_8_9 = {
      name = "CoqIDE 8.9";
      exec = "${unstable.coq_8_9}/bin/coqide";
    };
    coq_8_10 = {
      name = "CoqIDE 8.10";
      exec = "${unstable.coq_8_10}/bin/coqide";
    };
    coq_8_11 = {
      name = "CoqIDE 8.11";
      exec = "${unstable.coq_8_11}/bin/coqide";
    };
    coq_8_12 = {
      name = "CoqIDE 8.12";
      exec = "${unstable.coq_8_12}/bin/coqide";
    };
    coq_8_13 = {
      name = "CoqIDE 8.13";
      exec = "${unstable.coq_8_13}/bin/coqide";
    };
    coq_8_14 = {
      name = "CoqIDE 8.14";
      exec = "${unstable.coqPackages_8_14.coqide}/bin/coqide -coqtop ${unstable.coq_8_14}/bin/coqidetop.opt"; # -unicode-bindings ${pkgs.writeText "empty" ""}";
    };
    coq_8_15 = {
      name = "CoqIDE 8.15";
      exec = "${unstable.coqPackages_8_15.coqide}/bin/coqide -coqtop ${unstable.coq_8_15}/bin/coqidetop.opt";
    };
    coq_8_16 = {
      name = "CoqIDE 8.16";
      exec = "${unstable.coqPackages_8_16.coqide}/bin/coqide -coqtop ${unstable.coq_8_16}/bin/coqidetop.opt";
    };
    coq_8_17 = {
      name = "CoqIDE 8.17";
      exec = "${unstable.coqPackages_8_17.coqide}/bin/coqide -coqtop ${unstable.coq_8_17}/bin/coqidetop.opt";
    };
    # Desktop entry for launching VS Code with Foam notes
    foam = {
      name = "Foam";
      exec = "${unfree-unstable.vscode}/bin/code ${home}/git/notes";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };

  # Bookmarks for the file manager
  gtk = {
    enable = true;
    gtk3.bookmarks = [
      "file://${home}/git"
      "file://${home}/git/work"
      "file://${home}/git/research"
      "file:///tmp"
    ];
  };

  xresources.properties = {
    # Dracula Xresources palette (for Emacs and urxvt)
    "*.foreground" = "#F8F8F2";
    "*.background" = "#282A36";
    "*.color0" = "#000000";
    "*.color8" = "#4D4D4D";
    "*.color1" = "#FF5555";
    "*.color9" = "#FF6E67";
    "*.color2" = "#50FA7B";
    "*.color10" = "#5AF78E";
    "*.color3" = "#F1FA8C";
    "*.color11" = "#F4F99D";
    "*.color4" = "#BD93F9";
    "*.color12" = "#CAA9FA";
    "*.color5" = "#FF79C6";
    "*.color13" = "#FF92D0";
    "*.color6" = "#8BE9FD";
    "*.color14" = "#9AEDFE";
    "*.color7" = "#BFBFBF";
    "*.color15" = "#E6E6E6";
  };

  manual.manpages.enable = false;

  home = {
    username = user.name;
    homeDirectory = home;

    sessionVariables.EDITOR = "emacs";
    shellAliases.coqtop = "rlwrap coqtop";

    file.".background-image".source = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath;
    # The following option cannot be set through programs.emacs.extraConfig
    file.".emacs".text = "(setq inhibit-startup-screen t)";

    # Disable unicode bindings in CoqIDE, workaround for coq/coq#14856
    file.".config/coq/coqiderc".text = ''
      unicode_binding = "false"
    '';
    # Enable Dune cache and limit the number of jobs it can spawn
    file.".config/dune/config".text = ''
      (lang dune 2.1)
      (cache enabled)
      (jobs 4)
    '';
    # Avoid getting a warning about the directory not existing
    file.".config/matplotlib/matplotlibrc".text = "";

    # Scripts
    file."move_to_sd_card.sh".source = ./scripts/move_to_sd_card.sh;

    # Packages to be installed in the user environment.
    packages = (with pkgs; [

      # Utilities
      pass
      scrot
      pdfpc
      jq
      httpie
      arandr

      # Desktop packages
      dmenu
      xfce.thunar
      xfce.ristretto
      networkmanagerapplet
      xfce.xfce4-notifyd
      languagetool

      # Applications
      chromium
      tdesktop
      signal-desktop
      zotero

      # Development (stable packages)
      gnumake
      imagemagick
      mustache-go
      pandoc
      texlive.combined.scheme-full
      inotifyTools # Useful for dune build --watch in particular

    ]) ++ (with unstable; [

      # Development (unstable packages)
      coq_8_18
      coqPackages_8_18.coqide
      coqPackages_8_18.coq-lsp
      opam
      elmPackages.elm # needed by elm-land vscode extension
      elmPackages.elm-format

    ]) ++ [

      # Non-free applications and development tools
      unfree-unstable.elmPackages.lamdera
      unfree-stable.skypeforlinux
      unfree-stable.zoom-us

    ];

    # This value determines the home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update home Manager without changing this value. See
    # the home Manager release notes for a list of state version
    # changes in each release.
    inherit stateVersion;
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}