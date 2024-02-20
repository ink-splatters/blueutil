{
  description = "blueutil";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default-darwin";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  nixConfig = {
    extra-substituters = "https://cachix.cachix.org";
    extra-trusted-public-keys =
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
  };

  outputs = { nixpkgs, flake-utils, pre-commit-hooks, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) mkShell lib;
        inherit (pkgs.llvmPackages_17) stdenv;
        inherit (pkgs.darwin.apple_sdk) frameworks;

      in {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              clang-format.enable = true;
              clang-tidy.enable = true;
              deadnix.enable = true;
              markdownlint.enable = true;
              nil.enable = true;
              nixfmt.enable = true;
              statix.enable = true;
            };

            settings.markdownlint.config = {
              MD034 = false;
              MD013.line_length = 400;
            };
            tools = pkgs;

          };
        };

        formatter = pkgs.nixfmt;

        devShells = {
          default = mkShell.override { inherit stdenv; } {

            inherit (self.packages.${system}.default)
              CFLAGS nativeBuildInputs buildInputs;

            shellHook = self.checks.${system}.pre-commit-check.shellHook + ''
              export PS1="\n\[\033[01;36m\]‹obj-⊂› \\$ \[\033[00m\]"
              echo -e "\nto install pre-commit hooks:\n\x1b[1;37mnix develop .#install-hooks\x1b[00m"
            '';
          };

          install-hooks = mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
          };
        };

        packages.default = stdenv.mkDerivation {
          CFLAGS = "-O3" + lib.optionalString ("${system}" == "aarch64-darwin")
            " -mcpu=apple-m1";

          name = "blueutil";

          src = ./.;

          nativeBuildInputs = with pkgs; [ xcodebuild gnumake ];
          buildInputs = [ frameworks.IOBluetooth ];

          buildPhase = ''
            xcodebuild -configuration Release
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp blueutil-*/*/*/*/blueutil $out/bin/blueutil
          '';
        };

      });
}
