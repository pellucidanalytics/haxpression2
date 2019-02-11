package haxpression2.parse;

import thx.Either;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

import haxpression2.Value;
import haxpression2.parse.CoreParser as C;
import haxpression2.parse.ParseError;

typedef ValueParserOptions<N> = {
  parseReal : String -> N
};

typedef ValueParserResult<N> = Either<ParseError<Value<N>>, Value<N>>;

typedef ValueParsers<N> = {
  value: ParseObject<Value<N>>,
  _internal: {
    valueNA: ParseObject<Value<N>>,
    valueNM: ParseObject<Value<N>>,
    valueNum: ParseObject<Value<N>>,
    valueInt: ParseObject<Value<N>>,
    valueStr: ParseObject<Value<N>>,
    valueBool: ParseObject<Value<N>>,
  }
};

class ValueParser {
  public static function create<N>(options: ValueParserOptions<N>) : ValueParsers<N> {
    var valueNA = C.na.map(_ -> VNA);
    var valueNM = C.nm.map(_ -> VNM);
    var valueNum = C.decimalString.map(options.parseReal).map(VReal);
    var valueInt = C.integer.map(VInt);
    var valueStr = C.string.map(VStr);
    var valueBool = C.bool.map(VBool);
    var value = alt([valueNA, valueNM, valueNum, valueInt, valueStr, valueBool]);
    return {
      value: value,
      _internal: {
        valueNA: valueNA,
        valueNM: valueNM,
        valueNum: valueNum,
        valueInt: valueInt,
        valueStr: valueStr,
        valueBool: valueBool,
      }
    };
  }

  public static function parseString<N>(input : String, options: ValueParserOptions<N>) : ValueParserResult<N> {
    var parseResult = create(options).value.skip(eof()).apply(input);
    return if (parseResult.status) {
      Right(parseResult.value);
    } else {
      Left(ParseError.fromParseResult(input, parseResult));
    }
  }
}
