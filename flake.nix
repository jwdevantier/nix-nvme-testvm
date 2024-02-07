{
  description = "NVMe test environment VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators }:
    let
      allSystems = [
        "x86_64-linux" # AMD/Intel Linux
        "aarch64-linux" # ARM Linux
      ];

      forAllSystems = fn:
        nixpkgs.lib.genAttrs allSystems
        (system: fn { pkgs = import nixpkgs { inherit system; }; });

    in {
      # used when calling `nix fmt <path/to/flake.nix>`
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt);

      apps = forAllSystems ({ pkgs, ... }:
        let
          make-overlay-script = pkgs.runCommandLocal "make-overlay" {
            script = ./scripts/make-overlay;
            nativeBuildInputs = [ pkgs.makeWrapper ];
          } ''
            makeWrapper $script $out/bin/make-overlay.sh \
              --prefix PATH : ${
                pkgs.lib.makeBinPath (with pkgs; [ bash qemu coreutils ])
              }
          '';
        in {
          make-overlay = {
            type = "app";
            program = "${make-overlay-script}/bin/make-overlay.sh";
          };
        });

      # nix run|build <flake-ref>#<pkg-name>
      # -- 
      # $ nix run <flake-ref>#hello
      # $ nix run <flake-ref>#cowsay
      packages = forAllSystems ({ pkgs }:
        let python3Packages = pkgs.python311Packages;
        in rec {
          libvfn = pkgs.callPackage ./packages/libvfn { };
          xnvme = pkgs.callPackage ./packages/xnvme {
            inherit libvfn python3Packages;
          };
          xnvme-py = pkgs.callPackage ./packages/xnvme-py {
            inherit xnvme python3Packages;
          };
          vm = nixos-generators.nixosGenerate {
            system = pkgs.system;
            modules = [
              # add configuration.nix here
              (import ./configuration.nix {
                inputs = self.inputs;
                flake = self;
              })
            ];
            format = "qcow";
          };
        });
    };
}
