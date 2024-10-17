# Saves fish state for across fish shells.

function fish_state_setup
    if test -z "$FISH_STATE_FILE"
        if test -n "$XDG_RUNTIME_DIR"
            set -g FISH_STATE_FILE "$XDG_RUNTIME_DIR/fish_state"
        else
            set -g FISH_STATE_FILE "/tmp/$(id -u).fish_state"
        end
    end

end

function fish_state_save
    fish_state_setup

    # There may be races between two fish shells, but it's a bit ok:
    echo "set -g FISH_STATE_PWD \"$PWD\"
set -g dirprev $dirprev
set -g dirnext $dirnext" > "$FISH_STATE_FILE"
end

# function fish_state_on_variable_pwd --on-variable PWD
#     fish_state_save
# end

function fish_state_load
    fish_state_setup

    if test -e "$FISH_STATE_FILE"
        source "$FISH_STATE_FILE"
        cd "$FISH_STATE_PWD"
    end
end

function fish_state_clear
    fish_state_setup
    rm -fv "$FISH_STATE_FILE"
end
