{
  description = "Godot 4.0 alpha 1";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.src = {
    url = https://downloads.tuxfamily.org/godotengine/4.0/alpha2/godot-4.0-alpha2.tar.xz;
    flake = false;
  };

  outputs = { self, src, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in {
      defaultPackage.x86_64-linux = pkgs.stdenv.mkDerivation {
        name = "godot4";

        src = src;

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          scons
          udev
          xorg.libX11
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXrandr
          xorg.libXrender
          xorg.libXi
          xorg.libXext
          xorg.libXfixes
          freetype
          openssl
          alsa-lib
          libpulseaudio
          libGLU
          zlib
          yasm
        ];


        installPhase = ''
          cp $src/README.md $out
        '';
      };
    };
}
