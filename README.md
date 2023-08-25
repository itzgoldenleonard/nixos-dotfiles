# Dotfiles

This is where I keep all of my system and user configuration. As much as possible is crammed into the configuration.nix file. This is still a work in progress, so not everything is set up in configuration.nix yet, but the goal is to eventually be able to deploy a fully configured system with a single command.

# Summary
## In configuration.nix
- Hardware
- Window manager
- Home manager
    - mpv
    - Nushell
        - Starship
    - Neovim
    - wiki-tui [NYI]
    - gitui [NYI]
- System packages
- Nvidia drivers
- Fonts
- Localization

## In git repo
- OBS studio [NYI]
- DaVinci Resolve transitions [NYI]
- PrusaSlicer presets [NYI]

# Install

During NixOS installation download the configuration.nix after running `nixos-generate-config` but before running `nixos-install`

```sh
sudo curl https://raw.githubusercontent.com/itzgoldenleonard/nixos-dotfiles/master/configuration.nix -o /mnt/etc/nixos/configuration.nix
```
# Post install

## Install rust packages

```sh
rustup default
cargo install sccache
RUSTC_WRAPPER=sccache cargo install nu starship wiki-tui speedtest-rs
RUSTC_WRAPPER=sccache cargo install youtube-tui --no-default-features
RUSTC_WRAPPER=sccache cargo install ytsub --features bundled_sqlite    # You might be able to install everything in one line (that's a challenge)
```

## Add network places and calendars


