{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    firefox
    discord
    vscode
    wezterm
    easyeffects
    acl
    ripgrep
    starship
    eza
    bat
    gnomeExtensions.media-controls
    gnomeExtensions.gtile
    gnome.dconf-editor
    libreoffice-still
    teams-for-linux
    zoom-us
    fzf
    catppuccin-cursors.mochaDark
    fishPlugins.grc
    fishPlugins.fzf
    fishPlugins.autopair
    gnome.gnome-tweaks
    (rstudioWrapper.override{
      packages = with rPackages; [
        renv
        ggplot2
        foreign
        leaps
        car
      ];
    })
    R
    htop
    neovim
    grc
    jetbrains.idea-ultimate
    neofetch
    jdk17
    openjdk8
    openjdk19
    spotify
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.git = {
    enable = true;
    userName = "Arctic904";
    userEmail = "53384010+Arctic904@users.noreply.github.com";
  };

  dconf = {
    enable = true;
    settings = 
      let
        inherit (builtins) length head tail listToAttrs genList;
        range = a: b: if a < b then [a] ++ range (a+1) b else [];
        globalPath = "org/gnome/settings-daemon/plugins/media-keys";
        path = "${globalPath}/custom-keybindings/";
        mkPath = id: "${globalPath}/custom${toString id}";
        isEmpty = list: length list == 0;
        mkSettings = settings:
          let
            checkSettings = { name, command, binding }@this: this;
            aux = i: list:
              if isEmpty list then [] else
                let
                  hd = head list;
                  tl = tail list;
                  name = mkPath i;
                in
                  aux (i+1) tl ++ [ {
                    name = mkPath i;
                    value = checkSettings hd;
                  } ];
            settingsList = (aux 0 settings);
          in
            listToAttrs (settingsList ++ [
              {
                name = globalPath;
                value = {
                  custom-keybindings = genList (i: "/${mkPath i}/") (length settingsList);
                };
              }
              {
                name = "org/gnome/shell/extensions/user-theme";
                value = {
                  name = "Catppuccin-Mocha-Standard-Blue-Dark";
                };
              }
              {
                name = "org/gnome/desktop/interface";
                value = {
                  color-scheme = "prefer-dark";
                  cursor-theme = "Catppuccin-Mocha-Dark-Cursors";
                  clock-format = "12h";
                  show-battery-percentage = true;
                };
              }
              {
                name = "org/gnome/desktop/peripherals/touchpad";
                value = {
                  natural-scroll = true;
                  disable-while-typing = true;
                  tap-to-click = true;
                  two-finger-scrolling-enabled = true;
                };
              }
              {
                name = "org/gnome/desktop/background";
                value = {
                  picture-opacity = 100;
                  picture-uri = "file:///home/ryan/Pictures/alien-bg.webp";
                  picture-uri-dark = "file:///home/ryan/Pictures/alien-bg.webp";
                };
              }
            ]);
      in
        mkSettings [
          {
            name = "wezterm";
            command = "wezterm";
            binding = "<ctrl><alt>t";
          }
        ] ;
  };


# xdg.configFile."autostart".source = dotfiles + "/autostart";
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config/autostart" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/ryan/dotfiles/autostart";
    };

    ".wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "/home/ryan/dotfiles/wezterm/.wezterm.lua";
    

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" "normal"];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "cat-mocha-blue";
      package =  pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      };
    };
  };

  xdg.configFile = {
  "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
};

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ryan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.bash.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Starship init
      starship init fish | source
      '';
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      { name = "fzf"; src = pkgs.fishPlugins.fzf.src; }
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      # Manually packaging and enable a plugin
      # {
      #   name = "z";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "jethrokuan";
      #     repo = "z";
      #     rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
      #     sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
      #   };
      # }
    ];
  };

  programs.starship =
    let
      flavour = "mocha"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
    in
    {
      enable = true;
      settings = {
        # Other config here
        format = "$all"; # Remove this line to disable the default prompt format
        palette = "catppuccin_${flavour}";
      } // builtins.fromTOML (builtins.readFile
        (pkgs.fetchFromGitHub
          {
            owner = "catppuccin";
            repo = "starship";
            rev = "5629d23"; # Replace with the latest commit hash
            sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
          } + /palettes/${flavour}.toml));
    };
}
