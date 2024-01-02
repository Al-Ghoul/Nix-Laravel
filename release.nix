{
    siteSrc ? builtins.fetchTarball https://github.com/al-ghoul/Nix-Laravel/archive/main.tar.gz
}:
    let
     pkgs = (import <nixpkgs> { system = builtins.currentSystem or "x86_64-linux"; });
     jobs = with pkgs; {
         laravel-tests = php.buildComposerProject (finalAttrs: {
             pname = "Nix-Laravel";
             src = siteSrc;
             version = "1.0.0";
             composerNoDev = false;
             vendorHash = "sha256-cPoOZUyIE+dixrigj9l0KksJ9sduhZn6PmbRkDqzzms=";

             postFixupHooks = ''
                 cp -a .env.example .env
                 php artisan key:generate
                 php vendor/bin/phpunit
             '';
         });
    };
  in
    jobs
