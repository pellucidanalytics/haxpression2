package haxpression2.schema;

import thx.Validation;
import thx.schema.ParseError;
import thx.schema.SchemaDSL.*;
import thx.schema.SimpleSchema;
import thx.schema.SimpleSchema.*;
using thx.schema.SchemaDynamicExtensions;

import haxpression2.Expr;

class ExprSchema {
  public static function schema<E, V, A>(valueSchema : Schema<E, V>, annotationSchema : Schema<E, A>) : Schema<E, Expr<V, A>> {
    var annotatedExprSchema = AnnotatedExprSchema.schema(valueSchema, annotationSchema);
    return oneOf([
      alt(
        "var",
        string(),
        (name: String) -> EVar(name),
        (expr : Expr<V, A>) -> switch expr {
          case EVar(name) : Some(name);
          case _ : None;
        }
      ),
      alt(
        "lit",
        valueSchema,
        (value: V) -> ELit(value),
        (expr : Expr<V, A>) -> switch expr {
          case ELit(value) : Some(value);
          case _ : None;
        }
      ),
      alt(
        "func",
        object(ap2(
          (name : String, args : Array<AnnotatedExpr<V, A>>) -> { name: name, args: args },
          required("name", string(), (obj : { name: String, args: Array<AnnotatedExpr<V, A>> }) -> obj.name),
          required("args", array(annotatedExprSchema), (obj : { name: String, args: Array<AnnotatedExpr<V, A>> }) -> obj.args)
        )),
        (obj : { name : String, args: Array<AnnotatedExpr<V, A>> }) -> EFunc(obj.name, obj.args),
        (expr : Expr<V, A>) -> switch expr {
          case EFunc(name, args) : Some({ name: name, args: args });
          case _ : None;
        }
      ),
      alt(
        "binOp",
        object(ap4(
          (op : String, precedence: Int, left : AnnotatedExpr<V, A>, right : AnnotatedExpr<V, A>) -> { op: op, precedence: precedence, left: left, right: right },
          required("op", string(), (obj : { op: String, precedence: Int, left: AnnotatedExpr<V, A>, right: AnnotatedExpr<V, A> }) -> obj.op),
          required("precedence", int(), (obj : { op: String, precedence: Int, left: AnnotatedExpr<V, A>, right: AnnotatedExpr<V, A> }) -> obj.precedence),
          required("left", annotatedExprSchema, (obj : { op: String, precedence: Int, left: AnnotatedExpr<V, A>, right: AnnotatedExpr<V, A> }) -> obj.left),
          required("right", annotatedExprSchema, (obj : { op: String, precedence: Int, left: AnnotatedExpr<V, A>, right: AnnotatedExpr<V, A> }) -> obj.right)
        )),
        (obj : { op: String, precedence: Int, left: AnnotatedExpr<V, A>, right: AnnotatedExpr<V, A> }) -> EBinOp(obj.op, obj.precedence, obj.left, obj.right),
        (expr : Expr<V, A>) -> switch expr {
          case EBinOp(op, prec, left, right) : Some({ op: op, precedence: prec, left: left, right: right });
          case _ : None;
        }
      ),
      alt(
        "unOpPre",
        object(ap3(
          (op : String, precedence : Int, operand : AnnotatedExpr<V, A>) -> { op: op, precedence: precedence, operand: operand },
          required("op", string(), (obj : { op: String, precedence: Int, operand: AnnotatedExpr<V, A> }) -> obj.op),
          required("precedence", int(), (obj : { op: String, precedence: Int, operand: AnnotatedExpr<V, A> }) -> obj.precedence),
          required("operand", annotatedExprSchema, (obj : { op: String, precedence: Int, operand: AnnotatedExpr<V, A> }) -> obj.operand)
        )),
        (obj : { op: String, precedence: Int, operand: AnnotatedExpr<V, A> }) -> EUnOpPre(obj.op, obj.precedence, obj.operand),
        (expr : Expr<V, A>) -> switch expr {
          case EUnOpPre(op, prec, opnd) : Some({ op: op, precedence: prec, operand: opnd });
          case _ : None;
        }
      )
    ]);
  }
}
