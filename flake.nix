{
  description = "Godot 4.0 alpha 1"; # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/tools/godot/default.nix

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.src = {
    url = https://downloads.tuxfamily.org/godotengine/4.0/alpha2/godot-4.0-alpha2.tar.xz;
    flake = false;
  };

  outputs = { self, src, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
        options = {
          touch = true;
          pulseaudio = false;
          udev = true;
        };
    in {
      packages.x86_64-linux.godot = pkgs.stdenv.mkDerivation {
        pname = "godot";
        version = "4.0-alpha2";

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
          xorg.libXrandr xorg.libXrender
          xorg.libXi
          xorg.libXext
          xorg.libXfixes
          freetype
          openssl
          alsa-lib
          alsa-lib.dev
          libpulseaudio
          libGLU
          zlib
          yasm
          vulkan-loader
        ];

        patches = [ ./pkg_config_additions.patch ./dont_clobber_environment.patch ];

        outputs = ["out" "dev" "man"];

        sconsFlags = "-j 8 target=debug platform=linuxbsd";

        preConfigure = ''
          sconsFlags+=" ${
            pkgs.lib.concatStringsSep " "
            (pkgs.lib.mapAttrsToList (k: v: "${k}=${builtins.toJSON v}") options)
          }"
        '';

        installPhase = ''
          mkdir -p "$out/bin"
          cp bin/godot.* $out/bin/godot
          mkdir "$dev"
          cp -r modules/gdnative/include $dev
          mkdir -p "$man/share/man/man6"
          cp misc/dist/linux/godot.6 "$man/share/man/man6/"
          mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
          cp misc/dist/linux/org.godotengine.Godot.desktop "$out/share/applications/"
          cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
          cp icon.png "$out/share/icons/godot.png"
          substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
            --replace "Exec=godot" "Exec=$out/bin/godot"
        '';
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.godot;
      
      packages.x86_64-linux.godot-export-templates = self.packages.x86_64-linux.godot.overrideAttrs (oldAttrs: {
        pname = "godot-export-templates";
        sconsFlags = "-j 8 target=release platform=linuxbsd tools=no";
        installPhase = ''
          # The godot export command expects the export templates at
          # .../share/godot/templates/3.2.3.stable with 3.2.3 being the godot version.
          mkdir -p "$out/share/godot/templates/4.0.alpha2"
          cp bin/godot.linuxbsd.opt.64 $out/share/godot/templates/4.0.alpha2/linux_x11_64_release
        '';
        outputs = [ "out" ];
      });
    };
}
