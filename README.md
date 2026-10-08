# nix-kernel-cache

Builds the CachyOS kernel (`linux-cachyos-latest-lto-x86_64-v3` and
`linux-cachyos-latest-lto-zen4` from
[nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel)) and the
NVIDIA open kernel module for each on GitHub Actions and pushes them to a public Cachix
cache, so the NixOS hosts that use them do not compile them.

The kernel's store path depends only on the nix-cachyos-kernel revision in
`flake.lock`, because the input's `pinned` overlay builds with the input's own
nixpkgs. A host gets a cache hit when it locks the same revision and uses the
`pinned` overlay. The NVIDIA module also needs the same `mkDriver` arguments as
the host's `hardware.nvidia.package`.

The `variants` list in `flake.nix` names the CPU targets; each one builds in
its own job. The workflow builds on every push to `main`, and once a day after moving
`flake.lock` to the head of the upstream `release` branch. After the build and
the push to Cachix succeed, it commits `flake.lock` with `cached-paths.json`,
which lists the nix-cachyos-kernel revision, the kernel version and every pushed
output path. A host checks
those paths in the cache before it locks the same revision.

Nothing unfree is built or pushed. The NVIDIA module builds from
[open-gpu-kernel-modules](https://github.com/NVIDIA/open-gpu-kernel-modules).

## Setup

- Repository variable `CACHIX_CACHE`: the Cachix cache name. The workflow skips
  while it is unset.
- Repository secret `CACHIX_AUTH_TOKEN`: a Cachix token that may push to that
  cache.
