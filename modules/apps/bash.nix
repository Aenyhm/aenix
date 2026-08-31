{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      programs.bash = {
        enable = true;
        shellAliases = {
          ll = "ls -la";
          clipboard = "wl-copy";
          zed = "zeditor";
        };
        # Current git branch in the prompt
        initExtra = ''
          source ${pkgs.git}/share/git/contrib/completion/git-prompt.sh
          PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
        '';
      };
      # `uv tool install` puts its commands there
      home.sessionPath = [ "$HOME/.local/bin" ];
    };
}
