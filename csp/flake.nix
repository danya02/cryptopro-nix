{
  description = "Cryptography Service Provider with GOST cryptography";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {self, nixpkgs}: {
    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };

      stdenv.mkDerivation rec {
        pname = "cryptopro-csp-gui";
        version = "5.0.12000-6";
        meta = with lib; {
          sourceProvenance = with sourceTypes; [ binaryNativeCode ];
        };

        src = requireFile {
          name = "cprocsp-rdr-gui-gtk-64_5.0.12000-6_amd64.deb";
          url = "https://cryptopro.ru/products/csp/downloads";
          sha256 = "a5c01c6c4a22ea757fed594ff0275de42b89c093c44e8c0488f18242d35b0355";
        };

        nativeBuildInputs = [
          dpkg
          makeWrapper
          autoPatchelfHook
          wrapGAppsHook
          #qt5.wrapQtAppsHook
          qt6.wrapQtAppsHook
        ];
        buildInputs = [
          mesa
          alsa-lib
          nspr
          nss
 ed gnugrep coreutils xdg-utils
 glib gtk3 gtk4 gsettings-desktop-schemas
 libva pipewire wayland
 gcc nspr nss libkrb5
 qt6.qtbase
 #qt6.full
 #qt5.full
];


        dontWrapQtApps = true;

        installPhase = ''
          mkdir -p $out/bin
          cp -r usr $out
          cp -r opt $out
          cp -r usr/share $out/share
          ln -s $out/opt/chromium-gost/chromium-gost $out/bin/chromium-gost

          # we already using QT6, autopatchelf wants to patch this as well
          #rm $out/usr/lib/x86_64-linux-gnu/opera/libqt5_shim.so
          #ln -s $out/usr/bin/opera $out/bin/opera
        '';

        runtimeDependencies = [
          # Works fine without this except there is no sound.
          libpulseaudio.out

          # This is a little tricky. Without it the app starts then crashes. Then it
          # brings up the crash report, which also crashes. `strace -f` hints at a
          # missing libudev.so.0.
          (lib.getLib systemd)

          # Error at startup:
          # "Illegal instruction (core dumped)"
          gtk3
          gtk4
#        ] ++ lib.optionals proprietaryCodecs [
#          vivaldi-ffmpeg-codecs
        ];
      };
  };

}
