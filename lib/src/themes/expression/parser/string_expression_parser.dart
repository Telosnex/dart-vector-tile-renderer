import '../coalesce_expression.dart';
import '../concat_expression.dart';
import '../expression.dart';
import '../property_expression.dart';
import '../string_expression.dart';
import 'expression_parser.dart';

class ToStringExpressionParser extends ExpressionComponentParser {
  ToStringExpressionParser(ExpressionParser parser)
      : super(parser, 'to-string');

  @override
  bool matches(List<dynamic> json) {
    return super.matches(json) && json.length == 2;
  }

  @override
  Expression? parse(List<dynamic> json) {
    final delegate = parser.parseOptional(json[1]);
    if (delegate == null) {
      return null;
    }
    return ToStringExpression(delegate);
  }
}

class CoalesceExpressionParser extends ExpressionComponentParser {
  CoalesceExpressionParser(ExpressionParser parser) : super(parser, 'coalesce');

  @override
  bool matches(List<dynamic> json) {
    return super.matches(json) && json.length > 1;
  }

  @override
  Expression? parse(List json) {
    final values = json.sublist(1);
    final valueExpressions = values
        .map((e) => parser.parseOptional(e))
        .whereType<Expression>()
        .toList(growable: false);
    if (values.length != valueExpressions.length) {
      return null;
    }
    return CoalesceExpression(valueExpressions);
  }
}

class ConcatExpressionParser extends ExpressionComponentParser {
  ConcatExpressionParser(ExpressionParser parser) : super(parser, 'concat');

  @override
  bool matches(List<dynamic> json) {
    return super.matches(json) && json.length > 1;
  }

  @override
  Expression? parse(List json) {
    final values = json.sublist(1);
    final valueExpressions = values
        .map((e) => parser.parseOptional(e))
        .whereType<Expression>()
        .toList(growable: false);
    if (values.length != valueExpressions.length) {
      return null;
    }
    return ConcatExpression(valueExpressions);
  }
}

class FormatExpressionParser extends ExpressionComponentParser {
  FormatExpressionParser(ExpressionParser parser) : super(parser, 'format');

  @override
  bool matches(List<dynamic> json) {
    return super.matches(json) && json.length >= 3;
  }

  @override
  Expression? parse(List json) {
    final sections = <Expression>[];
    for (int i = 1; i < json.length; i += 2) {
      final section = parser.parseOptional(json[i]);
      if (section == null) {
        return null;
      }
      sections.add(section);

      if (i + 1 < json.length && json[i + 1] is! Map) {
        return null;
      }
    }

    return FormatExpression(sections);
  }
}

class StringExpressionParser extends ExpressionComponentParser {
  StringExpressionParser(ExpressionParser parser) : super(parser, 'string');

  @override
  bool matches(List<dynamic> json) {
    return super.matches(json) && json.length > 1;
  }

  @override
  Expression? parse(List json) {
    final values = json.sublist(1);
    final valueExpressions = values
        .map((e) => parser.parseOptional(e))
        .whereType<Expression>()
        .toList(growable: false);
    if (values.length != valueExpressions.length) {
      return null;
    }
    return StringExpression(valueExpressions);
  }
}

class GeometryTypeExpressionParser extends ExpressionComponentParser {
  GeometryTypeExpressionParser(ExpressionParser parser)
      : super(parser, 'geometry-type');

  @override
  bool matches(List<dynamic> json) {
    return super.matches(json) && json.length == 1;
  }

  @override
  Expression? parse(List<dynamic> json) {
    return GetPropertyExpression("\$type");
  }
}
