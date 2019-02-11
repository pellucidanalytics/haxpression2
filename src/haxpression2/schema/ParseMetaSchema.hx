package haxpression2.schema;

import parsihax.*;
import parsihax.Parser.*;
using parsihax.Parser;

import thx.schema.SchemaDSL.*;
import thx.schema.SimpleSchema;
import thx.schema.SimpleSchema.*;

import haxpression2.parse.ParseMeta;

class ParseMetaSchema {
  public static function schema<E>() : Schema<E, ParseMeta> {
    return object(ap1(
      ParseMeta.new,
      required("index", int(), (meta : ParseMeta) -> meta.index)
    ));
  }
}
