{
  inputs = {
    flutter-flake.url = "github:schuelermine/flutter-flake/b0";
    flake-utils.url = "github:numtide/flake-utils/master";
  };
  outputs = { self, nixpkgs, flutter-flake, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = flutter-flake.lib.get-devShell {
        inherit nixpkgs system;
        enable-android = true;
        nixpkgsConfig = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
    });
}
