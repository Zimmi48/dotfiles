{
  stateVersion,
  unstable,
  unfree-stable,
  unfree-unstable,
  extraImports ? [ ],
}:

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = extraImports;

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignorespace" ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      package = unstable.git;
    };

    # VS Code with mutable extensions so the user can install from the marketplace
    vscode = {
      enable = true;
      package = unfree-unstable.vscode;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        userSettings = {
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "git.postCommitCommand" = "sync";
          "editor.wordWrap" = "on";
          "window.restoreWindows" = "none";
          "extensions.autoUpdate" = false;
          "search.followSymlinks" = false;
        };
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gtk2;
  };

  services.redshift = {
    enable = true;
    latitude = 48.85341; # Paris
    longitude = 2.3488;
    temperature.day = 3000;
    temperature.night = 3000;
    tray = true;
  };

  home = {
    packages =
      (with pkgs; [

        # Utilities
        scrot
        jq
        httpie

        # Development
        gnumake
        imagemagick
        pandoc
        texlive.combined.scheme-full
        nixfmt

        # Applications
        signal-desktop
        telegram-desktop

      ])
      ++ [

        unfree-stable.obsidian
        unfree-stable.zoom-us

      ];

    inherit stateVersion;
  };

  home.file.".dmrc".text = ''
    [Desktop]
    Session=xfce
  '';

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
