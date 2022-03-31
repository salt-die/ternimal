import std/[asyncdispatch, posix, termios]

const
  ASYNC_STDIN_FILENO = STDIN_FILENO.AsyncFD

var
  before_mode: Termios
  raw_mode: Termios

template attach_reader*(cb: Callback, body: untyped) =
  discard STDIN_FILENO.tcgetattr(addr before_mode)
  discard STDIN_FILENO.tcgetattr(addr raw_mode)

  raw_mode.c_lflag = raw_mode.c_lflag and not (
    ECHO or ICANON or IEXTEN or ISIG
  )
  raw_mode.c_iflag = raw_mode.c_iflag and not (
    IXON or IXOFF or ICRNL or INLCR or IGNCR
  )
  raw_mode.c_cc[VMIN] = 1.cuchar
  discard STDIN_FILENO.tcsetattr(TCSANOW, addr raw_mode)

  ASYNC_STDIN_FILENO.register()
  ASYNC_STDIN_FILENO.addread(cb)

  try:
    body
  finally:
    ASYNC_STDIN_FILENO.unregister()
    discard STDIN_FILENO.tcsetattr(TCSANOW, addr before_mode)
