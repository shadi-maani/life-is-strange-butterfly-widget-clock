# Contributing to LiS Butterfly Clock 🦋

First off — thank you for even considering contributing. Every rewind counts.

## How to Contribute

### Reporting Bugs

If the butterfly stopped flying, or the clock froze in a time loop:

1. Open an [Issue](../../issues/new) with a clear title
2. Describe what happened vs. what you expected
3. Include your **Plasma version** (`plasmashell --version`)
4. Paste relevant **QML errors** from the terminal (run `plasmoidviewer -a lis-clock/`)
5. Screenshots help — a lot

### Suggesting Features

Have an idea that would make Max proud? Open an issue tagged `enhancement` and describe:

- **What** you want
- **Why** it would improve the widget
- Any **visual references** or mockups

### Submitting Code

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** — follow the existing code style (QML formatting, property ordering)
4. **Run the validator** before committing:
   ```bash
   cd lis-clock
   ./validate.sh
   ```
5. **Test visually** with `plasmoidviewer`:
   ```bash
   cd lis-clock && plasmoidviewer -a .
   ```
6. **Commit** with a meaningful message:
   ```bash
   git commit -m "feat: add particle trail to butterfly animation"
   ```
7. **Push** and open a **Pull Request**

### Code Style

- Use **4-space indentation** in QML files
- Group properties: id → dimensions → anchors → visual → behavior
- Keep animations in dedicated sections with clear comments
- All config entries must have matching `cfg_*` AND `cfg_*Default` in `ConfigGeneral.qml`
- All asset references must point to existing files in `contents/assets/`

### Project Structure

```
lis-clock/
├── metadata.json              # Plasma 6 plugin metadata
├── validate.sh                # Automated validation script
└── contents/
    ├── config/
    │   ├── main.xml           # Configuration schema (kcfg)
    │   └── config.qml         # Config model
    ├── ui/
    │   ├── main.qml           # Main widget logic
    │   └── ConfigGeneral.qml  # Settings UI
    └── assets/
        ├── CabinSketch-Bold.ttf
        ├── DuduCalligraphy.ttf
        ├── butterfly1.png
        ├── butterfly2.png
        └── darkroombutterfly3.png
```

### Commit Convention

Use prefixes for clarity:

| Prefix | Usage |
|--------|-------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `style:` | Visual/CSS/QML styling changes |
| `docs:` | Documentation updates |
| `refactor:` | Code restructuring |
| `test:` | Validation/test changes |

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

*"This action will have consequences..."*
