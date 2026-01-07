# dangreco/flakes

A collection of opinionated Nix flakes and templates for various development
environments. Each template includes git hooks, file management, and development
tools pre-configured for an optimal development experience.


## Templates

---

All templates include:

- **Git Hooks**: Pre-configured with [git-hooks.nix](https://github.com/cachix/git-hooks.nix) for automated linting and formatting
- **Task Runner**: [go-task](https://taskfile.dev/) for common development tasks
- **Nix Tooling**: Language servers (nil, nixd) and formatters (nixfmt) included
- **YAML Support**: yamlfmt and yamllint for YAML file management
- **CI Shell**: Separate CI development shell for continuous integration environments
- **Editor Integration**: Zed editor configuration

---

### Default

A minimal flake template.

```bash
nix flake init --refresh -t github:dangreco/flakes 
```

### Deno

A Deno development flake template.

```bash
nix flake init --refresh -t github:dangreco/flakes#deno
```

### Python

A Python development flake template.

```bash
nix flake init --refresh -t github:dangreco/flakes#python
```

### Rust

A Rust development flake template.

```bash
nix flake init --refresh -t github:dangreco/flakes#rust
```

## License

See [LICENSE](LICENSE) for details.
