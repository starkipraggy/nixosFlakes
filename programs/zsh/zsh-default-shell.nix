{config, lib, pkgs, ...}:
{
  options = {
     username = lib.mkEnableOption "username to apply to"
  };

  config = {

    # Install zsh systemwide
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;

  }
}
