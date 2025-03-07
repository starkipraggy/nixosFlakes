# starki's NixOS flake configuration

## Aims

Create a NixOS config that is
 - Portable
 - Reproducible
 - Modular
 - Doesn't get in the way
   - One command to build.
     - Home Manager as nixOS module
   - Configuration files that see high churn to be symlinked into Nix
     - Reduce building which is time-consuming. Let Git do its job

## Roadmap

 - [x] Enable flakes
 - [x] Incorporate Home Manager as nixOS module
 - [ ] Multihost
   - [ ] Desktop
   - [ ] VM
   - [ ] Surface Pro 9 (Intel)
 - [ ] Secret Management
 - [ ] Link high churn dotfiles without it being managed by Home Manager
   - [ ]  vim/neovim config (pick one)
