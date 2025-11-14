import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';

class PocClearDoubleFix extends ResolvedCorrectionProducer {
  static const _kind = FixKind(
    'double_parse_plugin.use_parse_double',
    DartFixKindPriority.standard,
    "Use 'parseDouble' instead of 'parse'",
  );

  PocClearDoubleFix({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => _kind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final invocation = node;
    if (invocation is! MethodInvocation) return;

    final target = invocation.target;
    if (target is! SimpleIdentifier ||
        target.name != 'double' ||
        invocation.methodName.name != 'parse') {
      return;
    }

    final args = invocation.argumentList.arguments;
    if (args.length != 1) return;

    final Expression arg = args.single;
    final String argSource = arg.toSource();

    final bool needsParens =
        arg is BinaryExpression ||
        arg is ConditionalExpression ||
        arg is CascadeExpression ||
        arg is AssignmentExpression;

    final replacement = needsParens
        ? '($argSource).parseDouble()'
        : '$argSource.parseDouble()';

    await builder.addDartFileEdit(file, (fileBuilder) {
      fileBuilder.addSimpleReplacement(range.node(invocation), replacement);
    });
  }
}
