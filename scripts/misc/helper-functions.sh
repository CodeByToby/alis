function set_password 
{
    read -sp "Enter password: " PASSWORD
    echo -ne '\n'
    read -sp "Enter password again: " PASSWORD_CHECK
    echo -ne '\n'

    # passwords do not match
    if [[ "$PASSWORD" != "$PASSWORD_CHECK" ]]; then
        echo "Passwords don't match. Try again..."
        set_password "$1"

    # passwords were left empty
    elif [ -z "$PASSWORD" ]; then
        read -n1 -p "You left the password empty. Not setting a password will lock you out of the account! Are you sure you want to leave it that way? (y/N) " OPTION

        if [[ $OPTION == +(y|Y) ]]; then
            set_variable "$1" ""
        else
            set_password "$1"
        fi
    
    # No problems encountered
    else 
        set_variable "$1" "$PASSWORD"
    fi
}

function set_variable
{
    echo "$1=\"$2\"" >> "$VARIABLE_FILE"
}

function change_variable
{
    print_error "$1 variable is not correct. What do you want to do?"
    
    select OPTION in 'Correct variable' 'Exit'; do
        [[ "$OPTION" == "Exit" ]] && \
            exit 2
        [[ "$OPTION" != "Correct variable" ]] && \
            continue
        
        case $2 in
            input) 
                echo -ne "\n"
                read -p "Input $1 variable: " "$1" ;;
            select) 
                echo -ne "\n"
                print_select "Select $1 variable: "
                
                select OPTION in $3; do
                    [ ! "$OPTION" ] && \
                        continue

                    eval "$1=$OPTION"
                    break
                done ;;
        esac

        break
    done
}