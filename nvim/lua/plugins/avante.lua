return {
  {
    "yetone/avante.nvim",
    lazy = false,
    build = "make",
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      behaviour = {
        auto_suggestions = false,
        enable_cursor_planning_mode = true,
      },
      providers = {
        gemini = {
          model = "gemini-2.5-pro-exp-03-25",
          extra_request_body = {
            temperature = 0,
            max_tokens = 64000,
          },
        },
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-0",
          extra_request_body = {
            temperature = 0,
            max_tokens = 64000,
          },
        },
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "o3-mini",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },
      windows = {
        width = 40,
      },
      file_selector = {
        provider = "fzf",
        provider_opts = {},
      },
      suggestion = {
        debounce = 3000,
        throttle = 3000,
      },
    },
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
