type
  Point* = tuple
    y: int
    x: int

  Size* = tuple
    height: int
    width: int

proc cols*(size: Size): int =
  ## Alias for width
  size.width

proc columns*(size: Size): int =
  ## Alias for width
  size.width

proc rows*(size: Size): int =
  ## Alias for height
  size.height
