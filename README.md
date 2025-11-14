# poc_clear_double

O `poc_clear_double` é um **plugin de análise (analyzer plugin) do Dart** criado como **prova de conceito (PoC)** para:

- Entender o funcionamento de plugins de análise.
- Testar como aplicar **regras de arquitetura e padronização** entre projetos.
- Forçar o uso de uma extensão específica (`parseDouble()`) em vez de chamadas diretas a `double.parse(...)`.

---

## O que é um plugin de análise (analyzer plugin)?

Normalmente, o Dart/Flutter já usa o **Dart analyzer** para:

- Mostrar erros e warnings no código.
- Rodar `dart analyze` / `flutter analyze`.
- Exibir lints no editor (VS Code, Android Studio, etc.).

Um **analyzer plugin** é um pacote Dart que:

- Se “pluga” no Dart analyzer.
- Consegue **inspecionar a AST** (árvore sintática) do código.
- Pode criar:
  - **Regras personalizadas** (diagnósticos/lints).
  - **Quick fixes** (correções automáticas).
  - **Assists** (refatorações/sugestões, mesmo sem erro).

Na prática: é um jeito de ensinar o analyzer a entender e reforçar **regras específicas da sua arquitetura**, do seu framework, ou do seu time.

O `poc_clear_double` é uma PoC simples usando esse mecanismo, mas a ideia é que o mesmo padrão possa ser usado para regras de arquitetura em projetos reais.

---

## O que este plugin faz

Atualmente o plugin tem:

### Regra: `prefer_parse_double`

Detecta chamadas do tipo:

```dart
double.parse(expr);
```

e gera um diagnóstico sugerindo trocar para:

```dart
expr.parseDouble();
```

A ideia é quando você tem uma **extension** (por exemplo em `String`) com `parseDouble()` e quer padronizar o uso dela ao longo do código.

> ⚠️ Este plugin **assume** que você já tem uma extensão `parseDouble()` declarada e importada no projeto. Ele apenas sugere/mecaniza a troca.

### Quick fix: converter para `expr.parseDouble()`

Quando a regra `prefer_parse_double` é disparada, o editor oferece um *quick fix* que reescreve:

```dart
double.parse(expr);
```

para:

```dart
expr.parseDouble();
```

Em alguns casos, se necessário, o plugin adiciona parênteses para preservar precedência, por exemplo:

```dart
double.parse(a + b);   // antes
(a + b).parseDouble(); // depois
```

---

## Motivação (PoC de arquitetura)

Esse plugin é uma **prova de conceito** para:

- Ver como centralizar regras de estilo/arquitetura em um plugin só.
- Permitir que **vários projetos** usem as mesmas regras de forma consistente.

A ideia principal é **ajudar grandes projetos** onde existem muitos *utils* e helpers criados ao longo do tempo.  
Por exemplo: o back-end pode exigir que uma data seja parseada de um jeito específico, e a arquitetura já definiu um util/extension que faz esse parse corretamente e mantém o padrão do código.  
Mesmo que a pessoa desenvolvedora **não conheça esse util na hora**, no momento em que ela tentar fazer de um jeito “genérico” ou conhecido (ex.: `double.parse`, `DateTime.parse`, um helper caseiro, etc.), o plugin pode sugerir automaticamente **os padrões pré-estabelecidos pela arquitetura**, guiando o uso correto das ferramentas da base de código.

---

## Estrutura do projeto

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
    (app Flutter usado para testar o plugin)
```

### O que é cada arquivo/pasta

- `exemple/`  
  App Flutter usado como *playground* pra validar o plugin na prática.

- `lib/main.dart`  
  Ponto de entrada do plugin. Registra a regra `PreferParseDoubleRule` e o quick fix `UseParseDoubleFix` no Dart analyzer.

- `lib/rules/rule.dart`  
  Implementa a regra em si: percorre a AST procurando chamadas `double.parse(expr)` e gera o diagnóstico `prefer_parse_double`.

- `lib/fixes/fixes.dart`  
  Implementa o quick fix associado à regra, reescrevendo `double.parse(expr)` para `expr.parseDouble()`.

- `test/poc_pattern_test.dart`  
  Testes automatizados que garantem que a regra se comporta como esperado (reporta onde deve e ignora onde não deve).

---

## Como usar o plugin em outro projeto

No projeto (Dart/Flutter) onde você quer testar o plugin, adicione em `pubspec.yaml`:

```yaml
dev_dependencies:
  poc_pattern:
    path: ../poc_pattern
```

> Ajuste o `path` conforme a localização do plugin no seu workspace.

Depois, no `analysis_options.yaml` do projeto:

```yaml
plugins:
  poc_pattern:
    path: ../poc_pattern
    diagnostics:
      prefer_parse_double: true
```

Passos finais:

1. Salvar os arquivos.
2. **Reiniciar o Dart Analysis Server** no editor.
3. Em qualquer arquivo onde houver `double.parse(expr)`, você deverá ver:
   - a lint `prefer_parse_double`,
   - um quick fix para converter para `expr.parseDouble()`.

---

## Desenvolvimento / Testes

Para rodar os testes do plugin:

```bash
dart test
```
