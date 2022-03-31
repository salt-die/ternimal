from ../ternimal_types import Point

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
    ignore
    tab
    enter
    backspace
    unknown
    none

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

  MouseInfo* {.pure.} = (MouseEventType, MouseButton, Mods)

  MouseEvent* {.pure.} = tuple
    position: Point
    event_type: MouseEventType
    button: MouseButton
    mods: Mods

  PasteEvent* {.pure.} = tuple
    paste: string

  EventKind* = enum
    key_press, mouse, paste

  Event* = object
    case kind*: EventKind
    of key_press: key_press_event*: KeyPressEvent
    of mouse: mouse_event*: MouseEvent
    of paste: paste_event*: PasteEvent

proc meta*(mods: Mods): bool =
  ## Alias for `alt`
  mods.alt

proc control*(mods: Mods): bool =
  ## Alias for `ctrl`
  mods.ctrl

const
  no_mods*: Mods = (false, false, false)
  enter*: KeyPressEvent = ("", Key.enter, no_mods)
  escape*: KeyPressEvent = ("", Key.escape, no_mods)
