# End-of-non-Interative
if not status is-interactive
    exit
end

if [ "$__INTELLIJ_COMMAND_HISTFILE__" = "" ]
    # helix
    set -gx VISUAL hx
    abbr -a hi "hx ."
else
    # jetbrains, todo: better way to detect
    # @see platform-impl/src/com/intellij/ide/CommandLineProcessor.kt openFileOrProject
    # TODO: specify the real line?
    set -gx VISUAL "$HOME/.local/share/JetBrains/Toolbox/scripts/clion --wait --line 1"
    alias hx "$VISUAL"
end

# backward compat
set -gx EDITOR "$VISUAL"

# fzf
set -g fzf_directory_opts --bind "alt-k:clear-query"

function _fzf_search_ripgrep
    # Copy from '_fzf_search_directory':
    set -f token (commandline --current-token)
    # expand any variables or leading tilde (~) in the token
    set -f expanded_token (eval echo -- $token)
    # unescape token because it's already quoted so backslashes will mess up the path
    set -f unescaped_exp_token (string unescape -- $expanded_token)

    # https://codeberg.org/tplasdio/rgfzf/src/branch/main/rgfzf
    # TODO: Save queries for both ripgrep and fzf:
    set -l rg_cmd rg --column --line-number --no-heading --color=always
    set -f file_paths_selected (FZF_DEFAULT_COMMAND="$rg_cmd \"$unescaped_exp_token\"" \
        _fzf_wrapper --multi --ansi --delimiter : --layout=reverse --header-first --marker="*" \
        --query "$unescaped_exp_token" \
        --disabled \
        --bind "alt-k:clear-query" \
        --bind "ctrl-y:unbind(change,ctrl-y)+change-prompt(fzf: )+enable-search+clear-query+rebind(ctrl-r)" \
        --bind "ctrl-r:unbind(ctrl-r)+change-prompt(rg: )+disable-search+clear-query+reload($rg_cmd {q} || true)+rebind(change,ctrl-y)" \
        --bind "change:reload:sleep 0.2; $rg_cmd {q} || true" \
        --prompt "rg: " \
        --header "switch: rg (ctrl+r) / fzf (ctrl+y)" \
        --preview 'bat --color=always {1} --highlight-line {2} --line-range $(math max {2}-15,0):' \
        --preview-window 'down,60%,noborder,+{2}+3/3,-3' | cut -s -d: -f1-3)

    if test $status -eq 0
        commandline --current-token --replace -- (string escape -- $file_paths_selected | string join ' ')
    end

    commandline --function repaint
end

function fzf_switch_common
    set -l indicator $argv[1]

    # abbr doesn't play very well with commandline...
    switch (commandline -t)
        case fd
            set -u fzf_fd_opts
            set -f func _fzf_search_directory
        case fa
            set -g fzf_fd_opts --hidden --no-ignore
            set -f func _fzf_search_directory
        case re
            set -f func _fzf_search_ripgrep
        case p
            set -f func _fzf_search_processes
        case gs
            set -f func _fzf_search_git_status
        case gl
            set -f func _fzf_search_git_log
        case '*'
            commandline -i "$indicator"
            return
    end

    if test "$indicator" = ";"
        commandline -rt ''
    else
        # Remove the last token of commandline, TODO: performance?
        set -l tokens (commandline -o)[1..-2]
        commandline -r (string join ' ' $tokens)
    end

    $func
end

bind --mode default ';' 'fzf_switch_common ";"' # e.g. f;, h;, ...
bind --mode default ':' 'fzf_switch_common ":"' # accept previous token as argument
abbr -a ga "git add ."
abbr -a gd "git diff HEAD"
abbr -a ra "rg --hidden --no-ignore"

# cd-to-file
functions -c cd fish_cd
function cd
    if test -f "$argv[1]"
        set argv[1] (dirname "$argv[1]")
    end

    # to keep 'cdh, dirh, prevd, nextd' works
    fish_cd $argv
end

# cursor
set -g fish_cursor_default line

# state
alias fss fish_state_save
alias fsc fish_state_clear
fish_state_load
