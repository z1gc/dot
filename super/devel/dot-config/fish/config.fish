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

# git
abbr -a gl "git log"
abbr -a gs "git status"
abbr -a ga "git add ."
abbr -a gd "git diff HEAD"

# ripgrep, for helix you can use 'space-/' to search
abbr -a ra "rg --hidden --no-ignore"

function fish_fast_switch
    # abbr doesn't play very well with commandline...
    switch (commandline -t)
        case f
            set -u fzf_fd_opts
            set -f func _fzf_search_directory
        case h
            set -g fzf_fd_opts --hidden
            set -f func _fzf_search_directory
        case p
            set -f func _fzf_search_processes
        case g
            set -f func _fzf_search_git_status
        case l
            set -f func _fzf_search_git_log
        case '*'
            commandline -i ';'
            return
    end

    # remove the input token from fzf.fish
    commandline -rt ''
    $func
end

# fdfind
abbr -a fa "fd --hidden --no-ignore"
bind --mode default ';' fish_fast_switch # e.g. f;, h;, ...

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
