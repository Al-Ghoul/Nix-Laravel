{
    siteSrc ? builtins.fetchTarball https://github.com/al-ghoul/Nix-Laravel/archive/main.tar.gz
}:
    let
     pkgs = (import <nixpkgs> { system = builtins.currentSystem or "x86_64-linux"; });
     jobs = with pkgs; rec {
         laravel-build = php.buildComposerProject (finalAttrs: {
             pname = "Nix-Laravel";
             src = siteSrc;
             version = "1.0.0";
             composerNoDev = false;
             vendorHash = "sha256-cPoOZUyIE+dixrigj9l0KksJ9sduhZn6PmbRkDqzzms=";

             installPhase = ''
                 runHook preInstall
                 mkdir -p $out
                 mv {.,}* $out
                 runHook postInstall
             '';

             passthru.tests.phpunit-tests = stdenvNoCC.mkDerivation {
                 name ="tests";
                 src = ./.;
                 buildInputs = [ pkgs.php ];
                 buildPhase = ''
                     cp -r ${laravel-build}/{.,}* .
                     cp -a .env.example .env
                     ./artisan key:generate
                 '';

                 doCheck = true;
                 checkPhase = ''
                    ./vendor/bin/phpunit
                     touch $out
                 '';
             };
         });
         tests = laravel-build.tests;
     };
  in
    jobs
