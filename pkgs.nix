import (
  let rev = "b0bbacb52134a7e731e549f4c0a7a2a39ca6b481"; in
  fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz"
) {}
