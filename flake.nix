{
  description = "basic swift development shell";

  outputs = { nixpkgs, flake-utils, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      with pkgs; {

        formatter = nixpkgs-fmt;

        devShell = mkShell.override { inherit (llvmPackages) stdenv; }
          {

            shellHook = ''
              export PS1="\n\[\033[01;32m\]\u $\[\033[00m\]\[\033[01;36m\] \w >\[\033[00m\] "
            '';

            nativeBuildInputs = with darwin.apple_sdk.frameworks; [
              xcodebuild
	      IOBluetooth
            ];
          };
      });
}
