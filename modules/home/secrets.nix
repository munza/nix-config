# sops-nix secrets
#
# Secrets live in a separate private repo, pulled in as the `secrets` flake
# input so no ciphertext lands in this public one. That repo holds:
#
#   secrets/common.json     — every host
#   secrets/<hostname>.json — that host only
#
# Which keys may decrypt which file is declared in its .sops.yaml, generated
# from hosts/*/variables.nix by `nix-secret sync-keys`.
#
# Changes there do not take effect until the input is bumped; `nix-secret sync`
# does that for you.
#
# sops encrypts values but leaves the keys in plaintext, so the secret names
# below are read straight out of the JSON at evaluation time — there is no
# registry to keep in sync. Only ciphertext is ever read.
#
# USAGE:
#   Secrets are loaded as environment variables automatically:
#     $GITHUB_ACCESS_TOKEN      -> <actual secret value>
#     $GITHUB_ACCESS_TOKEN_FILE -> path to the decrypted file
#
#   nix-secret            — interactive menu
#   nix-secret add        — add a secret and choose its scope
#   nix-secret read <n>   — print a secret's value
#   nix-secret edit       — open a whole scope in $EDITOR
#   nix-secret rekey      — re-encrypt after .sops.yaml changes
#   nix-secret sync-keys  — regenerate .sops.yaml from hosts/*/variables.nix
#
#   Pass config.sops.secrets.<name>.path to services that support secret files.
#   Never read secret contents during Nix evaluation; that exposes them in the store.
{
  inputs,
  config,
  lib,
  var,
  ...
}:

let
  # Scopes that apply to this host, narrowest last so a host-specific value
  # overrides a common one of the same name.
  scopeFiles = builtins.filter (f: builtins.pathExists f.file) [
    {
      scope = "common";
      file = "${inputs.secrets}/secrets/common.json";
    }
    {
      scope = var.host.name;
      file = "${inputs.secrets}/secrets/${var.host.name}.json";
    }
  ];

  # sops keeps object keys in plaintext, so this reads names only.
  namesIn =
    file:
    builtins.filter (n: n != "sops") (builtins.attrNames (builtins.fromJSON (builtins.readFile file)));

  secrets = builtins.listToAttrs (
    lib.concatMap (
      f:
      map (name: {
        inherit name;
        value = {
          inherit (f) file;
        };
      }) (namesIn f.file)
    ) scopeFiles
  );

  secretToEnv = name: lib.strings.toUpper (builtins.replaceStrings [ "-" ] [ "_" ] name);
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  # A host with no secrets file yet is valid; sops stays inert.
  config = lib.mkIf (secrets != { }) {
    sops = {
      age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      defaultSopsFormat = "json";
      defaultSopsFile = (builtins.head scopeFiles).file;

      secrets = lib.mapAttrs (_: s: {
        sopsFile = s.file;
        format = "json";
        mode = "0400";
      }) secrets;
    };

    home.sessionVariables = lib.mapAttrs' (name: _: {
      name = "${secretToEnv name}_FILE";
      value = config.sops.secrets.${name}.path;
    }) secrets;

    programs.zsh.initContent = lib.concatMapStrings (
      name:
      let
        envName = secretToEnv name;
        filePath = config.sops.secrets.${name}.path;
      in
      ''
        if [[ -s "${filePath}" ]]; then
          export ${envName}="$(<"${filePath}")"
        fi
      ''
    ) (builtins.attrNames secrets);
  };
}
