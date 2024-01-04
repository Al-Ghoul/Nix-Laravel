{
  description = "Nix-Laravel hydra build & tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
        pkgs = import nixpkgs {
            system = "x86_64-linux";
        };
    in
        {
            hydraJobs = rec {
                build =
                    pkgs.php.buildComposerProject {
                        pname = "Nix-Laravel-build";
                        src = self;
                        version = "1.0.0";
                        composerNoDev = false;
                        vendorHash = "sha256-cPoOZUyIE+dixrigj9l0KksJ9sduhZn6PmbRkDqzzms=";

                        installPhase = ''
                            runHook preInstall
                            mkdir -p $out
                            mv {.,}* $out
                            ls
                            runHook postInstall
                        '';

                        passthru.tests.phpunit-tests = pkgs.stdenvNoCC.mkDerivation {
                            name ="tests";
                            src = ./.;
                            nativeBuildInputs = [ pkgs.php ];
                            buildPhase = ''
                                cp -r ${build}/{.,}* .
                                cp -a .env.example .env
                                php artisan key:generate
                            '';

                            doCheck = true;
                            checkPhase = ''
                                php artisan test
                                touch $out
                            '';
                        };
                };
                tests = build.tests;
            };
        };
}
