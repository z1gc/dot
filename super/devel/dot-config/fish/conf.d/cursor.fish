function __fish_reset_cursor_on_postexec --on-event fish_postexec
    __fish_cursor_konsole "$fish_cursor_default"
end
