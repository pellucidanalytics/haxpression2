package haxpression2;

using thx.Arrays;
import thx.Unit;

/**
 *  Expression AST
 */
enum Expr<V, A> {
  ELit(value : V);
  EVar(name : String);
  EFunc(func : String, argExprs : Array<AnnotatedExpr<V, A>>);
  EUnOpPre(op : String, precedence: Int, operandExpr : AnnotatedExpr<V, A>);
  //EUnOpPost(op : String, expr : AnnotatedExpr<V, A>);
  EBinOp(op : String, precedence: Int, leftExpr : AnnotatedExpr<V, A>, rightExpr : AnnotatedExpr<V, A>);
}

/**
 *  Helper class for dealing with `Expr<V, A>`
 */
class Exprs {
  public static function isVar<V, A>(expr : Expr<V, A>, name : String) : Bool {
    return switch expr {
      case EVar(exprName) if (exprName == name) : true;
      case _ : false;
    };
  }

  public static function isAnyLit<V, A>(expr : Expr<V, A>) : Bool {
    return switch expr {
      case ELit(_) : true;
      case _ : false;
    }
  }

  public static function getVarsArray<V, A>(expr : Expr<V, A>) : Array<String> {
    function accVars(acc: Array<String>, expr : Expr<V, A>) : Array<String> {
      return switch expr {
        case ELit(_) : acc;
        case EVar(name) : acc.concat([name]);
        case EFunc(name, argExprs) : acc.concat(argExprs.map(ae -> ae.expr).flatMap(getVarsArray));
        case EUnOpPre(_, _, operandExpr) : acc.concat(getVarsArray(operandExpr.expr));
        case EBinOp(_, _, leftExpr, rightExpr) : acc.concat(getVarsArray(leftExpr.expr)).concat(getVarsArray(rightExpr.expr));
      };
    }
    return accVars([], expr).distinct();
  }

  public static function mapLit<V1, V2, A>(expr : Expr<V1, A>, f : V1 -> V2) : Expr<V2, A> {
    return switch expr {
      case ELit(v) : ELit(f(v));
      case EVar(name) : EVar(name);
      case EFunc(name, args) : EFunc(name, args.map(arg -> AnnotatedExpr.mapLit(arg, f)));
      case EUnOpPre(op, precedence, operandExpr) : EUnOpPre(op, precedence, AnnotatedExpr.mapLit(operandExpr, f));
      case EBinOp(op, precedence, leftExpr, rightExpr) : EBinOp(op, precedence, AnnotatedExpr.mapLit(leftExpr, f), AnnotatedExpr.mapLit(rightExpr, f));
    }
  }

  public static function mapAnnotation<V, A, B>(expr : Expr<V, A>, f : AnnotatedExpr<V, A> -> B) : Expr<V, B> {
    return switch expr {
      case ELit(value) : ELit(value);
      case EVar(name) : EVar(name);
      case EFunc(name, argExprs) : EFunc(name, argExprs.map(argExpr -> AnnotatedExpr.mapAnnotation(argExpr, f)));
      case EUnOpPre(op, precedence, operandExpr) : EUnOpPre(op, precedence, AnnotatedExpr.mapAnnotation(operandExpr, f));
      case EBinOp(op, precedence, leftExpr, rightExpr) : EBinOp(op, precedence, AnnotatedExpr.mapAnnotation(leftExpr, f), AnnotatedExpr.mapAnnotation(rightExpr, f));
    };
  }

  public static function voidAnnotation<V, A>(expr : Expr<V, A>) : Expr<V, Unit> {
    return mapAnnotation(expr, _ -> unit);
  }
}
