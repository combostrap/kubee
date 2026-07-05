let
  pkgs = import <nixpkgs> { config = {}; overlays = []; };
  nodejs = pkgs.nodejs_22;
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    nodejs
  ];
  shellHook = ''
      mkdir -p $out/bin
      export COREPACK_ENABLE_DOWNLOAD_PROMPT=0 && corepack enable --install-directory=$out/bin
      export PATH="$PATH:$out/bin"
      echo "Hallo from Nix"
      export NODE_BIN="${pkgs.nodejs}/bin/node"
      echo "Node version: $(node --version)"
      echo "NPM version: $(npm --version)"
      echo "Yarn version: $(yarn --version)"
      # create the temporary directory
      mkdir -p $TMP
      echo "Temp Dir: $TMP"
      '';
}