# AnnotationMono, with usable style metadata.
#
# pkgs.annotation-mono ships all 40 static instances (plus otf copies and a
# variable font). Every one of them declares subfamily "Regular" with the
# italic and bold bits unset — the style lives only in the typographic names,
# which font matchers ignore. To a matcher the whole family is 80 identical
# faces, so apps pick one arbitrarily; Zed lands on the upright italic.
#
# Keep the four faces worth having and give them the metadata that lets a
# matcher tell them apart: legacy family/subfamily plus the OS/2 and head
# style bits.
{ pkgs, ... }:

let
  # Rewrites each face in place; see the header for what and why.
  fixStyles = pkgs.writeText "annotation-mono-styles.py" ''
    import sys
    from fontTools.ttLib import TTFont

    FAMILY = "Annotation Mono"
    FACES = [
        ("Regular.ttf", "Regular", False, False),
        ("Bold.ttf", "Bold", True, False),
        ("Regular_Italic.ttf", "Italic", False, True),
        ("Bold_Italic.ttf", "Bold Italic", True, True),
    ]

    ITALIC, BOLD, REGULAR = 0b1, 0b100000, 0b1000000

    for filename, subfamily, bold, italic in FACES:
        path = sys.argv[1] + "/" + filename
        font = TTFont(path)

        name = font["name"]
        name.names = [r for r in name.names if r.nameID not in (16, 17)]
        for record in name.names:
            if record.nameID == 1:
                record.string = FAMILY
            elif record.nameID == 2:
                record.string = subfamily
            elif record.nameID == 4:
                record.string = FAMILY + " " + subfamily

        flags = font["OS/2"].fsSelection & ~(ITALIC | BOLD | REGULAR)
        flags |= ITALIC if italic else 0
        flags |= BOLD if bold else 0
        flags |= 0 if (bold or italic) else REGULAR
        font["OS/2"].fsSelection = flags

        style = font["head"].macStyle & ~0b11
        style |= 0b01 if bold else 0
        style |= 0b10 if italic else 0
        font["head"].macStyle = style

        font.save(path)
  '';

  font = pkgs.annotation-mono.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      (pkgs.python3.withPackages (ps: [ ps.fonttools ]))
    ];
    postInstall = (old.postInstall or "") + ''
      find "$out/share/fonts" -type f \
        ! -name Regular.ttf ! -name Bold.ttf \
        ! -name Regular_Italic.ttf ! -name Bold_Italic.ttf -delete
      # Upstream installs the faces read-only; fontTools rewrites in place.
      chmod u+w "$out/share/fonts/truetype"/*.ttf
      python3 ${fixStyles} "$out/share/fonts/truetype"
      chmod a-w "$out/share/fonts/truetype"/*.ttf
    '';
  });
in
font
