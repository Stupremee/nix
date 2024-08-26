{
  unstable-pkgs,
  theme,
  ...
}: {
  home.packages = with unstable-pkgs; [
    kubectl
    kubernetes-helm
    k9s
    kubelogin
    kubent
    argo
  ];

  programs.zsh.initExtra = ''
    load_plugin kubectl
  '';

  xdg.configFile."k9s/skin.yml".text = ''
    base: &base "${theme.base}"
    mantle: &mantle "${theme.mantle}"
    crust: &crust "${theme.crust}"
    blue: &blue "${theme.blue}"
    flamingo: &flamingo "${theme.flamingo}"
    green: &green "${theme.green}"
    lavender: &lavender "${theme.lavender}"
    maroon: &maroon "${theme.maroon}"
    mauve: &mauve "${theme.mauve}"
    overlay0: &overlay0 "${theme.overlay0}"
    overlay1: &overlay1 "${theme.overlay1}"
    overlay2: &overlay2 "${theme.overlay2}"
    peach: &peach "${theme.peach}"
    pink: &pink "${theme.pink}"
    red: &red "${theme.red}"
    rosewater: &rosewater "${theme.rosewater}"
    sapphire: &sapphire "${theme.sapphire}"
    sky: &sky "${theme.sky}"
    subtext0: &subtext0 "${theme.subtext0}"
    subtext1: &subtext1 "${theme.subtext1}"
    surface0: &surface0 "${theme.surface0}"
    surface1: &surface1 "${theme.surface1}"
    surface2: &surface2 "${theme.surface2}"
    teal: &teal "${theme.teal}"
    text: &text "${theme.text}"
    yellow: &yellow "${theme.yellow}"

    # Skin...
    k9s:
      # General K9s styles
      body:
        fgColor: *text
        bgColor: *base
        logoColor: *mauve

      # Command prompt styles
      prompt:
        fgColor: *text
        bgColor: *mantle
        suggestColor: *blue

      # ClusterInfoView styles.
      info:
        fgColor: *peach
        sectionColor: *text

      # Dialog styles.
      dialog:
        fgColor: *yellow
        bgColor: *overlay2
        buttonFgColor: *base
        buttonBgColor: *overlay1
        buttonFocusFgColor: *base
        buttonFocusBgColor: *pink
        labelFgColor: *rosewater
        fieldFgColor: *text

      frame:
        # Borders styles.
        border:
          fgColor: *mauve
          focusColor: *lavender

        # MenuView attributes and styles
        menu:
          fgColor: *text
          keyColor: *blue
          # Used for favorite namespaces
          numKeyColor: *maroon

        # CrumbView attributes for history navigation.
        crumbs:
          fgColor: *base
          bgColor: *maroon
          activeColor: *flamingo

        # Resource status and update styles
        status:
          newColor: *blue
          modifyColor: *lavender
          addColor: *green
          pendingColor: *peach
          errorColor: *red
          highlightColor: *sky
          killColor: *mauve
          completedColor: *overlay0

        # Border title styles.
        title:
          fgColor: *teal
          bgColor: *base
          highlightColor: *pink
          counterColor: *yellow
          filterColor: *green

      views:
        # Charts skins...
        charts:
          bgColor: *base
          chartBgColor: *base
          dialBgColor: *base
          defaultDialColors:
            - *green
            - *red
          defaultChartColors:
            - *green
            - *red
          resourceColors:
            cpu:
              - *mauve
              - *blue
            mem:
              - *yellow
              - *peach

        # TableView attributes.
        table:
          fgColor: *text #Doesn't Work
          bgColor: *base
          cursorFgColor: *surface0 # Doesn't Work
          cursorBgColor: *surface1 # should be rosewater
          markColor: *rosewater # Doesn't Work
          # Header row styles.
          header:
            fgColor: *yellow
            bgColor: *base
            sorterColor: *sky

        # Xray view attributes.
        xray:
          fgColor: *text #Doesn't Work
          bgColor: *base
          # Need to set this to a dark color since color text can't be changed
          # Ideally this would be rosewater
          cursorColor: *surface1
          cursorTextColor: *base #Doesn't Work
          graphicColor: *pink

        # YAML info styles.
        yaml:
          keyColor: *blue
          colonColor: *subtext0
          valueColor: *text

        # Logs styles.
        logs:
          fgColor: *text
          bgColor: *base
          indicator:
            fgColor: *lavender
            bgColor: *base

      help:
        fgColor: *text
        bgColor: *base
        sectionColor: *green
        keyColor: *blue
        numKeyColor: *maroon
  '';
}
