{helpers, ...}: {
  plugins.lint = {
    enable = true;
    lintersByFt = {
      nix = ["statix"];
      python = ["ruff"];
      lua = ["selene"];
      javascript = ["eslint_d" "eslint"];
      javascriptreact = ["eslint_d" "eslint"];
      typescript = ["eslint_d" "eslint"];
      typescriptreact = ["eslint_d" "eslint"];
      svelte = ["eslint_d" "eslint"];
      vue = ["eslint_d" "eslint"];
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
