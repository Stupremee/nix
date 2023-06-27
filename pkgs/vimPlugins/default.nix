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
  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons"; # Manifest entry: "nvim-tree/nvim-web-devicons"
    version = "2023-06-18";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-web-devicons/archive/14b3a5ba63b82b60cde98d0a40319d80f25e8301.tar.gz";
      sha256 = "0wychbncy17ckdhxa9byqfs3mszrb05cv3igxs7fmza6z2vqfmba";
    };
  };
  nvim-notify = buildVimPluginFrom2Nix {
    pname = "nvim-notify"; # Manifest entry: "rcarriga/nvim-notify"
    version = "2023-06-05";
    src = fetchurl {
      url = "https://github.com/rcarriga/nvim-notify/archive/ea9c8ce7a37f2238f934e087c255758659948e0f.tar.gz";
      sha256 = "1pa2isrsl31zmv0qag3n915cv734c1x78ibl4ws8b95zf5n954r8";
    };
  };
  comment-nvim = buildVimPluginFrom2Nix {
    pname = "comment-nvim"; # Manifest entry: "numToStr/Comment.nvim"
    version = "2023-06-12";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/176e85eeb63f1a5970d6b88f1725039d85ca0055.tar.gz";
      sha256 = "0v4w3iy6815z8zv6hnbjzdrbcaxmjf1lk7m4fh49vwqp4ylp52ll";
    };
  };
  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring"; # Manifest entry: "JoosepAlviste/nvim-ts-context-commentstring"
    version = "2023-06-22";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/7f625207f225eea97ef7a6abe7611e556c396d2f.tar.gz";
      sha256 = "08j2fg5rpx7is32xpfn7v9pqp3kw0g9mgf378rqnv52bnk13kdnk";
    };
  };
  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui-nvim"; # Manifest entry: "MunifTanjim/nui.nvim"
    version = "2023-06-18";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/d146966a423e60699b084eeb28489fe3b6427599.tar.gz";
      sha256 = "0a17a59rhsn9dzwfhnfwsyv9mn769idl4h82av1mx08grcrps10f";
    };
  };
  noice-nvim = buildVimPluginFrom2Nix {
    pname = "noice-nvim"; # Manifest entry: "folke/noice.nvim"
    version = "2023-06-22";
    src = fetchurl {
      url = "https://github.com/folke/noice.nvim/archive/7d01b45174d0d642302518275ab7cedf73e2690b.tar.gz";
      sha256 = "0xsjm65mn4mvmvdz35gkcc97gaqafj1ds21diw0dgvfljfga2dwd";
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
  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path"; # Manifest entry: "hrsh7th/cmp-path"
    version = "2022-10-03";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-path/archive/91ff86cd9c29299a64f968ebb45846c485725f23.tar.gz";
      sha256 = "052aclqk5fdcx2870h6y128x9lbwkqs7acc13xv7pdx0hgc6h7zp";
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
  indent-blankline-nvim = buildVimPluginFrom2Nix {
    pname = "indent-blankline-nvim"; # Manifest entry: "lukas-reineke/indent-blankline.nvim"
    version = "2023-05-30";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/indent-blankline.nvim/archive/7075d7861f7a6bbf0de0298c83f8a13195e6ec01.tar.gz";
      sha256 = "1a8jwppqac146a9vbiih80whni0xzsmjkxqk5gfzx7xbbgz76zad";
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
    version = "2023-06-16";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-ts-autotag/archive/6be1192965df35f94b8ea6d323354f7dc7a557e4.tar.gz";
      sha256 = "18f60mn48a2h1kg0033l2799rv6f0pnkvigs24g4nl3i99z6p2h5";
    };
  };
  todo-comments-nvim = buildVimPluginFrom2Nix {
    pname = "todo-comments-nvim"; # Manifest entry: "folke/todo-comments.nvim"
    version = "2023-05-22";
    src = fetchurl {
      url = "https://github.com/folke/todo-comments.nvim/archive/09b0b17d824d2d56f02ff15967e8a2499a89c731.tar.gz";
      sha256 = "1yrcvkdkw5fdym04c73z1241yghq5618kai85d6qbzq7sn404wch";
    };
  };
  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp"; # Manifest entry: "hrsh7th/cmp-nvim-lsp"
    version = "2023-06-23";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lsp/archive/44b16d11215dce86f253ce0c30949813c0a90765.tar.gz";
      sha256 = "1kqmspcdz0vb0wgj0v1hg9f9halfwx2mfwva302bz5rzhf5jp2vs";
    };
  };
  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline-nvim"; # Manifest entry: "akinsho/bufferline.nvim"
    version = "2023-06-17";
    src = fetchurl {
      url = "https://github.com/akinsho/bufferline.nvim/archive/60734264a8655a7db3595159fb50076dc24c2f2c.tar.gz";
      sha256 = "0dkp1qc3wfvisf118jzhgp0a65wpzpmh236x9dfjw97n4bw2yhm1";
    };
  };
  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim"; # Manifest entry: "nvim-lua/plenary.nvim"
    version = "2023-06-10";
    src = fetchurl {
      url = "https://github.com/nvim-lua/plenary.nvim/archive/36aaceb6e93addd20b1b18f94d86aecc552f30c4.tar.gz";
      sha256 = "140cafm6bbyp5phs1x5lx1dp2mqrcsrrv84mc3dd2fdv7drvld5h";
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
  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim"; # Manifest entry: "stevearc/dressing.nvim"
    version = "2023-06-16";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/5fb5cce0cbfcedeadbcee43e5674e8c9a9f28d4a.tar.gz";
      sha256 = "1wkknjdbb5hg390b8wxzxynnxdj2v32ww4q79sf2isr548kkj2g2";
    };
  };
  copilot-cmp = buildVimPluginFrom2Nix {
    pname = "copilot-cmp"; # Manifest entry: "zbirenbaum/copilot-cmp"
    version = "2023-05-11";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot-cmp/archive/c2cdb3c0f5078b0619055af192295830a7987790.tar.gz";
      sha256 = "0r7plhl9s2v9j4c790ymvgi1iyxr3xa15nq7m4z63kpdnn19z8jx";
    };
  };
  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig"; # Manifest entry: "neovim/nvim-lspconfig"
    version = "2023-06-22";
    src = fetchurl {
      url = "https://github.com/neovim/nvim-lspconfig/archive/11a1be0e5f180b57079db56de10a20b4323111ae.tar.gz";
      sha256 = "0dpaj48dh8qb6yclirhi39z91wcz0symswp7wpknsqs68qyvzixm";
    };
  };
  lsp-zero-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-zero-nvim"; # Manifest entry: "VonHeikemen/lsp-zero.nvim"
    version = "2023-06-22";
    src = fetchurl {
      url = "https://github.com/VonHeikemen/lsp-zero.nvim/archive/52582fc91efb40ee347c20570ff7d32849ef4a89.tar.gz";
      sha256 = "0y70n8sx3j6r8454dswq533lps3l7lrgpps36gl7nh73hl0lvqx6";
    };
  };
  impatient-nvim = buildVimPluginFrom2Nix {
    pname = "impatient-nvim"; # Manifest entry: "lewis6991/impatient.nvim"
    version = "2023-05-05";
    src = fetchurl {
      url = "https://github.com/lewis6991/impatient.nvim/archive/47302af74be7b79f002773011f0d8e85679a7618.tar.gz";
      sha256 = "1qqlnrrm89my38dr248ks7rsswm2yc9mr1vja87lzz8i4qjkvqym";
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
  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim"; # Manifest entry: "jose-elias-alvarez/null-ls.nvim"
    version = "2023-06-15";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/bbaf5a96913aa92281f154b08732be2f57021c45.tar.gz";
      sha256 = "1n6v963bpcbhnbdv7hlm7zslzwck8jyh5shf226hakys8vlv1ad6";
    };
  };
  gitsigns-nvim = buildVimPluginFrom2Nix {
    pname = "gitsigns-nvim"; # Manifest entry: "lewis6991/gitsigns.nvim"
    version = "2023-06-20";
    src = fetchurl {
      url = "https://github.com/lewis6991/gitsigns.nvim/archive/a36bc3360d584d39b4fb076d855c4180842d4444.tar.gz";
      sha256 = "0pywm4fyn5fkkgyzkn093x1slwwfgqv6553svjgj35vqcccmw462";
    };
  };
  lualine-nvim = buildVimPluginFrom2Nix {
    pname = "lualine-nvim"; # Manifest entry: "nvim-lualine/lualine.nvim"
    version = "2023-05-04";
    src = fetchurl {
      url = "https://github.com/nvim-lualine/lualine.nvim/archive/05d78e9fd0cdfb4545974a5aa14b1be95a86e9c9.tar.gz";
      sha256 = "0ispw9my9a0y6lpidy2r54747z6gnnn4bj2mnaii6q4kabzqs3gj";
    };
  };
  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim"; # Manifest entry: "nvim-telescope/telescope.nvim"
    version = "2023-06-21";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope.nvim/archive/ffe35cb433192fcb5080b557c1aef14d37092035.tar.gz";
      sha256 = "17p2gd8bq3qms1qy3g63brdm84rdindm7azfgkfxw8zcnxhcrj9z";
    };
  };
  nvim-autopairs = buildVimPluginFrom2Nix {
    pname = "nvim-autopairs"; # Manifest entry: "windwp/nvim-autopairs"
    version = "2023-06-18";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-autopairs/archive/e8f7dd7a72de3e7b6626c050a802000e69d53ff0.tar.gz";
      sha256 = "09cqzm3n1q3k9rsai1p517l2hlapn0qjnypfcj8x703ghgcscf3m";
    };
  };
  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter"; # Manifest entry: "nvim-treesitter/nvim-treesitter"
    version = "2023-06-23";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter/archive/fdaf9f3f98014a058401ea03603164492f243d31.tar.gz";
      sha256 = "1rpdspiqgihq1bjfgw1vjlmnbqxvkzsf342xvi3q27ai0id0m0nb";
    };
  };
  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp"; # Manifest entry: "hrsh7th/nvim-cmp"
    version = "2023-06-23";
    src = fetchurl {
      url = "https://github.com/hrsh7th/nvim-cmp/archive/e1f1b40790a8cb7e64091fb12cc5ffe350363aa0.tar.gz";
      sha256 = "0nbw8iq6j6zvn71jlwa526ilzmxh8hrxndm7dxdm6qjlhgcbgcni";
    };
  };
  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree-lua"; # Manifest entry: "nvim-tree/nvim-tree.lua"
    version = "2023-06-19";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-tree.lua/archive/c3c6544ee00333b0f1d6a13735d0dd302dba4f70.tar.gz";
      sha256 = "1ssls9z7mgr3z6a9dkks1jj1nc1fcz5cd93506xbkraq73vn99gr";
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
  catppuccin-nvim = buildVimPluginFrom2Nix {
    pname = "catppuccin-nvim"; # Manifest entry: "catppuccin/nvim"
    version = "2023-06-22";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/506a4aa13443e0104ea49b99947cc09488d0791d.tar.gz";
      sha256 = "1jis225629b2p7qinprlnm98wlcjyiafrbsl572pqnpqx1an6spz";
    };
  };
  lua-snip = buildVimPluginFrom2Nix {
    pname = "lua-snip"; # Manifest entry: "L3MON4D3/LuaSnip"
    version = "2023-06-19";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/3d2ad0c0fa25e4e272ade48a62a185ebd0fe26c1.tar.gz";
      sha256 = "0mdcvb30c9yndjbxmrsmbw4jmicdzwa9xr9g1b1bgxyj89ac2rzx";
    };
  };
  copilot-lua = buildVimPluginFrom2Nix {
    pname = "copilot-lua"; # Manifest entry: "zbirenbaum/copilot.lua"
    version = "2023-06-21";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot.lua/archive/9cb5396205faf609bc9df0e841e133ccb1b70540.tar.gz";
      sha256 = "0pqgqlz2v44x12vky65qan32j66n30g7jyg20r3xifglzwz3jzql";
    };
  };
}
