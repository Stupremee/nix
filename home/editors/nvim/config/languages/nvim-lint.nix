{helpers, ...}: {
  plugins.lint = {
    enable = true;
    lintersByFt = {
      nix = ["statix"];
      python = ["ruff"];
      lua = ["selene"];
      javascript = ["eslint_d"];
      javascriptreact = ["eslint_d"];
      typescript = ["eslint_d"];
      typescriptreact = ["eslint_d"];
      svelte = ["eslint_d"];
      json = ["jsonlint"];
    };

    autoCmd = {
      desc = "Lint buffer.";
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
