{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    dmenu
    (st.overrideAttrs (oldAttrs: rec {
      src = ../../dotfiles/st;
      buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
    }))
    (dwm.overrideAttrs (oldAttrs: rec {
      src = ../../dotfiles/dwm;
      buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
    }))
    (dwmblocks.overrideAttrs (oldAttrs: rec {
      src = ../../dotfiles/dwmblocks;
      buildInputs = oldAttrs.buildInputs ++ [harfbuzz];
    }))
    bat
    file
    fira-code
    libnotify
    pulsemixer
    xdotool
    xorg.xmodmap
  ];
  
  fonts.fontconfig.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/bin/statusbar"
    "$HOME/.local/bin/cron"
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".local/bin" = {
      source = ../../scripts;
      recursive = true;
    };
  };

  home.sessionVariables = {
    TERMINAL = "st";
    BROWSER = "firefox";
  };

  xsession = {
    enable = true;
    windowManager.command = "ssh-agent dwm";
    initExtra = ''
      xmodmap ${pkgs.writeText "xkb-layout" (lib.fileContents ../../dotfiles/x11/xmodmap)}'';
    profilePath = ".config/x11/xprofile";
    scriptPath = ".config/x11/xsession";
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    history = {
      save = 10000000;
      size = 10000000;
      path = "${config.xdg.cacheHome}/zsh/history";
    };
    syntaxHighlighting = {
      enable = true;
     # package = pkgs.zsh-syntax-highlighting;
    };
    autocd = true;
    initExtraBeforeCompInit = ''
      autoload -U colors && colors
      PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "'';
    completionInit = ''
      autoload -U compinit
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      compinit
      _comp_options+=(globdots)'';
    profileExtra = ''
      [ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx $HOME/.config/x11/xsession >/dev/null 2>&1'';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.lf = {
    enable = true;
    extraConfig = lib.fileContents ../../dotfiles/lf/lfrc;
  };

  programs.git = {
    enable = true;
    userName = "RuiPMaia";
    userEmail = "ruipmaia29@gmail.com";
  };
    
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 370;
        height = 350;
        offset = "0x19";
        padding = 2;
        horizontal_padding = 2;
        transparency = 25;
        font = "Monospace 12";
        format = "<b>%s</b>\\n%b";
      };
      urgency_low = {
        background = "#1d2021";
        foreground = "#928374";
        timeout = 3;
      };
      urgency_normal = {
        foreground = "#ebdbb2";
        background = "#458588";
        timeout = 5;
      };
      urgency_critical = {
        background = "#1cc24d";
        foreground = "#ebdbb2";
        frame_color = "#fabd2f";
        timeout = 10;
      };
    };
  };
  
  services.unclutter.enable = true;
  services.blueman-applet.enable = true;
}
