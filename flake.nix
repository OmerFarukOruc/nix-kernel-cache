{
  description = "Builds the CachyOS kernel and NVIDIA open module that OmerFarukOruc's NixOS hosts use, for a public Cachix cache";

  # The release branch only moves after the upstream Hydra built the kernel.
  inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  outputs =
    { nix-cachyos-kernel, ... }:
    let
      # The pinned overlay builds with the input's own nixpkgs, so these store
      # paths depend only on the nix-cachyos-kernel revision in flake.lock. A
      # host that locks the same revision and uses the pinned overlay gets them
      # from the cache.
      pkgs = import nix-cachyos-kernel.inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [ nix-cachyos-kernel.overlays.pinned ];
        # The NVIDIA package is unfree; only its open kernel module, built from
        # github.com/NVIDIA/open-gpu-kernel-modules, is built and pushed.
        config.allowUnfree = true;
      };
      # One entry per CPU target a host selects (oruc.machine.kernel.profile).
      variants = [
        "x86_64-v3"
        "zen4"
      ];
      kernelPackages = variant: pkgs.cachyosKernels."linuxPackages-cachyos-latest-lto-${variant}";
      # Must match the host's hardware.nvidia.package arguments exactly.
      nvidiaOpen =
        variant:
        ((kernelPackages variant).nvidiaPackages.mkDriver {
          version = "615.78.08";
          sha256_64bit = "sha256-Pj9t3cLudnoIGFMAr3vjyyhuznZpjS3eNSRZl4LQf/4=";
          openSha256 = "sha256-HBINiOjL0ZJLIAJeNIBYHBnwgUXtNwPPtnFpAI1YwF4=";
          settingsSha256 = "sha256-inDRpG02sdDgHmlqgu/DsgK8OFdOt1fZIYyXdhlGC/c=";
          persistencedSha256 = "sha256-RzeR6Ldct6MUxjnXRyThdh5Y3jjMehTVg85MtwuWNX4=";
        }).open;
    in
    {
      inherit variants;
      packages.x86_64-linux = builtins.listToAttrs (
        builtins.concatMap (variant: [
          {
            name = "kernel-${variant}";
            value = (kernelPackages variant).kernel;
          }
          {
            name = "nvidia-open-${variant}";
            value = nvidiaOpen variant;
          }
        ]) variants
      );
    };
}
