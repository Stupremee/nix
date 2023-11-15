{
  buildVimPluginFrom2Nix,
  fetchurl,
}: {
  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp"; # Manifest entry: "hrsh7th/cmp-nvim-lsp"
    version = "2023-06-23";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lsp/archive/44b16d11215dce86f253ce0c30949813c0a90765.tar.gz";
      sha256 = "1kqmspcdz0vb0wgj0v1hg9f9halfwx2mfwva302bz5rzhf5jp2vs";
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
  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer"; # Manifest entry: "hrsh7th/cmp-buffer"
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-buffer/archive/3022dbc9166796b644a841a02de8dd1cc1d311fa.tar.gz";
      sha256 = "0zs9j63w3h00ba1c70q6gq1r6z9s8qiisv91wi4nkkp2akpnmf2v";
    };
  };
  todo-comments-nvim = buildVimPluginFrom2Nix {
    pname = "todo-comments-nvim"; # Manifest entry: "folke/todo-comments.nvim"
    version = "2023-10-25";
    src = fetchurl {
      url = "https://github.com/folke/todo-comments.nvim/archive/4a6737a8d70fe1ac55c64dfa47fcb189ca431872.tar.gz";
      sha256 = "1xk16sp6v6b0xpgfvvh8d6gy88zi0d4h5jbjhlsfbps5wahql2xd";
    };
  };
  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui-nvim"; # Manifest entry: "MunifTanjim/nui.nvim"
    version = "2023-10-09";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/c0c8e347ceac53030f5c1ece1c5a5b6a17a25b32.tar.gz";
      sha256 = "0w708z6wprigwrr0gxp33b190glcg23k2pwpa2hfirfp2agnfnh9";
    };
  };
  nvim-autopairs = buildVimPluginFrom2Nix {
    pname = "nvim-autopairs"; # Manifest entry: "windwp/nvim-autopairs"
    version = "2023-10-21";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-autopairs/archive/0f04d78619cce9a5af4f355968040f7d675854a1.tar.gz";
      sha256 = "165w1ndc8v7y0m2sjv2ybszjg5nacni4cqickwh7bpvaqj631702";
    };
  };
  rust-tools-nvim = buildVimPluginFrom2Nix {
    pname = "rust-tools-nvim"; # Manifest entry: "simrat39/rust-tools.nvim"
    version = "2023-07-10";
    src = fetchurl {
      url = "https://github.com/simrat39/rust-tools.nvim/archive/0cc8adab23117783a0292a0c8a2fbed1005dc645.tar.gz";
      sha256 = "1kbgg2rwp9m0nk50lhh1d5nlb28ws455h3sxr8zbzmc1k8qrqwc6";
    };
  };
  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim"; # Manifest entry: "nvim-lua/plenary.nvim"
    version = "2023-10-11";
    src = fetchurl {
      url = "https://github.com/nvim-lua/plenary.nvim/archive/50012918b2fc8357b87cff2a7f7f0446e47da174.tar.gz";
      sha256 = "0bvxmbnqm0yll0h5li3dh44l4zq07rfa7d4s7a36xc15lz2l4vfr";
    };
  };
  lualine-nvim = buildVimPluginFrom2Nix {
    pname = "lualine-nvim"; # Manifest entry: "nvim-lualine/lualine.nvim"
    version = "2023-10-20";
    src = fetchurl {
      url = "https://github.com/nvim-lualine/lualine.nvim/archive/2248ef254d0a1488a72041cfb45ca9caada6d994.tar.gz";
      sha256 = "08krsbqyarb9cl7b0lgrm1kyaxmfab5884vykfh28kwf4yfp16hr";
    };
  };
  vim-illuminate = buildVimPluginFrom2Nix {
    pname = "vim-illuminate"; # Manifest entry: "RRethy/vim-illuminate"
    version = "2023-10-06";
    src = fetchurl {
      url = "https://github.com/RRethy/vim-illuminate/archive/3bd2ab64b5d63b29e05691e624927e5ebbf0fb86.tar.gz";
      sha256 = "0x7g4rw2pj9wlmaq6irdfklawqj7vrsggwjjx8wfj3ijbvi4jvi2";
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
  nvim-notify = buildVimPluginFrom2Nix {
    pname = "nvim-notify"; # Manifest entry: "rcarriga/nvim-notify"
    version = "2023-09-28";
    src = fetchurl {
      url = "https://github.com/rcarriga/nvim-notify/archive/e4a2022f4fec2d5ebc79afa612f96d8b11c627b3.tar.gz";
      sha256 = "0h1pfy9hh0550p8gjvmqd0sgdm1fmwhw50v1zrmlcsp9k0pc7qri";
    };
  };
  cmp-luasnip = buildVimPluginFrom2Nix {
    pname = "cmp-luasnip"; # Manifest entry: "saadparwaiz1/cmp_luasnip"
    version = "2023-10-09";
    src = fetchurl {
      url = "https://github.com/saadparwaiz1/cmp_luasnip/archive/05a9ab28b53f71d1aece421ef32fee2cb857a843.tar.gz";
      sha256 = "1jm4psksw761db4klz0qn4sfyp57gq437ys3rlhp90v30rcfl9hq";
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
  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree-lua"; # Manifest entry: "nvim-tree/nvim-tree.lua"
    version = "2023-11-12";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-tree.lua/archive/80cfeadf179d5cba76f0f502c71dbcff1b515cd8.tar.gz";
      sha256 = "01cslxz8n0j54iir246dxnssvczzjnah4rrsb6hi7rz7dx5dr0vr";
    };
  };
  copilot-cmp = buildVimPluginFrom2Nix {
    pname = "copilot-cmp"; # Manifest entry: "zbirenbaum/copilot-cmp"
    version = "2023-09-09";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot-cmp/archive/72fbaa03695779f8349be3ac54fa8bd77eed3ee3.tar.gz";
      sha256 = "07vahyzf8xvs6f6sfxw60ay0i5bkjfbdxm734xy7h1s9p1yq0g41";
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
  none-ls-nvim = buildVimPluginFrom2Nix {
    pname = "none-ls-nvim"; # Manifest entry: "nvimtools/none-ls.nvim"
    version = "2023-11-13";
    src = fetchurl {
      url = "https://github.com/nvimtools/none-ls.nvim/archive/728bc36f2c697f0dce201dc63687a6b676de6420.tar.gz";
      sha256 = "157x0psilmmnd1zbnihrd29idsqy8nhnr3jb3vhr11j9q6j1j4ks";
    };
  };
  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim"; # Manifest entry: "stevearc/dressing.nvim"
    version = "2023-11-07";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/fe3071330a0720ce3695ac915820c8134b22d1b0.tar.gz";
      sha256 = "07cw9hbbqn2dp4rk06mnrgaqxjrrywp2vhlnax7z25zf06xfi3q4";
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
  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag"; # Manifest entry: "windwp/nvim-ts-autotag"
    version = "2023-06-16";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-ts-autotag/archive/6be1192965df35f94b8ea6d323354f7dc7a557e4.tar.gz";
      sha256 = "18f60mn48a2h1kg0033l2799rv6f0pnkvigs24g4nl3i99z6p2h5";
    };
  };
  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp"; # Manifest entry: "hrsh7th/nvim-cmp"
    version = "2023-11-06";
    src = fetchurl {
      url = "https://github.com/hrsh7th/nvim-cmp/archive/0b751f6beef40fd47375eaf53d3057e0bfa317e4.tar.gz";
      sha256 = "16wzzdyhhs95kxfpn6z4abjglhf3sp6wpg8n07lf6jhgvzlkh7w0";
    };
  };
  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim"; # Manifest entry: "nvim-telescope/telescope.nvim"
    version = "2023-11-15";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope.nvim/archive/721cdcae134eb5c564cb6c9df6c317c3854528ad.tar.gz";
      sha256 = "019clsqq3dv4z6d22qkfd83jcr5ivd2f24waqnvcjn5igys7l3q2";
    };
  };
  comment-nvim = buildVimPluginFrom2Nix {
    pname = "comment-nvim"; # Manifest entry: "numToStr/Comment.nvim"
    version = "2023-08-07";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/0236521ea582747b58869cb72f70ccfa967d2e89.tar.gz";
      sha256 = "1sda94xkxpnk7mljgy940rjhwf3jg4wb08namkbvr95728zns1l1";
    };
  };
  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons"; # Manifest entry: "nvim-tree/nvim-web-devicons"
    version = "2023-11-13";
    src = fetchurl {
      url = "https://github.com/nvim-tree/nvim-web-devicons/archive/11eb26fc166742db8d1e8a6f5a7de9df37b09aae.tar.gz";
      sha256 = "0yn551j12hxwv0jvc6fnch0045c124p4ds0aiidh9x60ci8m01q3";
    };
  };
  lsp-zero-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-zero-nvim"; # Manifest entry: "VonHeikemen/lsp-zero.nvim"
    version = "2023-11-13";
    src = fetchurl {
      url = "https://github.com/VonHeikemen/lsp-zero.nvim/archive/8a9ee4e11a3e23101d1d1d11aaac3159ad925cc9.tar.gz";
      sha256 = "0by2qsdkigxk7sfxci4zkzd9ci7aq0ad0kxxwvi3mddlvsmcq43g";
    };
  };
  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring"; # Manifest entry: "JoosepAlviste/nvim-ts-context-commentstring"
    version = "2023-11-12";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/6c30f3c8915d7b31c3decdfe6c7672432da1809d.tar.gz";
      sha256 = "0kb4dfss64wzjwczw46frnyb7m8bdkwsnfaj7w4b1qf98pgkss18";
    };
  };
  gitsigns-nvim = buildVimPluginFrom2Nix {
    pname = "gitsigns-nvim"; # Manifest entry: "lewis6991/gitsigns.nvim"
    version = "2023-10-26";
    src = fetchurl {
      url = "https://github.com/lewis6991/gitsigns.nvim/archive/af0f583cd35286dd6f0e3ed52622728703237e50.tar.gz";
      sha256 = "1n7maayyx155nj5n5yjixkc0kqmnm5x6lwqrygfkhv7lfhzzn4w6";
    };
  };
  noice-nvim = buildVimPluginFrom2Nix {
    pname = "noice-nvim"; # Manifest entry: "folke/noice.nvim"
    version = "2023-10-25";
    src = fetchurl {
      url = "https://github.com/folke/noice.nvim/archive/92433164e2f7118d4122c7674c3834d9511722ba.tar.gz";
      sha256 = "0977vqymc25390p508j364ash077cl5s6p763vp799f3q4jwva1s";
    };
  };
  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig"; # Manifest entry: "neovim/nvim-lspconfig"
    version = "2023-11-15";
    src = fetchurl {
      url = "https://github.com/neovim/nvim-lspconfig/archive/d5d7412ff267b92a11a94e6559d5507c43670a52.tar.gz";
      sha256 = "1jpjx8sjnq6f3xnxxb404d5fiirk09km46xmwgm7zshi7bxjbd3g";
    };
  };
  catppuccin-nvim = buildVimPluginFrom2Nix {
    pname = "catppuccin-nvim"; # Manifest entry: "catppuccin/nvim"
    version = "2023-11-14";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/5e4be43e1a6acb044d5c55cd10f22461c40656ed.tar.gz";
      sha256 = "1fid6rscrsjxgx8v2d4qw0444gp392rk1bfqjqd26nhsa01raxmd";
    };
  };
  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline-nvim"; # Manifest entry: "akinsho/bufferline.nvim"
    version = "2023-11-01";
    src = fetchurl {
      url = "https://github.com/akinsho/bufferline.nvim/archive/9e8d2f695dd50ab6821a6a53a840c32d2067a78a.tar.gz";
      sha256 = "1s2hf4jrdl90qqyr6ns2gqwg2rjr1zwpvl49mq718if39c1z16vl";
    };
  };
  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter"; # Manifest entry: "nvim-treesitter/nvim-treesitter"
    version = "2023-11-15";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter/archive/8b9f99660294dcd11d42572c84ee33a1e284f70d.tar.gz";
      sha256 = "0aqhkf796sap1rrrjwjcabf1gs7r9n87gkawvd6c3lzvhmkmql29";
    };
  };
  lua-snip = buildVimPluginFrom2Nix {
    pname = "lua-snip"; # Manifest entry: "L3MON4D3/LuaSnip"
    version = "2023-11-13";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/1f4ad8bb72bdeb60975e98652636b991a9b7475d.tar.gz";
      sha256 = "0nxfd3y37bfmq39q1smny9xzajr9b0igm725r0zfar8s7vfh9kcz";
    };
  };
  indent-blankline-nvim = buildVimPluginFrom2Nix {
    pname = "indent-blankline-nvim"; # Manifest entry: "lukas-reineke/indent-blankline.nvim"
    version = "2023-10-30";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/indent-blankline.nvim/archive/29be0919b91fb59eca9e90690d76014233392bef.tar.gz";
      sha256 = "0wmv1sndw1kmxll7r57ph2lf6ykv57hgxli4grvb3dr3fd46frxk";
    };
  };
  copilot-lua = buildVimPluginFrom2Nix {
    pname = "copilot-lua"; # Manifest entry: "zbirenbaum/copilot.lua"
    version = "2023-11-04";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot.lua/archive/73047082d72fcfdde1f73b7f17ad495cffcbafaa.tar.gz";
      sha256 = "0rv7f7pxda5n8lav0qhwx4a4azax41cffzmnpgm063pnq3nx61qn";
    };
  };
}
