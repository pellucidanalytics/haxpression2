package haxpression2.parse;

import haxe.PosInfos;
import haxe.CallStack;
import haxe.ds.Option;

import thx.Error;
using thx.Options;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

class ParseError<T> extends Error {
  public var input(default, null) : String;
  public var result(default, null) : ParseResult<T>;
  public var details(default, null) : String;
  public var fieldInfo(default, null) : Option<String>;

  function new(
    message : String,
    input : String,
    result: ParseResult<T>,
    details: String,
    fieldInfo : Option<String>,
    ?stack: Array<StackItem>,
    ?pos: PosInfos
  ) {
    super(message, stack, pos);
    this.input = input;
    this.result = result;
    this.details = details;
    this.fieldInfo = fieldInfo;
  }

  public static function withFieldInfo<T>(error : ParseError<T>, fieldInfo : String) : ParseError<T> {
    return new ParseError(error.message, error.input, error.result, error.details, Some(fieldInfo));
  }

  public static function fromParseResult<T>(input : String, result : ParseResult<T>) : ParseError<T> {
    var message = 'Failed to parse expression "$input" (furthest position reached: ${result.furthest})';
    var details = ParseUtil.formatError(result, input);
    return new ParseError(
      message,
      input,
      result,
      details,
      None
    );
  }

  public override function toString() : String {
    var fieldPart = fieldInfo.cataf(
      () -> "",
      field -> 'For field "$field": '
    );
    return '${fieldPart}${message}';
  }
}
