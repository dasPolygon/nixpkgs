{ lib
, appimageTools
, fetchurl
, gitUpdater
}:

let
  pname = "simplex-chat-desktop";
  version = "5.5.1";

  src = fetchurl {
    url = "https://github.com/simplex-chat/simplex-chat/releases/download/v${version}/simplex-desktop-x86_64.AppImage";
    hash = "sha256-O8QKan5kFF+9CUYXxnj6tp0Bl1RqWS2jA6cI/1L55cc=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [
      makeWrapper
    ];

    extraBwrapArgs = [
      "--setenv _JAVA_AWT_WM_NONREPARENTING 1"
    ];

    extraInstallCommands = ''
      mv $out/bin/${pname}-${version} $out/bin/${pname}

      install --mode=444 -D ${appimageContents}/chat.simplex.app.desktop --target-directory=$out/share/applications
      substituteInPlace $out/share/applications/chat.simplex.app.desktop \
        --replace 'Exec=simplex' 'Exec=${pname}'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

  meta = with lib; {
    description = "Desktop application for SimpleX Chat";
    homepage = "https://simplex.chat";
    changelog = "https://github.com/simplex-chat/simplex-chat/releases/tag/v${version}";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ yuu ];
    platforms = [ "x86_64-linux" ];
  };

  passthru.updateScript = gitUpdater {
    url = "https://github.com/simplex-chat/simplex-chat";
    rev-prefix = "v";
    # skip tags that does not correspond to official releases, like vX.Y.Z-(beta,fdroid,armv7a).
    ignoredVersions = "-";
  };
}
