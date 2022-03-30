import std/[posix, re, sequtils, strutils, tables]

import ../../events
import ansi_escapes
import mouse_bindings

const
  max_bytes = 2048
  start_paste = "\x1b[200~"
  end_paste = "\x1b[201~"

var
  data = ""
  events_queue = new_seq[EventPackage](0)
  in_paste = false
  mouse_re = re"^\e[(<?[\d;]+[mM]|M...)\Z"
  mouse_prefix_re = re"^\e[(<?[\dl;]*|M.{0,2})\Z"
  short_matches = new_table[string, bool]()
  tv: Timeval

tv.tv_sec = Time(0)
tv.tv_usec = 0

proc read_stdin(): string =
  ## Non-blocking read of stdin
  var fds: TFdSet
  FD_ZERO(fds)
  FD_SET(STDIN_FILENO, fds)
  discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)

  if FD_ISSET(STDIN_FILENO, fds) > 0:
    discard read(STDIN_FILENO, result.addr, max_bytes)

proc has_longer_match(prefix: string): bool =
  if prefix in short_matches: return true
  if prefix.match(mouse_prefix_re): return true

  for key in ANSI_ESCAPES.keys:
    if key != prefix and key.starts_with(prefix):
      short_matches[prefix] = true
      return true

  short_matches[prefix] = false
  return false

proc create_mouse_event(data: string): MouseEvent =
  ## Create a MouseEvent from an vt100 escape code.
  const
    default_info: MouseInfo = (mouse_move, no_button, no_mods)

  var
    info: int
    x: int
    y: int
    mouse_info: MouseInfo

  if data[2] == 'M':  # \x1b[MaB*
    (info, x, y) = data[3..^1].mapit(ord(it))
    mouse_info = TYPICAL.get_or_default(info, default_info)

    if x >= 0xDC00:
      x -= 0xDC00
    if y >= 0xDC00:
      y -= 0xDC00

    x -= 32
    y -= 32
  else:
    if data[2] == '<':  # \x1b[<64;85;12M
      (info, x, y) = data[3..^1].split(";", 3).map(parse_int)
      mouse_info = TERM_SGR.get_or_default((info, data[^1]), default_info)
    else:  # \x1b[96;14;13M
      (info, x, y) = data[2..^1].split(";", 3).map(parse_int)
      mouse_info = URXVT.get_or_default(info, default_info)

    x -= 1
    y -= 1

  result = ((y, x), mouse_info[0], mouse_info[1], mouse_info[2])

proc find_longest_match =
  var
    prefix: string
    suffix: string
    kp: KeyPressEvent

  for i in countdown(data.len - 1, 0):
    prefix = data[0..i]
    suffix = data[i + 1..^1]

    if prefix.match(mouse_re):
      let m = Event(mouse_event: create_mouse_event(prefix))
      events_queue.add((mouse, m))
      data = suffix
      return

    if prefix == start_paste:
      in_paste = true
      data = suffix
      return

    if prefix notin ANSI_ESCAPES:
      continue

    kp = ANSI_ESCAPES[prefix]

    if kp.key == events.Key.escape and kp.mods == no_mods:
      if suffix.len == 1:
        # alt + character
        kp = (suffix, events.Key.char, (true, false, false))
        events_queue.add((key_press, Event(key_press_event: kp)))
        data = ""
        return

      if suffix.len > 1:
        # unknown escape sequence
        kp = ("", events.Key.unknown, no_mods)
        events_queue.add((key_press, Event(key_press_event: kp)))
        data = ""
        return

    events_queue.add((key_press, Event(key_press_event: kp)))
    data = suffix

proc parse_ansi(key: string) =
  if key == "":
    while data.len > 0:
      find_longest_match()
  else:
    data.add(key)

    if in_paste:
      if data.ends_with(end_paste):
        data.remove_suffix(end_paste)

        let p: PasteEvent = (paste: data)
        events_queue.add((paste, Event(paste_event: p)))

        in_paste = false
        data = ""
    elif data.len > 0 and not has_longer_match(data):
      find_longest_match()

proc read_keys*: seq[EventPackage] =
  events_queue.set_len(0)

  var keys: string

  while true:
    keys = read_stdin()
    if keys == "":
      break

    for key in keys:
      parse_ansi($key)

  parse_ansi("")

  return events_queue
