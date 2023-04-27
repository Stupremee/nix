{
  buildVimPluginFrom2Nix,
  fetchurl,
}: {
  cmp-luasnip = buildVimPluginFrom2Nix {
    pname = "cmp-luasnip"; # Manifest entry: "saadparwaiz1/cmp_luasnip"
    version = "2022-10-28";
    src = fetchurl {
      url = "https://github.com/saadparwaiz1/cmp_luasnip/archive/18095520391186d634a0045dacaa346291096566.tar.gz";
      sha256 = "0jqpw18bss2hrj0iz6qa7lkh2gp01xmp2gfjv4dq89iq2qj1zs5m";
    };
  };
  todo-comments-nvim = buildVimPluginFrom2Nix {
    pname = "todo-comments-nvim"; # Manifest entry: "folke/todo-comments.nvim"
    version = "2023-03-31";
    src = fetchurl {
      url = "https://github.com/folke/todo-comments.nvim/archive/8febc60a76feefd8203077ef78b6a262ea1a41f9.tar.gz";
      sha256 = "174ixil5qjpxxjkp73r7x6s5y6hr5b771c6x9hkhqp9al916i9bw";
    };
  };
  vim-illuminate = buildVimPluginFrom2Nix {
    pname = "vim-illuminate"; # Manifest entry: "RRethy/vim-illuminate"
    version = "2023-03-19";
    src = fetchurl {
      url = "https://github.com/RRethy/vim-illuminate/archive/a2907275a6899c570d16e95b9db5fd921c167502.tar.gz";
      sha256 = "1066wclghw6h61slx956v4ri57rxv65rf92c8mb890rp5yljckay";
    };
  };
  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path"; # Manifest entry: "hrsh7th/cmp-path"
    version = "2022-10-03";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-path/archive/91ff86cd9c29299a64f968ebb45846c485725f23.tar.gz";
      sha256 = "052aclqk5fdcx2870h6y128x9lbwkqs7acc13xv7pdx0hgc6h7zp";
    };
  };
  indent-blankline-nvim = buildVimPluginFrom2Nix {
    pname = "indent-blankline-nvim"; # Manifest entry: "lukas-reineke/indent-blankline.nvim"
    version = "2023-02-20";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/indent-blankline.nvim/archive/018bd04d80c9a73d399c1061fa0c3b14a7614399.tar.gz";
      sha256 = "1g8c8gqnr9wksys6pkywq85hm4z7ym0a2gpk35knic0dwij2k3gw";
    };
  };
  move-nvim = buildVimPluginFrom2Nix {
    pname = "move-nvim"; # Manifest entry: "fedepujol/move.nvim"
    version = "2023-04-21";
    src = fetchurl {
      url = "https://github.com/fedepujol/move.nvim/archive/d663b74b4e38f257aae757541c9076b8047844d6.tar.gz";
      sha256 = "1g2yhs5b8sw5xzyi6nmb7bvxyg05zrdn2iaicwjjbc3lmyg4a176";
    };
  };
  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag"; # Manifest entry: "windwp/nvim-ts-autotag"
    version = "2023-04-20";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-ts-autotag/archive/26761ba6848d814605a629bc8d2694eeb1e48007.tar.gz";
      sha256 = "1pbvi2skjdf6ajl8qcv1yrn6g1l7s7v5pb38xs2w6691h1bcwyh0";
    };
  };
  base64-nvim = buildVimPluginFrom2Nix {
    pname = "base64-nvim"; # Manifest entry: "moevis/base64.nvim"
    version = "2022-04-28";
    src = fetchurl {
      url = "https://github.com/moevis/base64.nvim/archive/67fb5f12db252b3e2bd190250d3edbed7aa8d3aa.tar.gz";
      sha256 = "0sim06pq12gkdkzblff418nrx7r73qx4njq5cdw7vr7xvph3gl86";
    };
  };
  nvim-autopairs = buildVimPluginFrom2Nix {
    pname = "nvim-autopairs"; # Manifest entry: "windwp/nvim-autopairs"
    version = "2023-04-20";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-autopairs/archive/7566a86f44bb72ba2b1a609f528a27d93241502d.tar.gz";
      sha256 = "004q5fypajkg40gng9fwz5d2slqxvbnkjjbh54rqq2zq6gqnnp94";
    };
  };
  catppuccin-nvim = buildVimPluginFrom2Nix {
    pname = "catppuccin-nvim"; # Manifest entry: "catppuccin/nvim"
    version = "2023-04-25";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/dd176757cc745f71bd54c472a9f58d5f8a54661d.tar.gz";
      sha256 = "0ja22nqvvijs2qfhx6zbc19jk14ky3ajfmq2rq6njhl3viyv2yy5";
    };
  };
  nvim-notify = buildVimPluginFrom2Nix {
    pname = "nvim-notify"; # Manifest entry: "rcarriga/nvim-notify"
    version = "2023-04-19";
    src = fetchurl {
      url = "https://github.com/rcarriga/nvim-notify/archive/159c6cf1be25a933f35e97499314c9faab55c98f.tar.gz";
      sha256 = "0yfcigh5diypbzsabs4d7fgh90jmxvc7vzq26wj14y21yqid3piq";
    };
  };
  lsp-zero-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-zero-nvim"; # Manifest entry: "VonHeikemen/lsp-zero.nvim"
    version = "2023-04-27";
    src = fetchurl {
      url = "https://github.com/VonHeikemen/lsp-zero.nvim/archive/0457b5d7e6a6c1632fdfafc9d5553ef0138e7088.tar.gz";
      sha256 = "1w0ry1jlzdjpz5k7ifzjnhg3fi2l5v1zfhjvvdg77w0krd88rxbl";
    };
  };
  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline-nvim"; # Manifest entry: "akinsho/bufferline.nvim"
    version = "2023-04-24";
    src = fetchurl {
      url = "https://github.com/akinsho/bufferline.nvim/archive/a4bd44523316928a7c4a5c09a3407d02c30b6027.tar.gz";
      sha256 = "1rfb3p5rb582fiqy1xfly8zgwrvwqsrg3mp05y4vir7q0szrlxy0";
    };
  };
  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer"; # Manifest entry: "hrsh7th/cmp-buffer"
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-buffer/archive/3022dbc9166796b644a841a02de8dd1cc1d311fa.tar.gz";
      sha256 = "0zs9j63w3h00ba1c70q6gq1r6z9s8qiisv91wi4nkkp2akpnmf2v";
    };
  };
  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp"; # Manifest entry: "hrsh7th/nvim-cmp"
    version = "2023-04-27";
    src = fetchurl {
      url = "https://github.com/hrsh7th/nvim-cmp/archive/11102d3db12c7f8b35265ad0e17a21511e5b1e68.tar.gz";
      sha256 = "18k90i6ggswpfdab48f7rn4lgjzdv6afz1vmrlyxdpbbkzdxfd2g";
    };
  };
  lualine-nvim = buildVimPluginFrom2Nix {
    pname = "lualine-nvim"; # Manifest entry: "nvim-lualine/lualine.nvim"
    version = "2023-04-09";
    src = fetchurl {
      url = "https://github.com/nvim-lualine/lualine.nvim/archive/84ffb80e452d95e2c46fa29a98ea11a240f7843e.tar.gz";
      sha256 = "1h9dv3icxrspmbpx956rw9gn3iyk4c99c9rx69qalrndcqgfd8gq";
    };
  };
  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp"; # Manifest entry: "hrsh7th/cmp-nvim-lsp"
    version = "2023-02-06";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lsp/archive/0e6b2ed705ddcff9738ec4ea838141654f12eeef.tar.gz";
      sha256 = "0wyy7bn8dayjx3f337gr6hwbn93822igqziyn0p57g8wisg2rbkl";
    };
  };
  copilot-cmp = buildVimPluginFrom2Nix {
    pname = "copilot-cmp"; # Manifest entry: "zbirenbaum/copilot-cmp"
    version = "2023-04-06";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot-cmp/archive/99467081478aabe4f1183a19a8ba585e511adc20.tar.gz";
      sha256 = "0dml06py42h7g3pc8rsrsbbqxy0arq6xcpzh7kzqr5birhqf41bl";
    };
  };
  vim-bbye = buildVimPluginFrom2Nix {
    pname = "vim-bbye"; # Manifest entry: "moll/vim-bbye"
    version = "2018-03-03";
    src = fetchurl {
      url = "https://github.com/moll/vim-bbye/archive/25ef93ac5a87526111f43e5110675032dbcacf56.tar.gz";
      sha256 = "0f7nixmwkhhiv4xmq063gdl0x0xykn1m8pz564yj1ggbh00pka1c";
    };
  };
  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons"; # Manifest entry: "nvim-tree/nvim-web-devicons"
    version = "2023-04-11";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-web-devicons/archive/4ec26d67d419c12a4abaea02f1b6c57b40c08d7e.tar.gz";
      sha256 = "17fvp2d618pw42h72mwixzvlq2x5xvn1kng94rp1rxynpi4pdzfa";
    };
  };
  gitsigns-nvim = buildVimPluginFrom2Nix {
    pname = "gitsigns-nvim"; # Manifest entry: "lewis6991/gitsigns.nvim"
    version = "2023-04-21";
    src = fetchurl {
      url = "https://github.com/lewis6991/gitsigns.nvim/archive/7dfe4be94b4f84a9931098f0f0f618d055e50bd5.tar.gz";
      sha256 = "0aam518375cbxsmjyg8iryb0kpxig5d4pvlnwgz7wdcfjmnjcain";
    };
  };
  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig"; # Manifest entry: "neovim/nvim-lspconfig"
    version = "2023-04-27";
    src = fetchurl {
      url = "https://github.com/neovim/nvim-lspconfig/archive/427378a03ffc1e1bc023275583a49b1993e524d0.tar.gz";
      sha256 = "13527q6wvir7mbk7z341j11csr3wxnr3ij1dwaiy7rwhvwxg6rnd";
    };
  };
  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim"; # Manifest entry: "stevearc/dressing.nvim"
    version = "2023-04-22";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/f5d7fa1fa5ce6bcebc8f07922f39b1eda4d01e37.tar.gz";
      sha256 = "0fzavzxpyl26y7mliaa06rf51p5ps9v3i1hhlwml0p0kf1psdxdk";
    };
  };
  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim"; # Manifest entry: "lewis6991/impatient.nvim"
    version = "2022-12-28";
    src = fetchurl {
      url = "https://github.com/lewis6991/impatient.nvim/archive/c90e273f7b8c50a02f956c24ce4804a47f18162e.tar.gz";
      sha256 = "1gd53v888q76j13gjf2lb0lyyaj4jxf1h77rqd3dl0csb19rlp9n";
    };
  };
  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring"; # Manifest entry: "JoosepAlviste/nvim-ts-context-commentstring"
    version = "2023-04-18";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/0bf8fbc2ca8f8cdb6efbd0a9e32740d7a991e4c3.tar.gz";
      sha256 = "046sgywxs3s4yvy1x7yhdbxc4v1z26mrdsgn7jgsk5qbgq8zf2qa";
    };
  };
  comment-nvim = buildVimPluginFrom2Nix {
    pname = "comment-nvim"; # Manifest entry: "numToStr/Comment.nvim"
    version = "2023-04-12";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/a89339ffbee677ab0521a483b6dac7e2e67c907e.tar.gz";
      sha256 = "0vl7nlxqwis9b9ma0wpdgh6p01rk8jcplqqzamhhs798fk01ar4p";
    };
  };
  rust-tools-nvim = buildVimPluginFrom2Nix {
    pname = "rust-tools-nvim"; # Manifest entry: "simrat39/rust-tools.nvim"
    version = "2023-02-20";
    src = fetchurl {
      url = "https://github.com/simrat39/rust-tools.nvim/archive/71d2cf67b5ed120a0e31b2c8adb210dd2834242f.tar.gz";
      sha256 = "1g01hml8a4pz7jswllfkrmw3qqmfxm2b41pccm62wxzlwbv1q2ps";
    };
  };
  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim"; # Manifest entry: "nvim-lua/plenary.nvim"
    version = "2023-04-10";
    src = fetchurl {
      url = "https://github.com/nvim-lua/plenary.nvim/archive/9ac3e9541bbabd9d73663d757e4fe48a675bb054.tar.gz";
      sha256 = "16gh8ijvb5g4bzx7lm8cpnk5jbjjmanhidiaydp7n8mbqy4qxjb7";
    };
  };
  cmp-nvim-lua = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lua"; # Manifest entry: "hrsh7th/cmp-nvim-lua"
    version = "2023-04-14";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lua/archive/f12408bdb54c39c23e67cab726264c10db33ada8.tar.gz";
      sha256 = "0yl83fyy0h0hnc4ph4503pdv2mv3y97ddzb8hy5gqsv8lih8zxpf";
    };
  };
  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree-lua"; # Manifest entry: "nvim-tree/nvim-tree.lua"
    version = "2023-04-24";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-tree.lua/archive/bb375fb20327c49920c41d2b51c1ce2f4fe7deb3.tar.gz";
      sha256 = "1w6nqjps6ngdmid7b7bl6fig39abf8yp0x2kindpi0y2vksc21nd";
    };
  };
  lua-snip = buildVimPluginFrom2Nix {
    pname = "lua-snip"; # Manifest entry: "L3MON4D3/LuaSnip"
    version = "2023-04-23";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/e77fa9ad0b1f4fc6cddf54e51047e17e90c7d7ed.tar.gz";
      sha256 = "1xk7ls3nqm9p9kyzkgigk622wdwh9d5wv84sv08a8qlk5azh9k1n";
    };
  };
  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter"; # Manifest entry: "nvim-treesitter/nvim-treesitter"
    version = "2023-04-27";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter/archive/08e8b2c08bfdcd20e4561620ca0ccda0bb2e050a.tar.gz";
      sha256 = "1cqvvr9drvj01yrwfmsd1x4vy23g0wbwidzbsrd5dw5jc5n18qh6";
    };
  };
  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim"; # Manifest entry: "jose-elias-alvarez/null-ls.nvim"
    version = "2023-04-26";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/33b853a3933eed3137cd055aac4e539e69832ad0.tar.gz";
      sha256 = "1fgdf6h6vlm6c8ij1lpdvzfhffqjmv2s1399l6jrdfmym21ag1d8";
    };
  };
  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim"; # Manifest entry: "nvim-telescope/telescope.nvim"
    version = "2023-04-26";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope.nvim/archive/713d26b98583b160b50fb827adb751f768238ed3.tar.gz";
      sha256 = "0kjij696a2bwmqb6f8kinhaf7a38b3b1nx726d53g5nx1p97vdi1";
    };
  };
  copilot-lua = buildVimPluginFrom2Nix {
    pname = "copilot-lua"; # Manifest entry: "zbirenbaum/copilot.lua"
    version = "2023-04-19";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot.lua/archive/decc8d43bcd73a288fa689690c20faf0485da217.tar.gz";
      sha256 = "03p84dcsrn8w49a9advkd1ps8jkn3i5w4m8cy7yvqys1bl1i6g8i";
    };
  };
}
