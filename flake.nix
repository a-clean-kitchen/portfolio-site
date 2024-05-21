{
  description = "NextJS Portfolio Site";

  inputs = {
    nixpkgs.url = "nixpkgs";
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pname = "portfolio-site";
      version = (builtins.fromJSON (builtins.readFile ./package.json)).version;
      buildInputs = with pkgs; [
        nodejs_20
        nodePackages_latest.pnpm
      ];
      nativeBuildInputs = buildInputs;
      npmDepsHash = "sha256-Whm88ZQgIwIdWJKp79gNH5FnleDGzNCPOIbBChzPNSw=";
    in rec {
      devShells.default = pkgs.mkShell {
        inherit buildInputs;
        shellHook = ''
          #!/usr/bin/env bash
        '';
      };
      apps.default = {
        type = "app";
        program = "${packages.default}/bin/portfolio-site";
      };
      packages.default = pkgs.buildNpmPackage {
        inherit pname version buildInputs npmDepsHash nativeBuildInputs;
        makeCacheWritable = true;
        __noChroot = true;
        src = ./.;
        postInstall = ''
          mkdir -p $out/bin
          exe="$out/bin/${pname}"
          lib="$out/lib/node_modules/${pname}"
          cp -r ./.next $lib
          touch $exe
          chmod +x $exe
          echo "
              #!/usr/bin/env bash
              cd $lib
              ${pkgs.nodePackages_latest.pnpm}/bin/pnpm run start" > $exe
        '';
      };
    });
}

