# Comic Code, a monospaced adaptation of Comic Shanns. Licensed under the
# SSZSPL, so the OTFs live in a private repo (the `comic-code` flake input)
# rather than in this public one. All four variants ship there; every face
# carries correct family/subfamily metadata, so unlike annotation-mono no
# style rewriting is needed.
{
  pkgs,
  inputs,
}:

pkgs.stdenvNoCC.mkDerivation {
  name = "comic-code";
  src = inputs.comic-code;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/fonts/opentype"
    install -m644 "$src"/*.otf "$out/share/fonts/opentype/"

    runHook postInstall
  '';

  meta = {
    description = "Comic Code (paid font, pulled from a private repo)";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
