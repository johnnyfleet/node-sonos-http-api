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
          #NODE_OPTIONS="--require global-agent/bootstrap";
          GLOBAL_AGENT_HTTP_PROXY="http://localhost:8080";
          GLOBAL_AGENT_HTTPS_PROXY="http://localhost:8080";


          shellHook = ''
            # generate the mitmproxy CA if you haven’t yet
            if [ ! -f "$HOME/.mitmproxy/mitmproxy-ca-cert.pem" ]; then
              echo "🔧 first run of mitmproxy – generating CA cert"
              mitmproxy --quit
            fi

            if ! command -v code &> /dev/null; then
              echo "⚠️  VSCode is not installed or not in PATH."
              echo "    You can install it with: nix-env -iA nixpkgs.vscode"
              echo "    Or use VSCodium (FOSS):   nix-env -iA nixpkgs.vscodium"
            fi

            # Install dependencies
            if [ ! -d node_modules ]; then
              npm install
              npm install global-agent
            fi

            # Export extra ca certs in shell hook to resolve $HOME.
            export NODE_EXTRA_CA_CERTS="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"
            export NODE_OPTIONS="--require global-agent/bootstrap"

            echo "🚀 Node Sonos HTTP API dev shell ready"
            echo "mitmproxy is ready. Run 'mitmproxy' or 'mitmweb'."
            echo "🔧 Proxy set: $HTTP_PROXY"

          '';
        };
      });
}
