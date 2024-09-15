<p align="center">
  <img src="./res/Catalog Lens Icon.png" height="150">
</p>

<h1 align="center">PNPM Catalog Lens <sup>Neovim</sup></h1>

<p align="center">
  Show versions as diagnostics for <a href="https://pnpm.io/catalogs" target="_blank">PNPM <code>catalog:</code> field.</a><br>
</p>

<p align="center" display="flex">
    <img width="300" alt="Screenshot before" src="./res/before.png">
    <img width="300" alt="Screenshot after" src="./res/after.png">
</p>

## Install

Using lazy.nvim:

```lua
---@type LazySpec
return {
  'https://github.com/ryoppippi/nvim-pnpm-catalog-lens',
  ft= { 'json' }
}
```

## Commands

| Command                  | Description      |
| ------------------------ | ---------------- |
| `PnpmCatalogLensEnable`  | Enable the lens  |
| `PnpmCatalogLensDisable` | Disable the lens |

## Credits

Logo is from
[`vscode-pnpm-catalog-lens`](https://github.com/antfu/vscode-pnpm-catalog-lens)

## Inspired by

- [vscode-pnpm-catalog-lens](https://github.com/antfu/vscode-pnpm-catalog-lens)
  by [Anthony Fu](https://github.com/antfu)

## License

[MIT](./LICENSE)
