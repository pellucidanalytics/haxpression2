package haxpression2.schema;

import utest.Assert;

import thx.schema.SimpleSchema.*;
using thx.schema.SchemaDynamicExtensions;

import haxpression2.AnnotatedExpr;
import haxpression2.AnnotatedExpr.create as ae;
import haxpression2.Value;
import haxpression2.parse.ParseMeta;
import haxpression2.parse.ParseMeta.create as meta;

class TestAnnotatedExprSchema {
  public function new() {}

  public static function assertRenderDynamic(expected : Dynamic, ae : AnnotatedExpr<Value<Float>, ParseMeta>, ?pos : haxe.PosInfos) : Void {
    var valueSchema = ValueSchema.schema(float());
    var metaSchema = ParseMetaSchema.schema();
    Assert.same(
      expected,
      AnnotatedExprSchema.schema(valueSchema, metaSchema).renderDynamic(ae),
      pos
    );
  }

  public function testRenderDynamic() : Void {
    assertRenderDynamic({
      expr: {
        func: {
          name: "myFunc",
          args: ([
            {
              expr: { lit: { int: 1 } },
              annotation: { index: 1 }
            },
            {
              expr: { "var": "a" },
              annotation: { index: 3 }
            }
          ] : Array<Dynamic>)
        }
      },
      annotation: { index: 0 }
    },
    ae(
      EFunc("myFunc", [
        ae(
          ELit(VInt(1)),
          meta(1)
        ),
        ae(
          EVar("a"),
          meta(3)
        ),
      ]),
      meta(0)
    ));
  }
}
