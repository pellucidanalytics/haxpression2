package haxpression2.parse;

class ExprParserBinOp {
  public var operatorRegexp(default, null) : EReg;
  public var precedence(default, null) : Int;

  public function new(op, precedence) {
    this.operatorRegexp = op;
    this.precedence = precedence;
  }
}
