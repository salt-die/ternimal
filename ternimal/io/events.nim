from ../data_structures import Point

type
  Key* {.pure.} = enum
    `char`
    escape
    left
    right
    up
    down
    home
    `end`
    insert
    delete
    pgup
    pgdn
    f1
    f2
    f3
    f4
    f5
    f6
    f7
    f8
    f9
    f10
    f11
    f12
    f13
    f14
    f15
    f16
    f17
    f18
    f19
    f20
    f21
    f22
    f23
    f24
    paste
    ignore
    tab
    enter
    backspace

  MouseEventType* {.pure.} = enum
    mouse_up
    mouse_down
    scroll_up
    scroll_down
    mouse_move

  MouseButton* {.pure.} = enum
    left
    middle
    right
    no_button
    unknown_button

  Mods* {.pure.} = tuple
    alt: bool
    ctrl: bool
    shift: bool

  KeyPressEvent* {.pure.} = tuple
    `char`: string
    key: Key
    mods: Mods

  MouseEvent* {.pure.} = tuple
    position: Point
    event_type: MouseEventType
    button: MouseButton
    mods: Mods

  PasteEvent* {.pure.} = tuple
    paste: string

proc meta*(mods: Mods): bool =
  ## Alias for `alt`
  mods.alt

proc control*(mods: Mods): bool =
  ## Alias for `ctrl`
  mods.ctrl

const
  NO_MODS*: Mods = (false, false, false)
  ENTER*: KeyPressEvent = ("", Key.enter, NO_MODS)
  ESCAPE*: KeyPressEvent = ("", Key.escape, NO_MODS)
