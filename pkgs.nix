import (
  let rev = "d942688fc137169b577e7bf0c09e01a2ac919b73"; in
  fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz"
) {}
