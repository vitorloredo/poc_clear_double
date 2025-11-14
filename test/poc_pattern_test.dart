// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:poc_pattern/rules/rule.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

@reflectiveTest
class PreferParseDoubleRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    Registry.ruleRegistry.registerLintRule(PocClearDoubleRule());
    super.setUp();
  }

  @override
  String get analysisRule => 'prefer_parse_double';

  void test_reports_on_double_parse() async {
    await assertDiagnostics(
      r'''
void f(String s) {
  final value = double.parse(s);
}
''',
      // 35 = offset do 'd' de "double.parse" nessa string (com a \n inicial).
      // 15 = comprimento de "double.parse".
      [lint(35, 15)],
    );
  }

  /// Não deve reportar nada se não for double.parse.
  void test_ignores_other_calls() async {
    await assertNoDiagnostics(r'''
void f(String s) {
  final value = double.tryParse(s);
}
''');
  }
}

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferParseDoubleRuleTest);
  });
}
