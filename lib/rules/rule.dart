import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class PocClearDoubleRule extends AnalysisRule {
  /// Código do diagnóstico (nome aparece no analysis_options, etc).
  static const LintCode code = LintCode(
    'prefer_parse_double',
    "Use '.parseDouble' instead of 'double.parse'.",
    correctionMessage:
        "Try replacing 'double.parse(...)' with '.parseDouble(...)' to fit with the architecture of the poc.",
  );

  PocClearDoubleRule()
    : super(
        name: 'prefer_parse_double',
        description:
            "Enforces using '.parseDouble' instead of 'double.parse(...)'.",
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;

    final isDoubleParse =
        target is SimpleIdentifier &&
        target.name == 'double' &&
        node.methodName.name == 'parse' &&
        node.argumentList.arguments.length == 1;

    if (isDoubleParse) {
      rule.reportAtNode(node);
    }
  }
}
