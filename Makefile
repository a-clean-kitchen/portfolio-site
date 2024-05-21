.PHONY: depFetch

depFetch:
	nix run nixpkgs#prefetch-npm-deps -- package-lock.json
