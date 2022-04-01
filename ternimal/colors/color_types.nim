import std/strutils

type
  Color* = tuple
    red: uint8
    green: uint8
    blue: uint8

  AColor* = tuple
    red: uint8
    green: uint8
    blue: uint8
    alpha: uint8

  ColorPair* = tuple
    bg: Color
    fg: Color

proc from_hex*(cls: type[Color], hexcode: string): Color =
  var hex = hexcode.normalize()
  hex.remove_prefix('#')
  result = (
    hex[0..1].from_hex[:uint8],
    hex[2..3].from_hex[:uint8],
    hex[4..5].from_hex[:uint8],
  )

proc from_hex*(cls: type[AColor], hexcode: string): AColor =
  var hex = hexcode.normalize()
  hex.remove_prefix('#')
  result = (
    hex[0..1].from_hex[:uint8],
    hex[2..3].from_hex[:uint8],
    hex[4..5].from_hex[:uint8],
    if hex.len == 8: hex[6..7].from_hex[:uint8] else: 255.uint8,
  )
