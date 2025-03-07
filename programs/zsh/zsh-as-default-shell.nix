{config, lib, pkgs, usernameList, ...}:
{
#   options = {
#     username = lib.mkEnableOption "username to apply to";
#   };

#   config = {

    # Install zsh systemwide
    programs.zsh.enable = true;

    users.users = lib.genAttrs usernameList (name: { shell = pkgs.zsh; } );

#   };
}
