#!/bin/sh

UID="$(printenv UID)"
GID="$(printenv GID)"

if [ "$UID" == "" ]; then
    UID=1000
fi

if [ "$GID" == "" ]; then
    GID="$UID"
fi

if [ $# -lt 1 ]; then
    echo "Usage: runas <command with arguments>"
    exit 1
fi

COMMAND=$1
shift

create_user () {
    addgroup -g $2 app
    adduser -h /home -u $1 -G app -D app -s /bin/sh
    chown -R app:app /home /app
}

show_info () {
    if [ "$(printenv VERBOSE)" == "" ]; then
        return;
    fi
    echo ""
    echo "#=========================================================="
    echo "# runas: $1"
    echo "#=========================================================="
    echo ""
}

CURRENT_UID=$(id -u app 2>/dev/null)
if [ $? -ne 0 ]; then
        show_info "Creating user with UID $UID and GID $GID."
        create_user $UID $GID
else
    if [ "$CURRENT_UID" -eq "$UID" ]; then
        show_info "runas: User already exists. Good."
    else
        show_info "Switching UID from $CURRENT_UID to $UID."
        deluser app
        create_user $UID $GID
    fi
fi

su app -c "$COMMAND $*"
