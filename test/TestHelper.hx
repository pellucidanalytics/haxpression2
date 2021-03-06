import utest.Assert;

import thx.Either;
import thx.Nel;
import thx.Unit;
import thx.Validation;
import thx.Validation.*;
import thx.schema.SimpleSchema;
import thx.schema.SimpleSchema.*;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

using haxpression2.AnnotatedExpr;
using haxpression2.AnnotatedExprGroup;
using haxpression2.Expr;
using haxpression2.Value;
import haxpression2.eval.AnnotatedExprEvaluator;
import haxpression2.eval.ExprEvaluator;
import haxpression2.eval.EvalError;
import haxpression2.parse.ExprParser;
import haxpression2.parse.ParseMeta;
using haxpression2.render.SchemaJSONRenderer;
import haxpression2.schema.AnnotatedExprSchema;
import haxpression2.schema.ParseMetaSchema;
import haxpression2.simple.SimpleExpr;
import haxpression2.simple.SimpleValue;

class TestHelper {
  public static function getTestExprParserOptions<A>(options: { annotate : Int -> A }) : SimpleExprParserOptions<A> {
    return SimpleExprs.getStandardExprParserOptions(options);
  }

  public static function getTestExprEvaluatorOptions<TExpr>() : SimpleExprEvaluatorOptions<TExpr> {
    return {
      variables: [
        "a" => Values.int(0),
        "b" => Values.int(1),
        "c" => Values.int(2),
        "x" => Values.int(10),
        "y" => Values.int(-10),
        "z" => Values.int(100)
      ],
      unOps: SimpleExprs.getStandardExprEvaluatorUnOps(),
      binOps: SimpleExprs.getStandardExprEvaluatorBinOps(),
      functions: SimpleExprs.getStandardExprEvaluatorFuncs(),
      onError: (error, expr) -> new EvalError(error, expr)
    };
  }

  public static function getTestExprParser<A>(options: { annotate : Int -> A }) : ParseObject<SimpleAnnotatedExpr<A>> {
    return ExprParser.create(getTestExprParserOptions(options)).expr;
  }

  public static function assertParseValue(expected : SimpleValue, input : String, ?pos : haxe.PosInfos) : Void {
    switch SimpleValueParser.parseString(input) {
      case Left(error) : Assert.fail(error.toString(), pos);
      case Right(actual) : Assert.same(expected, actual);
    };
  }

  public static function assertParseValueError(input : String, ?pos : haxe.PosInfos) : Void {
    switch SimpleValueParser.parseString(input) {
      case Left(errors) : Assert.pass(pos);
      case Right(actual) : Assert.fail('$input should not have parsed as a value', pos);
    };
  }

  public static function parseString(input : String) : Either<SimpleParseError<ParseMeta>, SimpleAnnotatedExpr<ParseMeta>> {
    return SimpleExprParser.parseString(input, getTestExprParserOptions({ annotate: ParseMeta.new }));
  }

  public static function parseStrings(input : Array<String>) : VNel<SimpleParseError<ParseMeta>, Array<SimpleAnnotatedExpr<ParseMeta>>> {
    return SimpleExprParser.parseStrings(input, getTestExprParserOptions({ annotate: ParseMeta.new }));
  }

  public static function parseStringMap(input : Map<String, String>) : VNel<SimpleParseError<ParseMeta>, Map<String, SimpleAnnotatedExpr<ParseMeta>>> {
    return SimpleExprParser.parseStringMap(input, getTestExprParserOptions({ annotate: ParseMeta.new }));
  }

  public static function renderString<A>(input : SimpleExpr<A>) : String {
    return SimpleExprRenderer.renderString(input);
  }

  public static function assertParseString<A>(input : String, expected : SimpleAnnotatedExpr<A>, ?log : Bool, ?pos : haxe.PosInfos) : Void {
    switch SimpleExprParser.parseString(input, TestHelper.getTestExprParserOptions({ annotate: ParseMeta.new })) {
      case Left(parseError) : Assert.fail(parseError.toString(), pos);
      case Right(actual) :
        if (log) {
          trace(input);
          trace(SimpleAnnotatedExprRenderer.renderJSONString(actual, SimpleValueSchema.schema(), ParseMetaSchema.schema()));
        }
        Assert.same(expected, actual, pos);
    }
  }

  public static function assertParseStringError(input : String, ?pos : haxe.PosInfos) : Void {
    switch SimpleExprParser.parseString(input, TestHelper.getTestExprParserOptions({ annotate: ParseMeta.new })) {
      case Left(parseError) : Assert.pass(pos);
      case Right(_) : Assert.fail('$input should not have parsed', pos);
    };
  }

  public static function assertFormatString(expected : String, input : String, ?pos : haxe.PosInfos) : Void {
    switch SimpleExprRenderer.formatString(input, getTestExprParserOptions({ annotate: ParseMeta.new })) {
      case Left(error) : Assert.fail(error.toString());
      case Right(actual) : Assert.same(expected, actual);
    };
  }

  static function evalErrorsToString<E, A>(errors : Nel<{ expr: SimpleAnnotatedExpr<A>, error: SimpleEvalError<SimpleAnnotatedExpr<A>> }>, metaSchema : Schema<E, A>) : String {
    return errors.map(error -> evalErrorToString(error, metaSchema)).toArray().join("\n");
  }

  static function evalErrorToString<E, A>(data: { expr: SimpleAnnotatedExpr<A>, error : SimpleEvalError<SimpleAnnotatedExpr<A>> }, metaSchema : Schema<E, A>) : String {
    return data.error.renderString(ae -> SimpleAnnotatedExprRenderer.renderJSONString(ae, SimpleValueSchema.schema(), metaSchema));
  }

  public static function evalString(input : String) : VNel<String, SimpleValue> {
    return switch SimpleAnnotatedExprEvaluator.evalString(input, getTestExprParserOptions({ annotate: ParseMeta.new }), getTestExprEvaluatorOptions()) {
      case ParseError(error) : failureNel(error.toString());
      case EvalErrors(errors) : failureNel(evalErrorsToString(errors, ParseMetaSchema.schema()));
      case Evaluated(value) : successNel(value);
    };
  }

  public static function assertEvalString(expected : SimpleValue, input : String, ?pos : haxe.PosInfos) : Void {
    switch evalString(input) {
      case Left(errors) : Assert.fail(errors.toArray().map(err -> err.toString()).join("\n"), pos);
      case Right(actual) : Assert.same(expected, actual, pos);
    };
  }

  public static function simplifyString(input : String) : String {
    return ExprEvaluator.simplifyString(
      input,
      getTestExprParserOptions({ annotate: _ -> unit }),
      getTestExprEvaluatorOptions(),
      SimpleValueRenderer.renderString
    );
  }

  public static function assertSimplifyString(expected : String, input : String, ?pos : haxe.PosInfos) : Void {
    Assert.same(expected, simplifyString(input), pos);
  }

  public static function traceExpr(input : String, ?pos : haxe.PosInfos) : Void {
    switch parseString(input) {
      case Left(error) : trace(error.toString(), pos);
      case Right(ae) : trace(SimpleExprRenderer.renderString(ae.expr));
    };
  }

  public static function assertExprGetVars(expected : Array<String>, input : String, ?pos : haxe.PosInfos) : Void {
    switch parseString(input) {
      case Left(error) : trace(error.toString(), pos);
      case Right(ae) : Assert.same(expected, Exprs.getVarsArray(ae.expr), pos);
    }
  }

  public static function assertAnnotatedExprGetVars(expected : Map<String, Array<ParseMeta>>, input : String, ?pos : haxe.PosInfos) : Void {
    switch parseString(input) {
      case Left(error) : trace(error.toString(), pos);
      case Right(ae) : Assert.same(expected, AnnotatedExpr.getVarsMap(ae), pos);
    }
  }

  public static function traceAnalyzeResult(result : AnalyzeResult<SimpleValue, ParseMeta>) : Void {
    var str = AnalyzeResult.schema(
      AnalyzedExpr.schema(
        AnnotatedExprSchema.schema(SimpleValueSchema.schema(), ParseMetaSchema.schema()),
        AnnotatedExprSchema.schema(SimpleValueSchema.schema(), constant(unit))
      )
    )
    .renderJSONString(result);
    trace(str);
  }
}
