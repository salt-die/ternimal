import std/[math, strutils]

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
  let color = hexcode.fromHex[:uint32]
  result = (
    uint8(color shr 16),
    uint8(color shr 8 mod 256),
    uint8(color mod 256),
  )

proc from_hex*(cls: type[AColor], hexcode: string): AColor =
  let color = hexcode.fromHex[:uint32]
  # TODO: Default to 255 for alpha value if hexcode is too short.
  result = (
    uint8(color shr 24),
    uint8(color shr 16 mod 256),
    uint8(color shr 8 mod 256),
    uint8(color mod 256),
  )
