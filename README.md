# poc_clear_double

> 🇧🇷 Quer ler em português? Confira o [`README.pt.md`](README.pt.md).

`poc_clear_double` is a **Dart analyzer plugin** created as a **proof of concept (PoC)** to:

- Understand how analyzer plugins behave.
- Try applying **architecture and consistency rules** across projects.
- Enforce the use of a specific extension (`parseDouble()`) instead of calling `double.parse(...)` directly.

---

## What is an analyzer plugin?

Out of the box, Dart/Flutter already relies on the **Dart analyzer** to:

- Show errors and warnings in your code.
- Run `dart analyze` / `flutter analyze`.
- Render lints inside the editor (VS Code, Android Studio, etc.).

An **analyzer plugin** is a Dart package that:

- Plugs into the Dart analyzer.
- Can **inspect the AST** (the code's syntax tree).
- Is able to create:
  - **Custom rules** (diagnostics/lints).
  - **Quick fixes** (automatic fixes for diagnostics).
  - **Assists** (refactorings/suggestions even when there is no error).

In practice, it is a way to teach the analyzer to understand and enforce **rules that are specific to your architecture**, framework, or team.

`poc_clear_double` is a simple PoC built with this mechanism, but the same pattern can be applied to real architecture rules.

---

## What the plugin enforces

Right now the plugin ships with:

### Rule: `prefer_parse_double`

It detects calls such as:

```dart
double.parse(expr);
```

and emits a diagnostic suggesting:

```dart
expr.parseDouble();
```

It assumes you already have an **extension** (for example, on `String`) that provides `parseDouble()` and you want to standardize its usage.

> ⚠️ The plugin **assumes** you declared and imported a `parseDouble()` extension. It only suggests/mechanizes the replacement.

### Quick fix: convert to `expr.parseDouble()`

Whenever the `prefer_parse_double` rule fires, the editor offers a *quick fix* that rewrites:

```dart
double.parse(expr);
```

to:

```dart
expr.parseDouble();
```

When needed, the plugin adds parentheses to preserve precedence, for example:

```dart
double.parse(a + b);   // before
(a + b).parseDouble(); // after
```

---

## Motivation (architecture PoC)

The plugin is a **proof of concept** meant to:

- See how style/architecture rules can live in a single plugin.
- Allow **multiple projects** to reuse the same rules consistently.

The main idea is to **help large codebases** filled with utilities and helpers accumulated over time. For example: the back end might require parsing a date in a very specific way, and the architecture already exposes an extension that handles it correctly. Even if a developer **does not know about that helper**, as soon as they try a “generic” approach (`double.parse`, `DateTime.parse`, a homegrown helper, etc.), the plugin can suggest the **pre-approved patterns**, guiding them toward the correct tools for that codebase.

---

## Project structure

```text
poc_pattern/
  pubspec.yaml
  analysis_options.yaml
  lib/
    main.dart
    fixes/
      fixes.dart
    rules/
      rule.dart
  test/
    poc_pattern_test.dart
  exemple/
    (Flutter app used to try out the plugin)
```

### What each file/folder does

- `exemple/`  
  Flutter app used as a playground to validate the plugin.

- `lib/main.dart`  
  Plugin entry point. Registers the `PreferParseDoubleRule` and the `UseParseDoubleFix` in the Dart analyzer.

- `lib/rules/rule.dart`  
  The rule implementation. It walks the AST looking for `double.parse(expr)` calls and reports the `prefer_parse_double` diagnostic.

- `lib/fixes/fixes.dart`  
  The quick fix implementation. Rewrites `double.parse(expr)` into `expr.parseDouble()`.

- `test/poc_pattern_test.dart`  
  Automated tests that make sure the rule fires where it should and stays silent elsewhere.

---

## Using the plugin in another project

Inside the Dart/Flutter project where you want to try the plugin, add to `pubspec.yaml`:

```yaml
dev_dependencies:
  poc_pattern:
    path: ../poc_pattern
```

> Adjust the `path` according to where the plugin lives in your workspace.

Then, in that project's `analysis_options.yaml`:

```yaml
plugins:
  poc_pattern:
    path: ../poc_pattern
    diagnostics:
      prefer_parse_double: true
```

Final steps:

1. Save the files.
2. **Restart the Dart Analysis Server** in your editor.
3. In any file containing `double.parse(expr)` you'll now see:
   - the `prefer_parse_double` lint, and
   - a quick fix that converts it to `expr.parseDouble()`.

---

## Development / tests

Run the plugin tests with:

```bash
dart test
```

---

## Further reading

- Official Dart docs on analyzer plugins: https://dart.dev/tools/analyzer-plugins
