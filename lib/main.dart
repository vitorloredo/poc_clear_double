import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:poc_pattern/rules/rule.dart';
import 'package:poc_pattern/fixes/fixes.dart';

final plugin = PocClearDoublePlugin();

class PocClearDoublePlugin extends Plugin {
  @override
  void register(PluginRegistry registry) {
    // Register diagnostics, quick fixes, and assists.
    registry.registerWarningRule(PocClearDoubleRule());
    registry.registerFixForRule(PocClearDoubleRule.code, PocClearDoubleFix.new);
  }

  @override
  String get name => "clear_double";
}
