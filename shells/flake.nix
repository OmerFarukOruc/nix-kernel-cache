{
  description = "The desktop shells OmerFarukOruc's NixOS hosts compile, built the same way for a public Cachix cache";

  # The hosts lock nixpkgs to nixos-unstable and make each shell follow it, so
  # a build here with the same nixpkgs revision and the same release tags has
  # the host's store paths.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Release tags, which scripts/pin-release.sh moves.
    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/v1.6.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { noctalia, dms, ... }:
    {
      # Both MIT licensed.
      packages.x86_64-linux = {
        noctalia = noctalia.packages.x86_64-linux.default;
        dms = dms.packages.x86_64-linux.default;
      };
    };
}
