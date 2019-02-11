package haxpression2;

import utest.Assert;

using thx.Eithers;
import thx.Nel;
import thx.Validation.*;

using haxpression2.eval.AnnotatedExprEvaluator;
import haxpression2.parse.ParseMeta;
import haxpression2.parse.ParseMeta.create as meta;
import haxpression2.simple.SimpleExpr;

import TestHelper.assertAnnotatedExprGetVars;

class TestAnnotatedExpr {
  public function new() {}

  public function testGetVars() : Void {
    assertAnnotatedExprGetVars(new Map(), "1 + 2 + 3 / 4");

    assertAnnotatedExprGetVars([
      "a" => [meta(4)],
      "b" => [meta(12)]
    ], "1 + a + 3 / b + NA");

    assertAnnotatedExprGetVars([
      "a" => [
        meta(0),
        meta(40)
      ],
      "c" => [
        meta(4),
        meta(25),
        meta(47)
      ],
      "b" => [
        meta(12),
        meta(21),
        meta(29),
        meta(44),
      ]
    ], "a + c + 3 / b + NA + b + c + b * myFunc(a + b, c)");
  }

  public function testSubstituteMap() : Void {
    assertSubstituteMap("1", "1", ["a" => "2"]);
    assertSubstituteMap("2", "a", ["a" => "2"]);
    assertSubstituteMap("a", "a", ["b" => "2"]);
    assertSubstituteMap("2 + 3", "a + b", ["a" => "2", "b" => "3" ]);
  }

  public static function assertSubstituteMap(expected : String, input : String, vars : Map<String, String>, ?pos : haxe.PosInfos) : Void {
    val3(
      function(expectedExpr : SimpleAnnotatedExpr<ParseMeta>, inputExpr : SimpleAnnotatedExpr<ParseMeta>, subExprs : Map<String, SimpleAnnotatedExpr<ParseMeta>>) {
        var actualExpr = AnnotatedExprEvaluator.substituteMap(inputExpr, subExprs);
        var expectedStr = TestHelper.renderString(expectedExpr.expr);
        var actualStr = TestHelper.renderString(actualExpr.expr);
        Assert.same(expectedStr, actualStr);
      },
      TestHelper.parseString(expected).toVNel(),
      TestHelper.parseString(input).toVNel(),
      TestHelper.parseStringMap(vars),
      Nel.semigroup()
    );
  }

}
