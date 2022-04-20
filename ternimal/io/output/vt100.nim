import std/[posix, strformat, termios]
from ../../ternimal_types import Size

var
  term: string  # TODO: set this at load time
  buffer: string

proc get_size*: Size =
  var win: IOctl_WinSize
  discard ioctl(STDIN_FILENO, TIOCGWINSZ, addr win)
  result = (int win.ws_row, int win.ws_col)

proc set_title*(title: string) =
  ## Set terminal title.
  if term != "linux" or term != "eterm-color":
    buffer &= fmt"\x1b]2;{title}\x07"

proc erase_screen* =
  buffer &= "\x1b[2J"

proc enter_alternate_screen* =
  buffer &= "\x1b[?1049h\x1b[H"

proc quit_alternate_screen* =
  buffer &= "\x1b[?1049l"

proc enable_mouse_support* =
  buffer &= "\x1b[?1000h\x1b[?1003h\x1b[?1015h\x1b[?1006h"

proc disable_mouse_support* =
  buffer &= "\x1b[?1000l\x1b[?1003l\x1b[?1015l\x1b[?1006l"

proc reset_attributes* =
  buffer &= "\x1b[0m"

proc enable_paste* =
  buffer &= "\x1b[?2004h"

proc disable_paste* =
  buffer &= "\x1b[?2004l"

proc show_cursor* =
  buffer &= "\x1b[?25h"

proc flush* =
  ## Write buffer to output stream.
  if buffer.len == 0:
    return
  stdout.write(buffer)
  buffer.set_len(0)
