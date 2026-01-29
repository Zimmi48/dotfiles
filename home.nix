{ user, home, stateVersion, unstable, unfree-stable, unfree-unstable, extraImports ? [] }:

{ config, lib, pkgs, vscode-extensions, ... }:

{
  imports = extraImports;

  programs = rec {
    # Bash configuration
    bash = {
      enable = true;
      enableCompletion = true;
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
      signing.key = "F1744A0942F536C7";
      settings = {
        user.name = "Théo Zimmermann";
        user.email = "theo.zimmermann@telecom-paris.fr";
        alias = {
          fix = "commit -a --amend --no-edit";
          newbranch = "checkout -b";
          clone-fork = "! ${./git-clone-fork.sh}";
          delete = "! f() { git branch -d $1 && git push origin -d $1; }; f";
          delete-hard = "! f() { git branch -D $1 && git push origin -d $1; }; f";
        };
        log.mailmap = true;
        pull.ff = "only";
        push.default = "current";
        remote.pushdefault = "origin";
        init.defaultBranch = "main";
      };
    };

    jujutsu = {
      enable = true;
      package = unstable.jujutsu;
      settings = {
        user = with git.settings.user; {
          inherit name email;
        };
        ui.default-command = "log";
        signing = {
          behavior = "drop";
          backend = "gpg";
          backends.gpg.program = "${pkgs.gnupg}/bin/gpg";
        };
        git = {
          sign-on-push = true;
          fetch = ["upstream" "origin"];
          push = "origin";
        };
      };
    };

    # Thunderbird configuration
    thunderbird = {
      enable = true;
      profiles.default.isDefault = true;
      settings = {
        "calendar.view.dayendhour" = 18; # End of the day at 18:00
        "calendar.view.daystarthour" = 9; # Start of the day at 9:00
        "calendar.week.start" = 1; # Start the week on Monday
        "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";
        "mail.identity.default.archive_granularity" = 0; # Use a single flat archive folder
        "mail.pane_config.dynamic" = 2; # Vertical layout
        "mail.spam.logging.enabled" = true;
        "mail.spam.manualMark" = true;
        "mail.spam.version" = 1;
        "mailnews.confirm.moveFoldersToTrash" = true; # Confirm when moving folders to trash
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
      mutableExtensionsDir = false;
      package = unfree-unstable.vscode;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions = (with unstable.vscode-extensions; [
            eamodio.gitlens
            foam.foam-vscode
            github.copilot-chat
            github.vscode-pull-request-github
            james-yu.latex-workshop
            jnoortheen.nix-ide
            mkhl.direnv
            ms-python.python
            ms-toolsai.jupyter
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-toolsai.vscode-jupyter-cell-tags
            ms-toolsai.vscode-jupyter-slideshow
            myriad-dreamin.tinymist
            ocamllabs.ocaml-platform
            rocq-prover.vsrocq
            yzhang.markdown-all-in-one # Recommended by Foam
            rust-lang.rust-analyzer
          ]) ++ (with unfree-unstable.vscode-extensions; [
            github.codespaces
            ms-python.vscode-pylance
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh
            ms-vsliveshare.vsliveshare
          ]) ++ (with vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
            ms-vscode.wasm-wasi-core # Needed by coq-lsp
            ejgallego.coq-lsp
            elm-land.elm-land
            quarto.quarto
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
          "git.openRepositoryInParentFolders" = "always";
          "editor.wordWrap" = "on";
          "editor.unicodeHighlight.nonBasicASCII" = false;
          "editor.inlineSuggest.enabled" = true; # Copilot
          "github.copilot.enable" = {
              "*" = true;
              plaintext = true;
              markdown = true;
              quarto = true;
              scminput = false;
              yaml = true;
          };
          "githubPullRequests.terminalLinksHandler" = "github";
          "coq-lsp.updateIgnores" = false;
          "[python]"."editor.formatOnType" = true;
          "[typst]" = {
            "editor.formatOnSave" = true;
            "editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?"; # Auto-added by Typst
          };
          "[typst-code]"."editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?"; # Auto-added by Typst
          "tinymist.formatterMode" = "typstyle";
          "notebook.output.scrolling" = true;
          "terminal.integrated.defaultProfile.linux" = "bash";
          "latex-workshop.view.pdf.viewer" = "tab";
          "window.restoreWindows" = "none";
          "workbench.colorTheme" = "Default Dark Modern";
          "extensions.autoUpdate" = false;
          "search.followSymlinks" = false; # Avoid issues with VS Code search eating CPU and memory
        };
      };
    };
  };

  services = {
    blueman-applet.enable = true;

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gtk2;
    };

    redshift = {
      enable = true;
      latitude = 48.85341; # Paris
      longitude = 2.3488;
      #provider = "geoclue2";
      tray = true;
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
    coq_8_18 = {
      name = "CoqIDE 8.18";
      exec = "${unstable.coqPackages_8_18.coqide}/bin/coqide -coqtop ${unstable.coq_8_18}/bin/coqidetop.opt";
    };
    coq_8_19 = {
      name = "CoqIDE 8.19";
      exec = "${unstable.coqPackages_8_19.coqide}/bin/coqide -coqtop ${unstable.coq_8_19}/bin/coqidetop.opt";
    };
    coq_8_20 = {
      name = "CoqIDE 8.20";
      exec = "${unstable.coqPackages_8_20.coqide}/bin/coqide -coqtop ${unstable.coq_8_20}/bin/coqidetop.opt";
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
      auto-multiple-choice
      chromium
      telegram-desktop
      zotero

      # Development (stable packages)
      gnumake
      imagemagick
      mustache-go
      pandoc
      texlive.combined.scheme-full
      inotify-tools # Useful for dune build --watch in particular
      nixfmt

    ]) ++ (with unstable; [

      # Applications (unstable packages)
      signal-desktop

      # Development (unstable packages)
      opam
      elmPackages.elm # needed by elm-land vscode extension
      elmPackages.elm-format
      elmPackages.elm-review
      typst
      typstyle

    ]) ++ [

      # Non-free applications and development tools
      unfree-unstable.elmPackages.lamdera
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