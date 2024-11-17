{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		flake-parts.url = "github:hercules-ci/flake-parts";
	};

	outputs = { nixpkgs, flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
		systems = nixpkgs.lib.platforms.unix;
		perSystem = { pkgs, ... }: {
			packages.default = pkgs.callPackage ./nix/package.nix { inherit pkgs; };
			devShells.default = pkgs.callPackage ./nix/package.nix { inherit pkgs; isShell = true; };
		};
	};
}
