# Archive and Extraction

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Creates an archive from directory
function mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
function mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }
function mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
function mkzip() { zip -r "${1%%/}.zip" "$1" ; }

# Files and Strings

# remove duplicate lines in a file (without resorting)
function removeduplines() { awk '!x[$0]++' "$1" > "$1".unique; }

# replace space with underscores for all files in directory
function blank_rename() {
    ONE=1                     # For getting singular/plural right (see below).
    number=0                  # Keeps track of how many files actually renamed.
    FOUND=0                   # Successful return value.
    for filename in *         #Traverse all files in directory.
    do
        echo "$filename" | grep -q " "         #  Check whether filename
        if [ $? -eq $FOUND ]                   #+ contains space(s).
        then
            fname=$filename                      # Yes, this filename needs work.
            n=`echo $fname | sed -e "s/ /_/g"`   # Substitute underscore for blank.
            mv "$fname" "$n"                     # Do the actual renaming.
            let "number += 1"
        fi
    done
    if [ "$number" -eq "$ONE" ]                 # For correct grammar.
    then
        echo "$number file renamed."
    else
        echo "$number files renamed."
    fi
}

# lowercase file names
function lc_fnames() {
    for file ; do
        filename=${file##*/}
        case "$filename" in
            */*) dirname==${file%/*} ;;
            *) dirname=.;;
        esac
        nf=$(echo $filename | tr A-Z a-z)
        newname="${dirname}/${nf}"
        if [ "$nf" != "$filename" ]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
        else
            echo "lowercase: $file not changed."
        fi
    done
}

## Processes & System

# my processes
function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
# my processes in tree like structure
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

function usage() {
    # Credit: http://unix.stackexchange.com/questions/119126/command-to-display-memory-usage-disk-usage-and-cpu-load
    free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%)\n", $3,$2,$3*100/$2 }'
    df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $4,$3,$6}'
    top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}'
}


## Counting

function count_files() {
    case $1 in
        *+h) echo $(($(ls --color=no -1 -la . | grep -v ^l | wc -l)-1))       ;;
        *-h) echo $(($(ls --color=no -1 -l .  | grep -v ^l | wc -l)-1))       ;;
        *+d) echo $(($(ls --color=no -1 -la . | grep -v ^- | wc -l)-1))       ;;
        *-d) echo  $(($(ls --color=no -1 -l . | grep -v ^- | wc -l)-1))       ;;
        *+f) echo $(($(ls --color=no -1 -la . | grep -v ^d | wc -l)-1))       ;;
        *-f) echo  $(($(ls --color=no -1 -l . | grep -v ^d | wc -l)-1))       ;;
        *)   echo -e "\n${ewhite}Usage:"
             echo -e "\n${eorange}count_files${ewhite} | ${egreen}+h ${eiceblue}[count files and folders - include hidden ones] \
                      \n${eorange}count_files${ewhite} | ${egreen}-h ${eiceblue}[count files and folders - exclude hidden ones] \
                      \n${eorange}count_files${ewhite} | ${egreen}+d ${eiceblue}[count folders - include hidden ones] \
                      \n${eorange}count_files${ewhite} | ${egreen}-d ${eiceblue}[count folders - exclude hidden ones] \
                      \n${eorange}count_files${ewhite} | ${egreen}+f ${eiceblue}[count files - include hidden ones] \
                      \n${eorange}count_files${ewhite} | ${egreen}-f ${eiceblue}[count files - exclude hidden ones]\n"
             tput sgr0 ;;
        esac
}

function count_files_by_ext() { find . -type f | sed -n 's/..*\.//p' | sort -f | uniq -ic ; }


## Helper functions
function ask() {
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}
