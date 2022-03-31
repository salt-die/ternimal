import io/events

type
  App* = object
    exit_key: KeyPressEvent
    background_char: char
    background_color_pair : ColorPair
    title: string
    double_click_timeout: float
    resize_poll_interval: float
    render_interval: float
