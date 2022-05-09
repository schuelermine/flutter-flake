{
  outputs = { self }: {
    templates.android = {
      path = ./android;
      description =
        "A flake for getting a dev shell with Android SDK & Flutter using flutter-flake";
    };
    lib = let
      optional = q: x: optList q [ x ];
      optList = q: xs: if q then xs else [ ];
      optStr = q: str:
        if q then ''
          ${str}
        '' else
          "";
      guard = q: k: if q then k else null;

    in {
      get-devShell = { nixpkgs, pkgs ? import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
      }, system, nixpkgsConfig ? { }, enable-android ? false
        , enable-linuxDesktop ? false, enable-web ? true
        , enable-windowsDesktop ? false, enable-macDesktop ? false
        , enable-ios ? false
        , chromeExecutable ? pkgs.ungoogled-chromium + "/bin/chromium" }:

        let
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            platformToolsVersion = "31.0.3";
            toolsVersion = "26.1.1";
          };

          flutter-deps = optional enable-android androidComposition.androidsdk
            ++ optList enable-linuxDesktop
            (with pkgs; [ clang cmake ninja pkg-config gtk3.dev pcre epoxy ]);

          flutter-fhs = pkgs.buildFHSUserEnv {
            name = "flutter";
            targetPkgs = (_: flutter-deps);
            runScript = pkgs.flutter + "/bin/flutter";
          };

        in if enable-ios || enable-macDesktop || enable-windowsDesktop then
          builtins.throw ''
            iOS, macOS and Windows are not supported currently. Feel free to contribute.
          ''
        else
          assert !enable-ios;
          assert !enable-macDesktop;
          assert !enable-windowsDesktop;
          pkgs.mkShell {
            packages = with pkgs; [ flutter-fhs ] ++ flutter-deps;
            shellHook = optStr enable-android ''
              flutter config --enable-android
              flutter config --android-sdk ${androidComposition.androidsdk}/libexec/android-sdk
            '' + optStr enable-linuxDesktop ''
              flutter config --enable-linux-desktop
            '' + optStr enable-web ''
              export CHROME_EXECUTABLE=${chromeExecutable}
            '';
          };
    };
  };
}
