# { pkgs, pkgInfo, nix-filter }: let
# 
#  self = {
#   bun = (pkgs.bun.overrideAttrs { version = "1.1.8"; });
# 
#   node_modules
#  };
# 
# in self
# 
# 
{ pkgs, pkgInfo }: let 
  nm = (pkgs.callPackage ./default.nix {}).nodeDependencies;
in 
pkgs.stdenv.mkDerivation rec {
  inherit (pkgInfo) name buildInputs version;
  nativeBuildInputs = pkgInfo.buildInputs;
  src = ./.;
  __noChroot = true;
  configurePhase = ''
    # Get the deps
    ln -s ${nm}/lib/node_modules ./node_modules
    export PATH="${nm}/bin:$PATH"

    mkdir $out
  '';
  
  buildPhase = ''
    runHook preBuild

    # Build time
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    cp -r .next/ $out
    cp -r public $out/public

    # Re-link the node_modules
    rm $out/node_modules
    mv node_modules $out/node_modules

    mkdir -p $out/bin

    
    cat <<ENTRYPOINT > $out/portfolio-site
    #!${pkgs.stdenv.shell}
    exec "$(type -p npm)" "exec -- next start" "$out/.next/" "$$@"
    ENTRYPOINT
    
    chmod +x $out/portfolio-site
    runHook postInstall
  '';
}
