{
  fetchFromGitHub,
  stdenv,
  ncurses,
  neovim,
  procps,
  scdoc,
  lua51Packages,
  util-linux,
}:
stdenv.mkDerivation rec {
  pname = "nvimpager";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "lucc";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-tjnmY7dJUE5k8hlAfNKcHqmpw0ciS6T5WJOpDvvt2V0=";
  };

  buildInputs = [
    ncurses # for tput
    procps # for nvim_get_proc() which uses ps(1)
  ];
  nativeBuildInputs = [scdoc];

  makeFlags = ["PREFIX=$(out)"];
  buildFlags = ["nvimpager.configured" "nvimpager.1"];
  preBuild = ''
    patchShebangs nvimpager
    substituteInPlace nvimpager --replace ':-nvim' ':-${neovim}/bin/nvim'
  '';

  doCheck = false;
  nativeCheckInputs = [lua51Packages.busted util-linux neovim];

  # filter out one test that fails in the sandbox of nix
  checkPhase = ''
    runHook preCheck
    script -ec "busted --lpath './?.lua' --filter-out 'handles man' test"
    runHook postCheck
  '';
}
