.PHONY: depHashFetch

depHashFetch:
	nix run nixpkgs#prefetch-npm-deps -- package-lock.json
