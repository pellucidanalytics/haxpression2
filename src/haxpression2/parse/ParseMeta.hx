package haxpression2.parse;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

class ParseMeta {
  public var index(default, null) : Int;

  public function new(index : Int) {
    this.index = index;
  }

  public static function create(index: Int) : ParseMeta {
    return new ParseMeta(index);
  }

  public function toString() {
    return 'ParseMeta(${index})';
  }

  public static function renderString(p : ParseMeta) : String {
    return p.toString();
  }
}
