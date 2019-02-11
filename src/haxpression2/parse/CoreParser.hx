package haxpression2.parse;

using thx.Strings;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

class CoreParser {
  // Whitespace
  public static var ws(default, never) : ParseObject<String> = whitespace();
  public static var ows(default, never) : ParseObject<String> = optWhitespace();

  // Constants
  public static var na(default, never) : ParseObject<String> = ~/na/i.regexp();
  public static var nm(default, never) : ParseObject<String> = ~/nm/i.regexp();

  // Integers
  static var integerZero(default, never) : ParseObject<Int> = "0".string().map(Std.parseInt);
  static var integerNonZero(default, never) : ParseObject<Int> = ~/[1-9][0-9]*/.regexp().map(Std.parseInt);
  static var integerNonZeroNeg(default, never) : ParseObject<Int> = ~/\-[1-9][0-9]*/.regexp().map(Std.parseInt);
  public static var integer(default, never) : ParseObject<Int> = alt([integerZero, integerNonZero, integerNonZeroNeg]);
  //public static var integer(default, never) : ParseObject<Int> = alt([integerZero, integerNonZero]);

  // Decimals (parsed in string format, so the Expr type can parse into the appropriate Float/Decimal type)
  static var unsignedDecimalWithLeadingDigits(default, never) : ParseObject<String> = ~/\d[\d,]*(?:\.\d+)(?:e-?\d+)?/.regexp().map(v -> v.replace(",", ""));
  static var unsignedDecimalWithoutLeadingDigits(default, never) : ParseObject<String> = ~/\.\d+(?:e-?\d+)/.regexp();
  static var unsignedDecimal(default, never) : ParseObject<String> = alt([unsignedDecimalWithLeadingDigits, unsignedDecimalWithoutLeadingDigits]);
  static var positiveDecimal(default, never) : ParseObject<String> = ~/\+?/.regexp().then(ows).then(unsignedDecimal);
  static var negativeSignDecimal(default, never) : ParseObject<String> = "-".string().then(ows).then(unsignedDecimal);
  /*
  static var negativeParenDecimal(default, never) : ParseObject<String> =
    "(".string()
      .then(ows)
      .then(unsignedDecimal)
      .skip(ows)
      .skip(")".string())
      .map(str -> '-${str.trim().trimCharsLeft("(").trimCharsRight(")")}');
      */
  static var negativeDecimal(default, never) : ParseObject<String> = alt([negativeSignDecimal/*, negativeParenDecimal*/]);
  public static var decimalString(default, never) : ParseObject<String> = alt([negativeDecimal, positiveDecimal]);

  // Bools
  static var boolTrue(default, never) : ParseObject<Bool> = ~/true/i.regexp().map(v -> true);
  static var boolFalse(default, never) : ParseObject<Bool> = ~/false/i.regexp().map(v -> false);
  public static var bool(default, never) : ParseObject<Bool> = alt([boolTrue, boolFalse]);

  // Strings
  static var stringDoubleQuote(default, never) : ParseObject<String> = ~/"[^"]*"/.regexp().map(str -> str.trimChars('"'));
  static var stringSingleQuote(default, never) : ParseObject<String> = ~/'[^']*'/.regexp().map(str -> str.trimChars("'"));
  public static var string(default, never) : ParseObject<String> = alt([stringDoubleQuote, stringSingleQuote]);
}
