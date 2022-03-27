type
  Point* = tuple
    x: int
    y: int

  Size* = tuple
    width: int
    height: int

proc cols*(size: Size): int =
  ## Alias for width
  size.width

proc columns*(size: Size): int =
  ## Alias for width
  size.width

proc rows*(size: Size): int =
  ## Alias for height
  size.height
