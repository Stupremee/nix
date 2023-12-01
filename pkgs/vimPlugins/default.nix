{
  buildVimPlugin,
  fetchurl,
}: {
  vim-bbye = buildVimPlugin {
    pname = "vim-bbye"; # Manifest entry: "moll/vim-bbye"
    version = "2018-03-03";
    src = fetchurl {
      url = "https://github.com/moll/vim-bbye/archive/25ef93ac5a87526111f43e5110675032dbcacf56.tar.gz";
      sha256 = "0f7nixmwkhhiv4xmq063gdl0x0xykn1m8pz564yj1ggbh00pka1c";
    };
  };
  lua-snip = buildVimPlugin {
    pname = "lua-snip"; # Manifest entry: "L3MON4D3/LuaSnip"
    version = "2023-11-28";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/1def35377854535bb3b0f4cc7a33c083cdb12571.tar.gz";
      sha256 = "0v4il6ha80f8vchqfhdfq84shwi5s2wi2lg2dyzmfx7dkxmdkkzv";
    };
  };
  cmp-nvim-lua = buildVimPlugin {
    pname = "cmp-nvim-lua"; # Manifest entry: "hrsh7th/cmp-nvim-lua"
    version = "2023-04-14";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lua/archive/f12408bdb54c39c23e67cab726264c10db33ada8.tar.gz";
      sha256 = "0yl83fyy0h0hnc4ph4503pdv2mv3y97ddzb8hy5gqsv8lih8zxpf";
    };
  };
  cmp-path = buildVimPlugin {
    pname = "cmp-path"; # Manifest entry: "hrsh7th/cmp-path"
    version = "2022-10-03";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-path/archive/91ff86cd9c29299a64f968ebb45846c485725f23.tar.gz";
      sha256 = "052aclqk5fdcx2870h6y128x9lbwkqs7acc13xv7pdx0hgc6h7zp";
    };
  };
  comment-nvim = buildVimPlugin {
    pname = "comment-nvim"; # Manifest entry: "numToStr/Comment.nvim"
    version = "2023-08-07";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/0236521ea582747b58869cb72f70ccfa967d2e89.tar.gz";
      sha256 = "1sda94xkxpnk7mljgy940rjhwf3jg4wb08namkbvr95728zns1l1";
    };
  };
  gitsigns-nvim = buildVimPlugin {
    pname = "gitsigns-nvim"; # Manifest entry: "lewis6991/gitsigns.nvim"
    version = "2023-11-29";
    src = fetchurl {
      url = "https://github.com/lewis6991/gitsigns.nvim/archive/6ef8c54fb526bf3a0bc4efb0b2fe8e6d9a7daed2.tar.gz";
      sha256 = "1c2a1bc37lvygxda8xw6l57msazqrb7hxr3cxraak4cdzbfc5h46";
    };
  };
  rust-tools-nvim = buildVimPlugin {
    pname = "rust-tools-nvim"; # Manifest entry: "simrat39/rust-tools.nvim"
    version = "2023-07-10";
    src = fetchurl {
      url = "https://github.com/simrat39/rust-tools.nvim/archive/0cc8adab23117783a0292a0c8a2fbed1005dc645.tar.gz";
      sha256 = "1kbgg2rwp9m0nk50lhh1d5nlb28ws455h3sxr8zbzmc1k8qrqwc6";
    };
  };
  nvim-ts-context-commentstring = buildVimPlugin {
    pname = "nvim-ts-context-commentstring"; # Manifest entry: "JoosepAlviste/nvim-ts-context-commentstring"
    version = "2023-11-30";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/1277b4a1f451b0f18c0790e1a7f12e1e5fdebfee.tar.gz";
      sha256 = "0n3gh9gcfzms16vcfmax0ljcm7x5dr1sdgy03fwf5gzl45hjvda2";
    };
  };
  nvim-web-devicons = buildVimPlugin {
    pname = "nvim-web-devicons"; # Manifest entry: "nvim-tree/nvim-web-devicons"
    version = "2023-11-27";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-web-devicons/archive/5efb8bd06841f91f97c90e16de85e96d57e9c862.tar.gz";
      sha256 = "0dcn1h9rbggjnb505bld6jdd2fiz8xgqlwcm8bpv8p2mjixn02ng";
    };
  };
  vim-illuminate = buildVimPlugin {
    pname = "vim-illuminate"; # Manifest entry: "RRethy/vim-illuminate"
    version = "2023-10-06";
    src = fetchurl {
      url = "https://github.com/RRethy/vim-illuminate/archive/3bd2ab64b5d63b29e05691e624927e5ebbf0fb86.tar.gz";
      sha256 = "0x7g4rw2pj9wlmaq6irdfklawqj7vrsggwjjx8wfj3ijbvi4jvi2";
    };
  };
  nvim-cmp = buildVimPlugin {
    pname = "nvim-cmp"; # Manifest entry: "hrsh7th/nvim-cmp"
    version = "2023-11-06";
    src = fetchurl {
      url = "https://github.com/hrsh7th/nvim-cmp/archive/0b751f6beef40fd47375eaf53d3057e0bfa317e4.tar.gz";
      sha256 = "16wzzdyhhs95kxfpn6z4abjglhf3sp6wpg8n07lf6jhgvzlkh7w0";
    };
  };
  nui-nvim = buildVimPlugin {
    pname = "nui-nvim"; # Manifest entry: "MunifTanjim/nui.nvim"
    version = "2023-11-26";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/257dccc43b4badc735978f0791d216f7d665b75a.tar.gz";
      sha256 = "1xnahijqr7p7b769jzkyb0knjf4ylnnrz7v8h05bnybjbksjfl7w";
    };
  };
  base64-nvim = buildVimPlugin {
    pname = "base64-nvim"; # Manifest entry: "moevis/base64.nvim"
    version = "2022-04-28";
    src = fetchurl {
      url = "https://github.com/moevis/base64.nvim/archive/67fb5f12db252b3e2bd190250d3edbed7aa8d3aa.tar.gz";
      sha256 = "0sim06pq12gkdkzblff418nrx7r73qx4njq5cdw7vr7xvph3gl86";
    };
  };
  nvim-lspconfig = buildVimPlugin {
    pname = "nvim-lspconfig"; # Manifest entry: "neovim/nvim-lspconfig"
    version = "2023-12-01";
    src = fetchurl {
      url = "https://github.com/neovim/nvim-lspconfig/archive/694aaec65733e2d54d393abf80e526f86726c988.tar.gz";
      sha256 = "09pnywlw73sn3y815mi1yl2fdvfnzcwigkzx7jqz9cfpgkcd0l5g";
    };
  };
  cmp-nvim-lsp = buildVimPlugin {
    pname = "cmp-nvim-lsp"; # Manifest entry: "hrsh7th/cmp-nvim-lsp"
    version = "2023-06-23";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lsp/archive/44b16d11215dce86f253ce0c30949813c0a90765.tar.gz";
      sha256 = "1kqmspcdz0vb0wgj0v1hg9f9halfwx2mfwva302bz5rzhf5jp2vs";
    };
  };
  impatient-nvim = buildVimPlugin {
    pname = "impatient-nvim"; # Manifest entry: "lewis6991/impatient.nvim"
    version = "2023-05-05";
    src = fetchurl {
      url = "https://github.com/lewis6991/impatient.nvim/archive/47302af74be7b79f002773011f0d8e85679a7618.tar.gz";
      sha256 = "1qqlnrrm89my38dr248ks7rsswm2yc9mr1vja87lzz8i4qjkvqym";
    };
  };
  nvim-ts-autotag = buildVimPlugin {
    pname = "nvim-ts-autotag"; # Manifest entry: "windwp/nvim-ts-autotag"
    version = "2023-06-16";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-ts-autotag/archive/6be1192965df35f94b8ea6d323354f7dc7a557e4.tar.gz";
      sha256 = "18f60mn48a2h1kg0033l2799rv6f0pnkvigs24g4nl3i99z6p2h5";
    };
  };
  bufferline-nvim = buildVimPlugin {
    pname = "bufferline-nvim"; # Manifest entry: "akinsho/bufferline.nvim"
    version = "2023-11-29";
    src = fetchurl {
      url = "https://github.com/akinsho/bufferline.nvim/archive/1a3397556d194bb1f2cc530b07124ccc512c5501.tar.gz";
      sha256 = "1ckzfkplv9mjajhxbp2pl0jza5pmdhbywb8f6li1fakgf0jgv7vv";
    };
  };
  move-nvim = buildVimPlugin {
    pname = "move-nvim"; # Manifest entry: "fedepujol/move.nvim"
    version = "2023-04-21";
    src = fetchurl {
      url = "https://github.com/fedepujol/move.nvim/archive/d663b74b4e38f257aae757541c9076b8047844d6.tar.gz";
      sha256 = "1g2yhs5b8sw5xzyi6nmb7bvxyg05zrdn2iaicwjjbc3lmyg4a176";
    };
  };
  dressing-nvim = buildVimPlugin {
    pname = "dressing-nvim"; # Manifest entry: "stevearc/dressing.nvim"
    version = "2023-12-01";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/8b7ae53d7f04f33be3439a441db8071c96092d19.tar.gz";
      sha256 = "1brpnpw55mqc7l9xk9rkjl1x0vpas1w05znjv1k0b4wnfrjhi9x0";
    };
  };
  catppuccin-nvim = buildVimPlugin {
    pname = "catppuccin-nvim"; # Manifest entry: "catppuccin/nvim"
    version = "2023-11-29";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/919d1f786338ebeced798afbf28cd085cd54542a.tar.gz";
      sha256 = "049h1pkgmph0smlr8hvghyjbisndcb6swf5zydfqq8ddmbzvnbz8";
    };
  };
  todo-comments-nvim = buildVimPlugin {
    pname = "todo-comments-nvim"; # Manifest entry: "folke/todo-comments.nvim"
    version = "2023-10-25";
    src = fetchurl {
      url = "https://github.com/folke/todo-comments.nvim/archive/4a6737a8d70fe1ac55c64dfa47fcb189ca431872.tar.gz";
      sha256 = "1xk16sp6v6b0xpgfvvh8d6gy88zi0d4h5jbjhlsfbps5wahql2xd";
    };
  };
  indent-blankline-nvim = buildVimPlugin {
    pname = "indent-blankline-nvim"; # Manifest entry: "lukas-reineke/indent-blankline.nvim"
    version = "2023-10-30";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/indent-blankline.nvim/archive/29be0919b91fb59eca9e90690d76014233392bef.tar.gz";
      sha256 = "0wmv1sndw1kmxll7r57ph2lf6ykv57hgxli4grvb3dr3fd46frxk";
    };
  };
  nvim-tree-lua = buildVimPlugin {
    pname = "nvim-tree-lua"; # Manifest entry: "nvim-tree/nvim-tree.lua"
    version = "2023-11-28";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-tree.lua/archive/05f55c1fd6470b31627655c528245794e3cd4b2c.tar.gz";
      sha256 = "12scm47gwdf44ra3gr9p14bzdf48irsqdkd49zndsk8xcw4hc323";
    };
  };
  cmp-luasnip = buildVimPlugin {
    pname = "cmp-luasnip"; # Manifest entry: "saadparwaiz1/cmp_luasnip"
    version = "2023-10-09";
    src = fetchurl {
      url = "https://github.com/saadparwaiz1/cmp_luasnip/archive/05a9ab28b53f71d1aece421ef32fee2cb857a843.tar.gz";
      sha256 = "1jm4psksw761db4klz0qn4sfyp57gq437ys3rlhp90v30rcfl9hq";
    };
  };
  neoconf-nvim = buildVimPlugin {
    pname = "neoconf-nvim"; # Manifest entry: "folke/neoconf.nvim"
    version = "2023-11-04";
    src = fetchurl {
      url = "https://github.com/folke/neoconf.nvim/archive/64437787dba70fce50dad7bfbb97d184c5bc340f.tar.gz";
      sha256 = "07wmg9b5skrqzjlngqqb0z45lxydy8rxl3bq95d62n66rxygfybh";
    };
  };
  nvim-autopairs = buildVimPlugin {
    pname = "nvim-autopairs"; # Manifest entry: "windwp/nvim-autopairs"
    version = "2023-10-21";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-autopairs/archive/0f04d78619cce9a5af4f355968040f7d675854a1.tar.gz";
      sha256 = "165w1ndc8v7y0m2sjv2ybszjg5nacni4cqickwh7bpvaqj631702";
    };
  };
  copilot-cmp = buildVimPlugin {
    pname = "copilot-cmp"; # Manifest entry: "zbirenbaum/copilot-cmp"
    version = "2023-09-09";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot-cmp/archive/72fbaa03695779f8349be3ac54fa8bd77eed3ee3.tar.gz";
      sha256 = "07vahyzf8xvs6f6sfxw60ay0i5bkjfbdxm734xy7h1s9p1yq0g41";
    };
  };
  noice-nvim = buildVimPlugin {
    pname = "noice-nvim"; # Manifest entry: "folke/noice.nvim"
    version = "2023-10-25";
    src = fetchurl {
      url = "https://github.com/folke/noice.nvim/archive/92433164e2f7118d4122c7674c3834d9511722ba.tar.gz";
      sha256 = "0977vqymc25390p508j364ash077cl5s6p763vp799f3q4jwva1s";
    };
  };
  cmp-buffer = buildVimPlugin {
    pname = "cmp-buffer"; # Manifest entry: "hrsh7th/cmp-buffer"
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-buffer/archive/3022dbc9166796b644a841a02de8dd1cc1d311fa.tar.gz";
      sha256 = "0zs9j63w3h00ba1c70q6gq1r6z9s8qiisv91wi4nkkp2akpnmf2v";
    };
  };
  lualine-nvim = buildVimPlugin {
    pname = "lualine-nvim"; # Manifest entry: "nvim-lualine/lualine.nvim"
    version = "2023-10-20";
    src = fetchurl {
      url = "https://github.com/nvim-lualine/lualine.nvim/archive/2248ef254d0a1488a72041cfb45ca9caada6d994.tar.gz";
      sha256 = "08krsbqyarb9cl7b0lgrm1kyaxmfab5884vykfh28kwf4yfp16hr";
    };
  };
  telescope-nvim = buildVimPlugin {
    pname = "telescope-nvim"; # Manifest entry: "nvim-telescope/telescope.nvim"
    version = "2023-11-27";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope.nvim/archive/84c5a71d825b6687a55aed6f41e98b92fd8e5454.tar.gz";
      sha256 = "1sih4i0d651imij4hqynfsqjw4zirg4lv2v8zk9v1mm147dpqf51";
    };
  };
  nvim-treesitter = buildVimPlugin {
    pname = "nvim-treesitter"; # Manifest entry: "nvim-treesitter/nvim-treesitter"
    version = "2023-12-01";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter/archive/80a16deb5146a3eb4648effccda1ab9f45e43e76.tar.gz";
      sha256 = "0mylli0kd90llgg0h49dkl95d7mmz2rg0hfj64cg47ixgr8dp0p6";
    };
  };
  plenary-nvim = buildVimPlugin {
    pname = "plenary-nvim"; # Manifest entry: "nvim-lua/plenary.nvim"
    version = "2023-11-30";
    src = fetchurl {
      url = "https://github.com/nvim-lua/plenary.nvim/archive/55d9fe89e33efd26f532ef20223e5f9430c8b0c0.tar.gz";
      sha256 = "02gdbdkkpl179zv09xw0a4lpvrfvcdwfxzg2nss6ii91vhrq6s6v";
    };
  };
  none-ls-nvim = buildVimPlugin {
    pname = "none-ls-nvim"; # Manifest entry: "nvimtools/none-ls.nvim"
    version = "2023-12-01";
    src = fetchurl {
      url = "https://github.com/nvimtools/none-ls.nvim/archive/7bf88cd3b37a411fdacfdca1745408a77a420493.tar.gz";
      sha256 = "0cnypccbw13pp2rlsc3sbagq409rg7mi8bb3b1dpqcizlh8zahrm";
    };
  };
  lsp-zero-nvim = buildVimPlugin {
    pname = "lsp-zero-nvim"; # Manifest entry: "VonHeikemen/lsp-zero.nvim"
    version = "2023-11-28";
    src = fetchurl {
      url = "https://github.com/VonHeikemen/lsp-zero.nvim/archive/98fe58a00c69f709b6b65e53aed56d86da92a4b7.tar.gz";
      sha256 = "16p4ldgggqkdmvl36nvj2z1i0034ivgs2kgypxs4f7dhl7lkklmp";
    };
  };
  copilot-lua = buildVimPlugin {
    pname = "copilot-lua"; # Manifest entry: "zbirenbaum/copilot.lua"
    version = "2023-11-28";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot.lua/archive/3665ed0f3ef3ad68673df7195789d134d0d1fdb0.tar.gz";
      sha256 = "1rsxxd93hdzg3sv2g7zxrp0ldxkkf40cp4zmrx3jc266hxkbzr0h";
    };
  };
  nvim-notify = buildVimPlugin {
    pname = "nvim-notify"; # Manifest entry: "rcarriga/nvim-notify"
    version = "2023-09-28";
    src = fetchurl {
      url = "https://github.com/rcarriga/nvim-notify/archive/e4a2022f4fec2d5ebc79afa612f96d8b11c627b3.tar.gz";
      sha256 = "0h1pfy9hh0550p8gjvmqd0sgdm1fmwhw50v1zrmlcsp9k0pc7qri";
    };
  };
}
