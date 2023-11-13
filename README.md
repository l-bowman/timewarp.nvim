# 🌀 Timewarp

Timewarp enhances your Neovim navigation among open buffers, automatically keeping track of your last edit and yank positions, enabling swift movement between important points in your code. Pivot as needed between these warp points and your initial cursor position.

## 📋 Requirements

Neovim v0.9+ recommended.

## 💾 Installation

Below is an example using the Lazy package manager for Neovim. Modify the configuration to fit your choice of package manager.

```lua
{
"l-bowman/timewarp.nvim",
config = function()
  require("timewarp").setup({})
end,
}
```

## ⌨️ Usage

- `:TimewarpLastEdit` - Jump to the position of the last edit.
- `:TimewarpLastYank` - Jump to the position of the last yank.
- `:TimewarpReturn` - Return to the initial position prior to the last warp.

### Which Key Example

For users of [https://github.com/folke/which-key.nvim](folke/which-key.nvim), here’s a suggestion for setting up your key bindings.

```lua
z = {
      name = "Timewarp",
      e = { "<cmd>TimewarpLastEdit<cr>", "Last Edit" },
      y = { "<cmd>TimewarpLastYank<cr>", "Last Yank" },
      r = { "<cmd>TimewarpReturn<cr>", "Return to Initial Position" },
    },
```

## 🤖 Behavior Explained

### Essential Navigation Points

Timewarp simplifies your navigation by focusing on three points of interest:

- **Last Edit**: Quickly warp back to where you last modified the code.
- **Last Yank**: Easily warp back to where you last yanked text.
- **Return**: Return to where you were before you warped.

## License

[MIT License](LICENSE)
