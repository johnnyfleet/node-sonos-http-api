{
  description = "Dev env for node-sonos-http-api";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # Allow unfree if installing vscode in this direnv.
          #config = {
          #  allowUnfree = true;
          #};
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_20  # Match the version expected by the project
            yarn       # Or npm, depending on what the project uses
            #vscode     # Optional for launching with nix-installed code
            jq         # Often useful for debugging APIs
            mitmproxy
            python3
          ];

           # Set proxy env vars directly
          HTTP_PROXY = "http://localhost:8080";
          HTTPS_PROXY = "http://localhost:8080";
          NODE_LOG_LEVEL= "debug";

          shellHook = ''
            echo "🚀 Node Sonos HTTP API dev shell ready"
            echo "mitmproxy is ready. Run 'mitmproxy' or 'mitmweb'."
            echo "🔧 Proxy set: $HTTP_PROXY"

            if ! command -v code &> /dev/null; then
              echo "⚠️  VSCode is not installed or not in PATH."
              echo "    You can install it with: nix-env -iA nixpkgs.vscode"
              echo "    Or use VSCodium (FOSS):   nix-env -iA nixpkgs.vscodium"
            fi

            if [ ! -d node_modules ]; then
              npm install
            fi
          '';
        };
      });
}
