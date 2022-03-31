from std/tables import toTable, Table
from ../../io_types import MouseEventType, MouseButton, Mods, MouseInfo, no_mods

const
  alt: Mods = (true, false, false)
  control: Mods = (false, true, false)
  shift: Mods = (false, false, true)
  alt_control: Mods = (true, true, false)
  alt_shift: Mods = (true, false, true)
  control_shift: Mods = (false, true, true)
  alt_control_shift: Mods = (true, true, true)

  TERM_SGR*: Table[(int, char), MouseInfo] = {
    ( 0, 'm'): (mouse_up, left, no_mods),
    ( 4, 'm'): (mouse_up, left, shift),
    ( 8, 'm'): (mouse_up, left, alt),
    (12, 'm'): (mouse_up, left, alt_shift),
    (16, 'm'): (mouse_up, left, control),
    (20, 'm'): (mouse_up, left, control_shift),
    (24, 'm'): (mouse_up, left, alt_control),
    (28, 'm'): (mouse_up, left, alt_control_shift),

    ( 1, 'm'): (mouse_up, middle, no_mods),
    ( 5, 'm'): (mouse_up, middle, shift),
    ( 9, 'm'): (mouse_up, middle, alt),
    (13, 'm'): (mouse_up, middle, alt_shift),
    (17, 'm'): (mouse_up, middle, control),
    (21, 'm'): (mouse_up, middle, control_shift),
    (25, 'm'): (mouse_up, middle, alt_control),
    (29, 'm'): (mouse_up, middle, alt_control_shift),

    ( 2, 'm'): (mouse_up, right, no_mods),
    ( 6, 'm'): (mouse_up, right, shift),
    (10, 'm'): (mouse_up, right, alt),
    (14, 'm'): (mouse_up, right, alt_shift),
    (18, 'm'): (mouse_up, right, control),
    (22, 'm'): (mouse_up, right, control_shift),
    (26, 'm'): (mouse_up, right, alt_control),
    (30, 'm'): (mouse_up, right, alt_control_shift),

    ( 0, 'M'): (mouse_down, left, no_mods),
    ( 4, 'M'): (mouse_down, left, shift),
    ( 8, 'M'): (mouse_down, left, alt),
    (12, 'M'): (mouse_down, left, alt_shift),
    (16, 'M'): (mouse_down, left, control),
    (20, 'M'): (mouse_down, left, control_shift),
    (24, 'M'): (mouse_down, left, alt_control),
    (28, 'M'): (mouse_down, left, alt_control_shift),

    ( 1, 'M'): (mouse_down, middle, no_mods),
    ( 5, 'M'): (mouse_down, middle, shift),
    ( 9, 'M'): (mouse_down, middle, alt),
    (13, 'M'): (mouse_down, middle, alt_shift),
    (17, 'M'): (mouse_down, middle, control),
    (21, 'M'): (mouse_down, middle, control_shift),
    (25, 'M'): (mouse_down, middle, alt_control),
    (29, 'M'): (mouse_down, middle, alt_control_shift),

    ( 2, 'M'): (mouse_down, right, no_mods),
    ( 6, 'M'): (mouse_down, right, shift),
    (10, 'M'): (mouse_down, right, alt),
    (14, 'M'): (mouse_down, right, alt_shift),
    (18, 'M'): (mouse_down, right, control),
    (22, 'M'): (mouse_down, right, control_shift),
    (26, 'M'): (mouse_down, right, alt_control),
    (30, 'M'): (mouse_down, right, alt_control_shift),

    (32, 'M'): (mouse_move, left, no_mods),
    (36, 'M'): (mouse_move, left, shift),
    (40, 'M'): (mouse_move, left, alt),
    (44, 'M'): (mouse_move, left, alt_shift),
    (48, 'M'): (mouse_move, left, control),
    (52, 'M'): (mouse_move, left, control_shift),
    (56, 'M'): (mouse_move, left, alt_control),
    (60, 'M'): (mouse_move, left, alt_control_shift),

    (33, 'M'): (mouse_move, middle, no_mods),
    (37, 'M'): (mouse_move, middle, shift),
    (41, 'M'): (mouse_move, middle, alt),
    (45, 'M'): (mouse_move, middle, alt_shift),
    (49, 'M'): (mouse_move, middle, control),
    (53, 'M'): (mouse_move, middle, control_shift),
    (57, 'M'): (mouse_move, middle, alt_control),
    (61, 'M'): (mouse_move, middle, alt_control_shift),

    (34, 'M'): (mouse_move, right, no_mods),
    (38, 'M'): (mouse_move, right, shift),
    (42, 'M'): (mouse_move, right, alt),
    (46, 'M'): (mouse_move, right, alt_shift),
    (50, 'M'): (mouse_move, right, control),
    (54, 'M'): (mouse_move, right, control_shift),
    (58, 'M'): (mouse_move, right, alt_control),
    (62, 'M'): (mouse_move, right, alt_control_shift),

    (35, 'M'): (mouse_move, no_button, no_mods),
    (39, 'M'): (mouse_move, no_button, shift),
    (43, 'M'): (mouse_move, no_button, alt),
    (47, 'M'): (mouse_move, no_button, alt_shift),
    (51, 'M'): (mouse_move, no_button, control),
    (55, 'M'): (mouse_move, no_button, control_shift),
    (59, 'M'): (mouse_move, no_button, alt_control),
    (63, 'M'): (mouse_move, no_button, alt_control_shift),

    # This is duplicated from the block above with lowercase 'm' for WSL.
    (35, 'm'): (mouse_move, no_button, no_mods),
    (39, 'm'): (mouse_move, no_button, shift),
    (43, 'm'): (mouse_move, no_button, alt),
    (47, 'm'): (mouse_move, no_button, alt_shift),
    (51, 'm'): (mouse_move, no_button, control),
    (55, 'm'): (mouse_move, no_button, control_shift),
    (59, 'm'): (mouse_move, no_button, alt_control),
    (63, 'm'): (mouse_move, no_button, alt_control_shift),

    (64, 'M'): (scroll_up, no_button, no_mods),
    (68, 'M'): (scroll_up, no_button, shift),
    (72, 'M'): (scroll_up, no_button, alt),
    (76, 'M'): (scroll_up, no_button, alt_shift),
    (80, 'M'): (scroll_up, no_button, control),
    (84, 'M'): (scroll_up, no_button, control_shift),
    (88, 'M'): (scroll_up, no_button, alt_control),
    (92, 'M'): (scroll_up, no_button, alt_control_shift),

    (65, 'M'): (scroll_down, no_button, no_mods),
    (69, 'M'): (scroll_down, no_button, shift),
    (73, 'M'): (scroll_down, no_button, alt),
    (77, 'M'): (scroll_down, no_button, alt_shift),
    (81, 'M'): (scroll_down, no_button, control),
    (85, 'M'): (scroll_down, no_button, control_shift),
    (89, 'M'): (scroll_down, no_button, alt_control),
    (93, 'M'): (scroll_down, no_button, alt_control_shift),
  }.toTable

  TYPICAL*: Table[int, MouseInfo] = {
    32: (mouse_down, left, no_mods),
    33: (mouse_down, middle, no_mods),
    34: (mouse_down, right, no_mods),
    35: (mouse_up, unknown_button, no_mods),

    64: (mouse_move, left, no_mods),
    65: (mouse_move, middle, no_mods),
    66: (mouse_move, right, no_mods),
    67: (mouse_move, no_button, no_mods),

    96: (scroll_up, no_button, no_mods),
    97: (scroll_down, no_button, no_mods),
  }.toTable

  URXVT*: Table[int, MouseInfo] = {
    32: (mouse_down, unknown_button, no_mods),
    35: (mouse_up, unknown_button, no_mods),

    96: (scroll_up, no_button, no_mods),
    97: (scroll_down, no_button, no_mods),
  }.toTable
