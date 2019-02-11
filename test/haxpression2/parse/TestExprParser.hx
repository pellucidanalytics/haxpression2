package haxpression2.parse;

import utest.Assert;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

import haxpression2.AnnotatedExpr.create as ae;
using haxpression2.Value;
import haxpression2.parse.ParseMeta.create as meta;
import haxpression2.simple.SimpleExpr;

import TestHelper.assertParseString;
import TestHelper.assertParseStringError;

class TestExprParser {
  public function new() {}

  public function testWhitespaceErrors() : Void {
    assertParseStringError("");
    assertParseStringError(" ");
    assertParseStringError("   ");
    assertParseStringError("\t");
    assertParseStringError("\t ");
    assertParseStringError("()");
    assertParseStringError("( )");
    assertParseStringError(",");
  }

  public function testLitNANM() : Void {
    assertParseString("NA", ae(ELit(VNA), meta(0)));
    assertParseString("na", ae(ELit(VNA), meta(0)));
    assertParseString("Na", ae(ELit(VNA), meta(0)));
    assertParseString("nA", ae(ELit(VNA), meta(0)));
    assertParseString("NM", ae(ELit(VNM), meta(0)));
    assertParseString("nm", ae(ELit(VNM), meta(0)));
    assertParseString("Nm", ae(ELit(VNM), meta(0)));
    assertParseString("nM", ae(ELit(VNM), meta(0)));
    assertParseString(
      "NA + NM",
      ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VNA), meta(0)),
          ae(ELit(VNM), meta(5))
        ),
        meta(3)
      )
    );
  }

  public function testLitInt() : Void {
    assertParseString("0", ae(ELit(VInt(0)), meta(0)));
    assertParseString("1", ae(ELit(VInt(1)), meta(0)));
    assertParseString(" 1  ", ae(ELit(VInt(1)), meta(1)));
    assertParseString(" -1  ",
      ae(
        EUnOpPre(
          "-",
          2,
          ae(
            ELit(VInt(1)),
            meta(2)
          )
        ),
        meta(1)
      )
    );
  }

  public function testLitNum() {
    assertParseString("0.0", ae(ELit(VReal(0.0)), meta(0)));
    assertParseString("1.0", ae(ELit(VReal(1.0)), meta(0)));
    assertParseString(" 1.1  ", ae(ELit(VReal(1.1)), meta(1)));
  }

  public function testLitBool() {
    assertParseString("true", ae(ELit(VBool(true)), meta(0)));
    assertParseString("false", ae(ELit(VBool(false)), meta(0)));
    assertParseString("   true ", ae(ELit(VBool(true)), meta(3)));
    assertParseString("  false ", ae(ELit(VBool(false)), meta(2)));
    assertParseString("True", ae(ELit(VBool(true)), meta(0)));
    assertParseString("False", ae(ELit(VBool(false)), meta(0)));
    assertParseString("TRUE", ae(ELit(VBool(true)), meta(0)));
    assertParseString("FALSE", ae(ELit(VBool(false)), meta(0)));
  }

  public function testVar() {
    assertParseString("a", ae(EVar("a"), meta(0)));
    assertParseString(" a", ae(EVar("a"), meta(1)));
    assertParseString(" a ", ae(EVar("a"), meta(1)));
    assertParseString("   a ", ae(EVar("a"), meta(3)));
    assertParseString("sales", ae(EVar("sales"), meta(0)));
    assertParseString(" sales", ae(EVar("sales"), meta(1)));
    assertParseString("   sales ", ae(EVar("sales"), meta(3)));
    assertParseString("asn!sales", ae(EVar("asn!sales"), meta(0)));
    assertParseString(" asn!sales", ae(EVar("asn!sales"), meta(1)));
    assertParseString("   asn!sales ", ae(EVar("asn!sales"), meta(3)));
  }

  public function testVarErrors() {
    assertParseStringError("x y");
    assertParseStringError("!asn");
    assertParseStringError("asn!");
    assertParseStringError("asn!!sales");
    assertParseStringError("asn!sales x");
  }

  public function testFunc() {
    assertParseString("TEST()",
      ae(
        EFunc("TEST", []),
        meta(0)
      )
    );

    assertParseString(" TEST (   ) ",
      ae(
        EFunc("TEST", []),
        meta(1)
      )
    );

    assertParseString("TEST(1, true)",
      ae(
        EFunc("TEST", [
          ae(ELit(VInt(1)), meta(5)),
          ae(ELit(VBool(true)), meta(8))
        ]),
        meta(0)
      )
    );
  }

  public function testBinOp() {
    assertParseString("1+2",
      ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VInt(1)), meta(0)),
          ae(ELit(VInt(2)), meta(2))
        ),
        meta(1)
      )
    );

    assertParseString("(1+2)",
      ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VInt(1)), meta(1)),
          ae(ELit(VInt(2)), meta(3))
        ),
        meta(2)
      )
    );

    assertParseString(" 1  + 2  ",
      ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VInt(1)), meta(1)),
          ae(ELit(VInt(2)), meta(6))
        ),
        meta(4)
      )
    );

    assertParseString("1 + 2 * 3",
      ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VInt(1)), meta(0)),
          ae(
            EBinOp(
              "*",
              7,
              ae(ELit(VInt(2)), meta(4)),
              ae(ELit(VInt(3)), meta(8))
            ),
            meta(6)
          )
        ),
        meta(2)
      )
    );

    assertParseString("(1 + 2) * 3",
      ae(
        EBinOp(
          "*",
          7,
          ae(
            EBinOp(
              "+",
              6,
              ae(ELit(VInt(1)), meta(1)),
              ae(ELit(VInt(2)), meta(5))
            ),
            meta(3)
          ),
          ae(
            ELit(VInt(3)),
            meta(10)
          )
        ),
        meta(8)
      )
    );

    assertParseString("(1 + (2 + (3 + 4)))",
      ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VInt(1)), meta(1)),
          ae(
            EBinOp(
              "+",
              6,
              ae(ELit(VInt(2)), meta(6)),
              ae(
                EBinOp(
                  "+",
                  6,
                  ae(ELit(VInt(3)), meta(11)),
                  ae(ELit(VInt(4)), meta(15))
                ),
                meta(13)
              )
            ),
            meta(8)
          )
        ),
        meta(3)
      )
    );
  }

  public function testParseStringMap() : Void {
    assertParseStringMap([
      "a" => ae(ELit(VInt(0)), meta(0)),
      "b" => ae(
        EBinOp(
          "+",
          6,
          ae(ELit(VInt(1)), meta(0)),
          ae(EVar("a"), meta(4))
        ),
        meta(2)
      ),
      "c" => ae(EVar("d"), meta(0))
    ], [
      "a" => "0",
      "b" => "1 + a",
      "c" => "d"
    ]);
  }

  public function testParseStringMapError() : Void {
    var input = [
      "a" => "1.1.1", // bad
      "b" => "c",
      "c" => "" // bad
    ];
    switch ExprParser.parseStringMap(input, TestHelper.getTestExprParserOptions({ annotate: ParseMeta.new })) {
      case Left(errors) : Assert.same(2, errors.toArray().length);
      case Right(_) : Assert.fail("Should have failed to parse");
    };
  }

  public static function assertParseStringMap(expected : Map<String, SimpleAnnotatedExpr<ParseMeta>>, input : Map<String, String>, ?pos : haxe.PosInfos) : Void {
    switch ExprParser.parseStringMap(input, TestHelper.getTestExprParserOptions({ annotate: ParseMeta.new })) {
      case Left(errors) : Assert.fail('failed to parse map: ${errors}', pos);
      case Right(actual): Assert.same(expected, actual);
    };
  }
}
