# oh-my-fish/jump-plugin; todo: completions
function j
    set -l MARKPATH "$HOME/.marks"
    if test (count $argv) -eq 0
        set -l file_list (command ls $MARKPATH)
        if test (count $file_list) -gt 0
            set -l mark_list
            for file in $file_list
                if test -d $MARKPATH/$file -a -L $MARKPATH/$file
                    set mark_list $mark_list $file
                end
            end
            if test (count $mark_list) -gt 0
                set -l output ""
                for mark_name in $mark_list
                    set -l real_path (readlink $MARKPATH/$mark_name)
                    set output "$output$mark_name $real_path"\n
                end
                echo $output | column -t
            end
        end
    else if [ "$argv[1]" = -h ]
        echo "Usage:"
        echo "  j              show all marks"
        echo "  j <mark>       change to mark"
        echo "  j -e <mark>    show the mark path"
        echo "  j -a [mark]    mark current dir"
        echo "  j -d <mark...> delete marks"
    else if [ "$argv[1]" = -e ]
        if not test -e "$MARKPATH/$argv[2]"
            echo "ERRMARK: not exists"
        else
            readlink $MARKPATH/$argv[2]
        end
    else if [ "$argv[1]" = -a ]
        if [ "$argv[2]" = "" ]
            # https://stackoverflow.com/a/15867729
            set -f mark (ls $MARKPATH | grep -E '^[0-9]+$' | sort -n | awk 'BEGIN{p=-1} $1!=p+1{exit}{p=p+1} END{print p+1}')
            if [ "$mark" = "" ]
                echo "ERRMARK: empty"
                return 1
            end
        else if test -e $MARKPATH/$argv[2]
            echo "A mark named $argv[2] already exists."
            return 1
        else
            set -f mark $argv[2]
        end
        command ln -sfv (pwd) $MARKPATH/$mark
    else if [ "$argv[1]" = -d ]
        for mark_name in $argv[2..-1]
            if test -d $MARKPATH/$mark_name -a -L $MARKPATH/$mark_name
                command rm -i $MARKPATH/$mark_name
            else
                echo "No such mark: $mark_name"
            end
        end
    else
        if test -d $MARKPATH/$argv[1] -a -L $MARKPATH/$argv[1]
            cd (readlink $MARKPATH/$argv[1])
        else
            echo "Mark invalid: $MARKPATH"
        end
    end
end
