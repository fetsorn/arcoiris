{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    foundry.url =
      "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
  };

  outputs = { self, nixpkgs, foundry }:
    let
      eachSystem = systems: f:
        let
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key:
                let
                  appendSystem = key: system: ret: { ${system} = ret.${key}; };
                in attrs // {
                  ${key} = (attrs.${key} or { })
                    // (appendSystem key system ret);
                };
            in builtins.foldl' op attrs (builtins.attrNames ret);
        in builtins.foldl' op { } systems;
      defaultSystems = [ "x86_64-linux" "aarch64-darwin" ];
    in eachSystem defaultSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
        };
      in {

        devShell = with pkgs;
          mkShell {
            buildInputs = [
              nodejs
              yarn
              # From the foundry overlay
              # Note: Can also be referenced without overlaying as: foundry.defaultPackage.${system}
              foundry-bin

              # ... any other dependencies we need
              solc

              # to view code coverage
              lcov
            ];

            # Decorative prompt override so we know when we're in a dev shell
            shellHook = ''
              export PS1="[dev] $PS1"
            '';
          };
      });
}
