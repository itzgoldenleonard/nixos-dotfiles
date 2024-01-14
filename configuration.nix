{ config, lib, pkgs, ... }:

let 
  dotfiles-repo = pkgs.fetchFromGitHub {
    owner = "itzgoldenleonard";
    repo = "nixos-dotfiles";
    rev = "c5429052d22ba91706cc0864cb21442584c26be4";
    sha256 = "ok6id1cTy6zIl7tfi5sCxvXMioB+vbIuGZiMP59NOiw=";
  };

  /*
  unstable = import (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable";
      }) { config = config.nixpkgs.config; };
      */
  
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  imports =
    [
      ./hardware-configuration.nix  # Hardware scan
      (import "${home-manager}/nixos")
    ];

  /********************\
  **  Window manager  **
  \********************/
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true; # Disables the display manager
  services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.libinput.enable = true; # touchpad support

/*    ██   ██  ██████  ███    ███ ███████     ███    ███  █████  ███    ██  █████   ██████  ███████ ██████  
 *    ██   ██ ██    ██ ████  ████ ██          ████  ████ ██   ██ ████   ██ ██   ██ ██       ██      ██   ██ 
 *    ███████ ██    ██ ██ ████ ██ █████       ██ ████ ██ ███████ ██ ██  ██ ███████ ██   ███ █████   ██████  
 *    ██   ██ ██    ██ ██  ██  ██ ██          ██  ██  ██ ██   ██ ██  ██ ██ ██   ██ ██    ██ ██      ██   ██ 
 *    ██   ██  ██████  ██      ██ ███████     ██      ██ ██   ██ ██   ████ ██   ██  ██████  ███████ ██   ██  */

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ava = { pkgs, config, osConfig, ... }: {
    programs.bash.enable = true;
    home.stateVersion = "23.05";
    home.packages = with pkgs; [ 
      libsForQt5.kate
      libsForQt5.kmail
      libsForQt5.kontact
      libsForQt5.kaddressbook
      libsForQt5.korganizer
      libsForQt5.knotes
      partition-manager
      prusa-slicer
      wiki-tui
      sccache
      inkscape
      hugin
      openscad
      gnome-solanum
      tor-browser-bundle-bin
      tokei
      blender
      libreoffice-qt
      rawtherapee
      docker-compose
      merkuro
      dmenu-wayland
    ];


    /*******\
    ** mpv **
    \*******/
    programs.mpv = {
      enable = true;
      config = { ytdl-format = "bestvideo[height<=?1080]+bestaudio/best"; }; # Limit youtube to 1080p to load faster
      bindings = { F = "script-binding quality_menu/video_formats_toggle"; };
      scripts = with pkgs.mpvScripts; [ mpris quality-menu sponsorblock webtorrent-mpv-hook ];
    };

    /***********\
    **  Shell  **
    \***********/
    # Nu
    # ==
    programs.nushell = {
      enable = true;
      envFile.text = ''
        $env.PROMPT_INDICATOR = { $"(ansi green_bold)❯ " }
        $env.PROMPT_INDICATOR_VI_INSERT = { $"(ansi green_bold): " }
        $env.PROMPT_INDICATOR_VI_NORMAL = { $"(ansi green_bold)❯ " }
        $env.PROMPT_MULTILINE_INDICATOR = { "::: " }
      '';
      shellAliases = {
          config = "git $'--git-dir=($env.HOME)/.dotfiles' $'--work-tree=($env.HOME)'";
      };
      configFile.text = ''
        let dark_theme = {
            # color for nushell primitives
            separator: white
            leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
            header: green_bold
            empty: blue
            # Closures can be used to choose colors for specific values.
            # The value (in this case, a bool) is piped into the closure.
            bool: { if $in { 'light_cyan' } else { 'light_gray' } }
            int: white
            filesize: {|e|
                if $e == 0b {
                    'white'
                } else if $e < 1mb {
                    'cyan'
                } else { 'blue' }
            }
            duration: white
            date: { (date now) - $in |
                if $in < 1hr {
                    'red3b'
                } else if $in < 6hr {
                    'orange3'
                } else if $in < 1day {
                    'yellow3b'
                } else if $in < 3day {
                    'chartreuse2b'
                } else if $in < 1wk {
                    'green3b'
                } else if $in < 6wk {
                    'darkturquoise'
                } else if $in < 52wk {
                    'deepskyblue3b'
                } else { 'dark_gray' }
            }
            range: white
            float: white
            string: white
            nothing: white
            binary: white
            cellpath: white
            row_index: green_bold
            record: white
            list: white
            block: white
            hints: dark_gray

            shape_and: purple_bold
            shape_binary: purple_bold
            shape_block: blue_bold
            shape_bool: light_blue
            shape_custom: green
            shape_datetime: cyan_bold
            shape_directory: blue
            shape_external: light_blue
            shape_externalarg: green_bold
            shape_filepath: blue
            shape_flag: blue_bold
            shape_float: purple_bold
            # shapes are used to change the cli syntax highlighting
            shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
            shape_globpattern: cyan_bold
            shape_int: purple_bold
            shape_internalcall: blue_bold
            shape_list: blue_bold
            shape_literal: blue
            shape_matching_brackets: { attr: u }
            shape_nothing: light_cyan
            shape_operator: yellow
            shape_or: purple_bold
            shape_pipe: purple_bold
            shape_range: yellow_bold
            shape_record: blue_bold
            shape_redirection: purple_bold
            shape_signature: green_bold
            shape_string: green
            shape_string_interpolation: cyan_bold
            shape_table: blue_bold
            shape_variable: purple
        }


        # The default config record. This is where much of your global configuration is setup.
        $env.config = {
            edit_mode: vi # emacs, vi
            cursor_shape: {
                vi_insert: line # block, underscore, line (block is the default)
                vi_normal: block # block, underscore, line  (underscore is the default)
            }

            ls: {
                use_ls_colors: true # use the LS_COLORS environment variable to colorize output
                clickable_links: true # enable or disable clickable links. Your terminal has to support links.
            }

            #cd: {
                #abbreviations: true # allows `cd s/o/f` to expand to `cd some/other/folder`
            #}

            table: {
                mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
                index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
                trim: {
                    methodology: wrapping # wrapping or truncating
                    wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
                    truncating_suffix: "..." # A suffix used by the 'truncating' methodology
                }
            }

            history: {
                max_size: 1000 # Session has to be reloaded for this to take effect
                sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
                file_format: "plaintext" # "sqlite" or "plaintext"
            }

            completions: {
                case_sensitive: false # set to true to enable case-sensitive completions
                quick: true  # set this to false to prevent auto-selecting completions when only one remains
                partial: true  # set this to false to prevent partial filling of the prompt
                algorithm: "prefix"  # prefix or fuzzy
                external: {
                    enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
                    max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
                    completer: null # check 'carapace_completer' above as an example
                }
            }

            color_config: $dark_theme   # if you want a light theme, replace `$dark_theme` to `$light_theme`
            use_grid_icons: true
            footer_mode: "25" # always, never, number_of_rows, auto
            show_banner: false
            render_right_prompt_on_last_line: true # true or false to enable or disable right prompt to be rendered on last line of the prompt.

            float_precision: 2 # the precision for displaying floats in tables
            buffer_editor: "nvim" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
            use_ansi_coloring: true
            shell_integration: true # enables terminal markers and a workaround to arrow keys stop working issue

            menus: [
                # Configuration for default nushell menus
                {
                    name: completion_menu
                    only_buffer_difference: false
                    marker: "| "
                    type: {
                        layout: columnar
                        columns: 4
                        col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                        col_padding: 2
                    }
                    style: {
                        text: green
                        selected_text: green_reverse
                        description_text: yellow
                    }
                }

                {
                    name: history_menu
                    only_buffer_difference: true
                    marker: "? "
                    type: {
                        layout: list
                        page_size: 10
                    }
                    style: {
                        text: green
                        selected_text: green_reverse
                        description_text: yellow
                    }
                }

                {
                    name: help_menu
                    only_buffer_difference: true
                    marker: "? "
                    type: {
                        layout: description
                        columns: 4
                        col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                        col_padding: 2
                        selection_rows: 4
                        description_rows: 10
                    }
                    style: {
                        text: green
                        selected_text: green_reverse
                        description_text: yellow
                    }
                }

                # Custom menu (from the default config)
                {
                    name: vars_menu
                    only_buffer_difference: true
                    marker: "# "
                    type: {
                        layout: list
                        page_size: 10
                    }
                    style: {
                        text: green
                        selected_text: green_reverse
                        description_text: yellow
                    }
                    source: { |buffer, position|
                        $nu.scope.vars
                        | where name =~ $buffer
                        | sort-by name
                        | each { |it| {value: $it.name description: $it.type} }
                    }
                }
            ]

            keybindings: [
                {
                    name: completion_previous
                    modifier: shift
                    keycode: backtab
                    mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
                    event: { send: menuprevious }
                }

                {
                    name: next_page
                    modifier: control
                    keycode: char_x
                    mode: [emacs, vi_normal, vi_insert]
                    event: { send: menupagenext }
                }

                {
                    name: undo_or_previous_page
                    modifier: control
                    keycode: char_z
                    mode: [emacs, vi_normal, vi_insert]
                    event: { send: menupageprevious }
                }

                # Keybindings used to trigger the menus
                {
                    name: completion_menu
                    modifier: none
                    keycode: tab
                    mode: [emacs vi_normal vi_insert]
                    event: {
                        until: [
                            { send: menu name: completion_menu }
                            { send: menunext }
                        ]
                    }
                }

                {
                    name: history_menu
                    modifier: control
                    keycode: char_r
                    mode: [emacs vi_normal vi_insert]
                    event: { send: menu name: history_menu }
                }

                {
                    name: vars_menu
                    modifier: alt
                    keycode: char_o
                    mode: [emacs, vi_normal, vi_insert]
                    event: { send: menu name: vars_menu }
                }

                {
                    name: help_menu
                    modifier: control
                    keycode: char_h
                    mode: [emacs, vi_normal, vi_insert]
                    event: { send: menu name: help_menu }
                }
            ]
        } 
      '';
    };

    # Starship
    # ========
    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        format = lib.concatStrings [
          "$sudo"
          "$username"
          "$os"
          "$directory"
        ];
        right_format = lib.concatStrings [
          "$git_commit"
          "$git_status"
          "$git_branch"
          ""
          "$container"
          "$c"
          "$rust"
          "$python"
          "$nodejs"
          ""
          "$time"
          "$battery"
        ];
        add_newline = false;
        # Left prompt configuration
        sudo = {
          disabled = false;
          style = "bold yellow";
          format = "[$symbol]($style)";
          symbol = " ";
        };
        username = {
          show_always = true;
          style_user = "bold green";
          style_root = "bold red";
          format = "[$user]($style)";
          disabled = false;
        };
        os = {
          disabled = false;
          style = "bold green";
          format = "[$symbol]($style)";
        };
        os.symbols = {
          Alpine = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "﯑ ";
          Gentoo = " ";
          HardenedBSD = "ﲊ ";
          Illumos = " ";
          Linux = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = " ";
          openSUSE = " ";
          OracleLinux = " ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          Redox = " ";
          Solus = "ﴱ ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Windows = " ";
        };
        directory = {
          truncation_length = 3;
          style = "bold green";
          format = "[$path]($style)[$read_only]($read_only_style)";
          read_only = " ";
          truncation_symbol = "…/";
        };
        directory.substitutions = {
          "Documents" = " ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          "Videos" = "";
        };
        # Right prompt
        git_commit = {
          style = "bold purple";
        };
        git_status = {
          style = "bold purple";
          format = "([\\[ $ahead_behind$conflicted$untracked$stashed$modified$staged$renamed$deleted\\]]($style))";
          ahead = "[⇡($count )](green)";
          behind = "[⇣($count )](bright-red)";
          conflicted = "[=($count )](blink underline red)";
          untracked = "[?($count )](purple)";
          stashed = "[$($count )](yellow)";
          modified = "[!($count )](bright-red)";
          staged = "[+($count )](bright-green)";
          renamed = "[»($count )](yellow)";
          deleted = "[󰩹($count )](bright-red)";
        };
        git_branch = {
          symbol = "";
          style = "bold purple";
          format = "[ $symbol $branch(:remote_branch)]($style) |";
          truncation_length = 10;
        };
        # Languages
        c = {
          symbol = "";
          style = "bright-blue";
          format = "[ $symbol]($style) |";
        };

        rust = {
          symbol = "󱘗";
          style = "yellow";
          format = "[ $symbol]($style) |";
        };

        python = {
          symbol = "";
          format = "[ \${symbol}\${pyenv_prefix}( \\($virtualenv\\))]($style) |";
        };

        nodejs = {
          symbol = "";
          style = "green";
          format = "[ $symbol]($style) |";
        };

        time = {
          disabled = false;
          time_format = "%R"; # Hour:Minute Format
          format = "[  $time ]($style)";
        };

        # This is to be configured later
        battery = {
          disabled = false;
        };
      };
    };

    # General user shell config (to be used outside of nushell too)
    # =============================================================
    home.sessionVariables = {
      RUSTC_WRAPPER="sccache";
      DOTFILES_DIR="${config.xdg.configHome}/dotfiles";
    };

    /**********\
    ** Neovim ** TODO: Maybe do plugin management with <https://rycee.gitlab.io/home-manager/options.html#opt-programs.neovim.plugins>
    \**********/
    programs.neovim = {
      enable = true;
      extraLuaConfig = ''
        --------------
        -- Settings --
        --------------
        local g = vim.g
        local o = vim.o
        local A = vim.api
        
        -- Visual changes
        o.relativenumber = true                     -- Relative line numbers
        o.number = true                             -- Current line number
        o.splitbelow = true                         -- Split below by default
        o.splitright = true                         -- Split right by default
        o.background = 'dark'                       -- Tell nvim that I'm using dark mode
        o.showtabline = 2                           -- Always show the tab line
        o.termguicolors = true                      -- True color support
        -- Behavior
        o.mouse = 'a'                               -- Always enable mouse
        o.scrolloff = 6                             -- Always keep 6 lines above/below cursor
        o.hidden = true                             -- Required to keep multiple buffers open
        o.foldmethod = 'indent'                     -- Folding always uses indent mode
        o.clipboard = 'unnamedplus'                 -- Use system clipboard
        o.updatetime = 300                          -- Decrease update time
        o.timeoutlen = 500                          -- Make something faster
        -- Indentation
        o.tabstop = 4                               -- Tell nvim that tabs are 4 spaces wide
        o.autoindent = true                         -- Autoindent on enter
        o.shiftwidth = 4                            -- Number of spaces to use for autoindent
        o.smarttab = true                           -- Insert the correct number of spaces with Tab key
        o.expandtab = true                          -- Change <Tab> to spaces
        o.smartindent = true                        -- Autoindent on new lines
        
        -----------------
        -- Keybindings --
        -----------------
        local function map(m, k, v)
            vim.keymap.set(m, k, v, { silent = true })
        end
        
        -- Set the <leader> key to space
        g.mapleader = ' '
        g.maplocalleader = ' '
        
        -- Use alt + hjkl to resize windows
        map('n', '<M-j>', ':resize -2<CR>')
        map('n', '<M-k>', ':resize +2<CR>')
        map('n', '<M-h>', ':vertical resize -2<CR>')
        map('n', '<M-l>', ':vertical resize +2<CR>')
        
        -- Use Tab to move between buffers
        map('n', '<TAB>', ':bnext<CR>')
        map('n', '<S-TAB>', ':bprevious<CR>')
        
        -------------
        -- Plugins --
        -------------
        -- Bootstrap packer
        local fn = vim.fn
        local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
        if fn.empty(fn.glob(install_path)) > 0 then
            packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
            vim.cmd [[packadd packer.nvim]]
        end
        -- Automatically run :PackerCompile whenever init.lua is updated with an autocommand:
        A.nvim_create_autocmd('BufWritePost', {
            group = A.nvim_create_augroup('PACKER', { clear = true }),
            pattern = 'init.lua',
            command = 'source <afile> | PackerCompile',
        })
        
        --------------------------
        -- Plugin configuration --
        --------------------------
        -- Svelte
        g.vim_svelte_plugin_use_typescript = 1
        g.vim_svelte_plugin_use_sass = 1
        -- Ale
        g.ale_completion_enabled = 1
        g.ale_linters = {['rust'] = {'analyzer'}}
        
        -- Install plugins
        return require('packer').startup(function(use)
            use 'wbthomason/packer.nvim'            -- Packer itself
            use 'fneu/breezy'                       -- Colorscheme
            -- Languages
            use 'leafOfTree/vim-svelte-plugin'
            use 'leafgarland/typescript-vim'
            use 'sirtaj/vim-openscad'
            use 'rust-lang/rust.vim'
            -- Tools
            use 'dense-analysis/ale'
            use 'dhruvasagar/vim-table-mode'
            use 'lambdalisue/suda.vim'
        
        
            -- Automatically set up your configuration after cloning packer.nvim
            -- Put this at the end after all plugins
            if packer_bootstrap then
                require('packer').sync()
            end
        
            -- These need to be here or it wont start the first time
            vim.cmd 'colorscheme breezy'                -- Set colorscheme to breezy
            A.nvim_set_hl(0, "Normal", { bg='None' })   -- Transparent background
        end)
      '';
    };

    /****************\
    **  OBS Studio  **
    \****************/
    programs.obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.wlrobs ];
    };
    home.file."${config.xdg.configHome}/obs-studio/basic" = {
      source = (dotfiles-repo + "/obs-studio");
      recursive = true;
    };

    /*********************\
    **  DaVinci Resolve  **
    \*********************/
    home.file."${config.home.homeDirectory}/.local/share/DaVinciResolve/Fusion/Templates/Edit/Transitions" = {
      source = (dotfiles-repo +  "/davinci-resolve");
      recursive = true;
    };

    /*****************\
    **  PrusaSlicer  **
    \*****************/
    home.file."${config.xdg.configHome}/PrusaSlicer" = {
      source = (dotfiles-repo + "/prusa-slicer");
      recursive = true;
    };

    /**************\
    **  wiki-tui  **
    \**************/
    home.file."${config.xdg.configHome}/wiki-tui/config.toml" = {
      text = ''
        [api]
        base_url = 'https://en.wikipedia.org/'

        [theme]
        text = 'white'
        title = 'light magenta'
        highlight = '#1b668f'
        background = 'black'
        search_match = 'light cyan'
        highlight_text = 'white'
        highlight_inactive = 'black'

        [logging]
        enabled = false

        [features]
        links = true
        toc = true

        # Vim keybinds
        [keybindings]
        down.key = 'j'
        up.key = 'k'
        left.key = 'h'
        right.key = 'l'
        focus_next.key = 'tab'
        focus_next.mode = 'normal'
        focus_prev.key = 'tab'
        focus_prev.mode = 'shift'

        [settings.toc]
        position = 'left'
        title = 'article'
        min_width = 20
        max_width = 40
        scroll_x = true
        scroll_y = true
        item_format = '{NUMBER} {TEXT}'
      '';
    };

    /***********\
    **  gitui  **
    \***********/
    programs.gitui = {
      enable = true;
      keyConfig = ''
        (
            open_help: Some(( code: F(1), modifiers: ( bits: 0,),)),

            move_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
            move_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
            move_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
            move_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),
            
            popup_up: Some(( code: Char('p'), modifiers: ( bits: 2,),)),
            popup_down: Some(( code: Char('n'), modifiers: ( bits: 2,),)),
            page_up: Some(( code: Char('b'), modifiers: ( bits: 2,),)),
            page_down: Some(( code: Char('f'), modifiers: ( bits: 2,),)),
            home: Some(( code: Char('g'), modifiers: ( bits: 0,),)),
            end: Some(( code: Char('G'), modifiers: ( bits: 1,),)),
            shift_up: Some(( code: Char('K'), modifiers: ( bits: 1,),)),
            shift_down: Some(( code: Char('J'), modifiers: ( bits: 1,),)),

            edit_file: Some(( code: Char('I'), modifiers: ( bits: 1,),)),

            status_reset_item: Some(( code: Char('U'), modifiers: ( bits: 1,),)),

            diff_reset_lines: Some(( code: Char('u'), modifiers: ( bits: 0,),)),
            diff_stage_lines: Some(( code: Char('s'), modifiers: ( bits: 0,),)),

            stashing_save: Some(( code: Char('w'), modifiers: ( bits: 0,),)),
            stashing_toggle_index: Some(( code: Char('m'), modifiers: ( bits: 0,),)),

            stash_open: Some(( code: Char('l'), modifiers: ( bits: 0,),)),

            abort_merge: Some(( code: Char('M'), modifiers: ( bits: 1,),)),
        )
      '';
      theme = ''
        (
            selected_tab: Reset,
            command_fg: White,
            selection_bg: Blue,
            selection_fg: White,
            cmdbar_bg: Reset,
            cmdbar_extra_lines_bg: Blue,
            disabled_fg: DarkGray,
            diff_line_add: Green,
            diff_line_delete: Red,
            diff_file_added: LightGreen,
            diff_file_removed: LightRed,
            diff_file_moved: LightMagenta,
            diff_file_modified: Yellow,
            commit_hash: Magenta,
            commit_time: LightCyan,
            commit_author: Green,
            danger_fg: Red,
            push_gauge_bg: Blue,
            push_gauge_fg: Reset,
            tag_fg: LightMagenta,
            branch_fg: LightYellow,
        )
      '';
    };

    /*********\
    **  GPG  **
    \*********/
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "qt";
    };

    /*************\
    **  Firefox  **
    \*************/
    programs.firefox = {
      enable = true;
      profiles.ava = {
        search = {
          default = "Brave";
          force = true;
          engines = {
            "Brave" = {
              urls=[{
                template = "https://search.brave.com/search";
                params = [ { name = "q"; value = "{searchTerms}"; } ];
              }];
              icon = "https://cdn.search.brave.com/serp/v1/static/brand/eebf5f2ce06b0b0ee6bbd72d7e18621d4618b9663471d42463c692d019068072-brave-lion-favicon.png";
            };
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Wiby" = {
              urls = [{
                template = "https://wiby.me";
                params = [ { name = "q"; value = "{searchTerms}"; } ];
              }];
              icon = "https://wiby.me/favicon.ico";
              definedAliases = [ "@m" "@w" ];
            };
            "Bing".metaData.hidden = true;
            "Google".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
          };
        };
        settings = {
          # Misc
          "browser.search.region" = "World";
          "intl.regional_prefs.use_os_locales" = true;
          # Security / anti-tracking
          "dom.security.https_only_mode" = true;
          "browser.contentblocking.category" = "strict";
          "privacy.donottrackheader.enabled" = true;
          "signon.rememberSignons" = false;
          # New tab page
          "browser.newtabpage.pinned" = null;
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = null;
          "browser.newtabpage.activity-stream.topSitesRows" = 2;
          # https://github.com/arkenfox/user.js/blob/master/user.js
          # Arkenfox [0100]
          "browser.startup.page" = 3; #102
          "browser.startup.homepage" = "about:home"; #103
          "browser.newtabpage.activity-stream.showSponsored" = false; #105
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false; #105
          "browser.newtabpage.activity-stream.default.sites" = ""; #106
          # Arkenfox [0200]
          "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%"; #201
          "geo.provider.use_gpsd" = false; #202
          "geo.provider.use_geoclue" = false; #202
          "intl.accept_languages" = "en-US, en"; #210
          "javascript.use_us_english_locale" = true; #211
          # Arkenfox [0300]
          "extensions.getAddons.showPane" = false; #320
          "extensions.htmlaboutaddons.recommendations.enabled" = false; #321
          "browser.discovery.enabled" = false; #322
          "datareporting.policy.dataSubmissionEnabled" = false; #330
          "datareporting.healthreport.uploadEnabled" = false; #331
          "toolkit.telemetry.unified" = false; #332
          "toolkit.telemetry.enabled" = false; #332
          "toolkit.telemetry.server" = "data:,"; #332
          "toolkit.telemetry.archive.enabled" = false; #332
          "toolkit.telemetry.newProfilePing.enabled" = false; #332
          "toolkit.telemetry.shutdownPingSender.enabled" = false; #332
          "toolkit.telemetry.updatePing.enabled" = false; #332
          "toolkit.telemetry.bhrPing.enabled" = false; #332
          "toolkit.telemetry.firstShutdownPing.enabled" = false; #332
          "toolkit.telemetry.coverage.opt-out" = true; #333
          "toolkit.coverage.opt-out" = true; #333
          "toolkit.coverage.endpoint.base" = ""; #333
          "browser.ping-centre.telemetry" = false; #334
          "browser.newtabpage.activity-stream.feeds.telemetry" = false; #335
          "browser.newtabpage.activity-stream.telemetry" = false; #336
          "app.shield.optoutstudies.enabled" = false; #340
          "app.normandy.enabled" = false; #341
          "app.normandy.api_url" = ""; #341
          "breakpad.reportURL" = ""; #350
          "browser.tabs.crashReporting.sendReport" = false; #350
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; #351
          "captivedetect.canonicalURL" = ""; #360
          "network.captive-portal-service.enabled" = false; #360
          "network.connectivity-service.enabled" = false; #361
          # Arkenfox [0400]
          "browser.safebrowsing.downloads.remote.enabled" = false;
          # Arkenfox [0600]
          "network.http.speculative-parallel-limit" = 0; #604
          "browser.places.speculativeConnect.enabled" = false; #605
          "browser.send_pings" = false; #610
          # Arkenfox [0700]
          "network.file.disable_unc_paths" = true; #703
          "network.gio.supported-protocols" = ""; #704
          "network.trr.mode" = 5; #710
          # Arkenfox [0800]
          "browser.fixup.alternate.enabled" = false; #802
          "browser.search.suggest.enabled" = false; #804
          "browser.urlbar.suggest.searches" = false; #804
          "browser.urlbar.speculativeConnect.enabled" = false; #805
          "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0; #806
          "browser.urlbar.suggest.quicksuggest.sponsored" = false; #807
          "browser.formfill.enable" = false; #810
          # Arkenfox [0900]
          "signon.autofillForms" = false; #903
          "signon.formlessCapture.enabled" = false; #904
          "network.auth.subresource-http-auth-allow" = 1; #905
          # Arkenfox [1200]
          "security.ssl.require_safe_negotiation" = true; #1201
          "security.tls.enable_0rtt_data" = false; #1206
          "security.OCSP.require" = true; #1212
          "security.cert_pinning.enforcement_level" = 2; #1223
          "dom.security.https_only_mode_send_http_background_request" = false; #1246
          "security.ssl.treat_unsafe_negotiation_as_broken" = true; #1270
          "browser.xul.error_pages.expert_bad_cert" = true; #1272
          # Arkenfox [1600]
          "network.http.referer.XOriginTrimmingPolicy" = 2; #1602
          # Arkenfox [1700]
          "privacy.userContext.enabled" = true; #1701
          "privacy.userContext.ui.enabled" = true; #1701
          # Arkenfox [2400]
          "dom.disable_window_move_resize" = true; #2402
          # Arkenfox [2600]
          "browser.helperApps.deleteTempFileOnExit" = true; #2603
          "browser.uitour.enabled" = false; #2606
          "browser.uitour.url" = ""; #2606
          "devtools.debugger.remote-enabled" = false; #2608
          "permissions.manager.defaultsUrl" = ""; #2616
          "network.IDN_show_punycode" = true; #2619
          "pdfjs.enableScripting" = false; #2620
          "permissions.delegation.enabled" = false; #2623
          "browser.tabs.searchclipboardfor.middleclick" = false; #2624
          "browser.download.manager.addToRecentDocs" = false; #2653
          "browser.download.always_ask_before_handling_new_types" = true; #2654
          "extensions.enabledScopes" = 5; #2660
          "extensions.postDownloadThirdPartyPrompt" = false; #2661
          # Arkenfox [2700]
          "privacy.partition.serviceWorkers" = true; #2710
          "privacy.partition.always_partition_third_party_non_cookie_storage" = true; #2720
          "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = false; #2720
          # Arkenfox [2800]
          "privacy.sanitize.sanitizeOnShutdown" = true; #2810
          "privacy.clearOnShutdown.cache" = true; #2811
          "privacy.clearOnShutdown.downloads" = false; #2811
          "privacy.clearOnShutdown.formdata" = true; #2811
          "privacy.clearOnShutdown.history" = false; #2811
          "privacy.clearOnShutdown.sessions" = false; #2811
          "privacy.clearOnShutdown.cookies" = false; #2815
          # Arkenfox [4500]
          "browser.link.open_newwindow" = 3; #4512
          "browser.link.open_newwindow.restriction" = 0; #4513
          # Arkenfox [5000]
          "extensions.formautofill.creditCards.enabled" = false; #5017
          # Arkenfox [9000]
          "browser.startup.homepage_override.mstone" = "ignore"; #9001
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false; #9002
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false; #9002
          "browser.messaging-system.whatsNewPanel.enabled" = false; #9003
        };
      };
    };

    /**********\
    **  Pass  **
    \**********/
    programs.password-store = {
      enable = true;
      package = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
    };
  };



/* ███████ ██    ██ ███████ ████████ ███████ ███    ███ 
 * ██       ██  ██  ██         ██    ██      ████  ████ 
 * ███████   ████   ███████    ██    █████   ██ ████ ██ 
 *      ██    ██         ██    ██    ██      ██  ██  ██ 
 * ███████    ██    ███████    ██    ███████ ██      ██  */
  /*************\
  ** Packages  **
  \*************/
  system.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
     wl-clipboard
     git
     rustup
     appimage-run             # TODO: could this be a user package
     davinci-resolve # This too
  ];
  programs.kdeconnect.enable = true;
  programs.dconf.enable = true; # This is neccessary for glib apps to change settings

  # Neovim
  # ======
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  # Nvidia drivers
  # ==============
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = ["nvidia"]; # Tell Xorg to use the nvidia driver (also valid for Wayland)
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Use the open source version of the kernel module Only available on driver 515.43.04+
    nvidiaSettings = true;
    prime = {
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:34:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  # Fonts
  # =====
  fonts = {
    packages = with pkgs; [ roboto roboto-serif roboto-mono (nerdfonts.override { fonts = ["FiraCode"]; }) ];
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "FiraCode Nerd Font" "Roboto Mono" ];
      serif = [ "Roboto Serif" "Noto Serif" ];
      sansSerif = [ "Roboto" "Noto Sans" ];
    };
  };


  /****************\
  **  Bootloader  **
  \****************/
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;


  /****************\
  **  Networking  **
  \****************/
  networking.networkmanager.enable = true; # Enable networking
  networking.networkmanager.wifi.scanRandMacAddress = false;
  networking.hostName = "ava-laptop-nix";
  # networking.wireless.enable = true;


  /**************\
  **  Printing  **
  \**************/
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;
  services.printing.drivers = with pkgs; [ gutenprint ];


  /******************\
  **  Localization  **
  \******************/
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_DK.UTF-8";
    LC_IDENTIFICATION = "en_DK.UTF-8";
    LC_MEASUREMENT = "en_DK.UTF-8";
    LC_MONETARY = "en_DK.UTF-8";
    LC_NAME = "en_DK.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_DK.UTF-8";
    LC_TELEPHONE = "en_DK.UTF-8";
    LC_TIME = "en_DK.UTF-8";
  };
  console.keyMap = "dvorak";


  /***********\
  **  Sound  **
  \***********/
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  /**********\
  **  User  **
  \**********/
  users.users.ava = {
    isNormalUser = true;
    description = "Ava Drumm";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}

/* Configuration with sway
let 
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ava-desktop-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_DK.UTF-8";
    LC_IDENTIFICATION = "en_DK.UTF-8";
    LC_MEASUREMENT = "en_DK.UTF-8";
    LC_MONETARY = "en_DK.UTF-8";
    LC_NAME = "en_DK.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_DK.UTF-8";
    LC_TELEPHONE = "en_DK.UTF-8";
    LC_TIME = "en_DK.UTF-8";
  };

  fonts = {
    fonts = with pkgs; [ (nerdfonts.override { fonts = ["FiraCode"]; }) ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [ swaylock-effects swayidle xwayland ];
    extraOptions = [ "--unsupported-gpu" "--verbose" "--debug" ];
  };
  security.polkit.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ava = {
    isNormalUser = true;
    description = "Ava Drumm";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
      nushell
      starship
    #  thunderbird
    ];
  };
  
  security.doas.enable = true;
  security.doas.extraRules = [ { users = [ "ava" ]; persist = true; keepEnv = true; } ];

  home-manager.users.ava = { pkgs, ... }: {
    home.packages = [ pkgs.cowsay ];
    programs.bash.enable = true;
    home.stateVersion = "23.05";

    /*
    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        # Use kitty as default terminal
        terminal = "alacritty"; 
        startup = [
          # Launch Firefox on start
          {command = "firefox";}
        ];
      };
    };
    */
  /*
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     alacritty
     dbus-sway-environment
     configure-gtk
     wayland
     xdg-utils
     glib
     dracula-theme
     gnome3.adwaita-icon-theme
     swaylock
     swayidle
     grim
     slurp
     wl-clipboard
     bemenu
     mako
     wdisplays
     neovim
     git
     rustup
  ];

  # Nvidia drivers
  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
*/
