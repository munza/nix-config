# Helpers exposed as `flake.lib`.
#
# hostVars <name>  — loads hosts/<name>/variables.nix, checks that the fields
#                    every host must declare are present, and fills in
#                    everything that can be derived from the platform and the
#                    user name. Host files should never hand-write a value this
#                    can compute.
{ inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;

  # Fields a hosts/<name>/variables.nix must declare itself. Anything not
  # listed here is either derived below or genuinely optional.
  requiredFields = [
    [
      "host"
      "platform"
    ]
    [
      "user"
      "name"
    ]
    [
      "user"
      "fullName"
    ]
    [
      "user"
      "email"
    ]
    [
      "stateVersion"
      "system"
    ]
    [
      "stateVersion"
      "home"
    ]
  ];

  assertRequired =
    name: vars:
    lib.foldl' (
      acc: path:
      if lib.hasAttrByPath path vars then
        acc
      else
        throw "hosts/${name}/variables.nix is missing required field '${lib.concatStringsSep "." path}'"
    ) vars requiredFields;

  withDefaults =
    name: vars:
    let
      isDarwin = lib.hasSuffix "-darwin" vars.host.platform;
      homeDirectory = if isDarwin then "/Users/${vars.user.name}" else "/home/${vars.user.name}";
    in
    lib.recursiveUpdate {
      host = {
        inherit name isDarwin;
        isLinux = !isDarwin;
      };
      user = { inherit homeDirectory; };
      nix.builder = if isDarwin then "darwin-rebuild" else "nixos-rebuild";
      paths.config = "${homeDirectory}/.nix-config";
      # Hosts that have not had their key generated yet cannot be secret
      # recipients; `nix-secret sync-keys` skips them.
      machine.sshPublicKeyFile = null;
    } vars;
in
{
  hostVars = name: withDefaults name (assertRequired name (import ../hosts/${name}/variables.nix));
}
