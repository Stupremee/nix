{helpers, ...}: {
  plugins.lint = {
    enable = true;
    lintersByFt = {
      nix = ["statix"];
      python = ["ruff"];
      lua = ["selene"];
      javascript = ["eslint"];
      javascriptreact = ["eslint"];
      typescript = ["eslint"];
      typescriptreact = ["eslint"];
      svelte = ["eslint"];
      vue = ["eslint"];
      json = ["jsonlint"];
    };

    autoCmd = {
      event = "BufWritePost";
      desc = "Lint buffer";
    };
  };

  # Autocmd for linting on insert leave.
  # Only possible for some linters.
  autoCmd = [
    {
      event = ["InsertLeave"];
      pattern = ["*.nix" "*.lua"];
      callback = helpers.mkRaw ''
        function() require('lint').try_lint() end
      '';
    }
  ];
}
