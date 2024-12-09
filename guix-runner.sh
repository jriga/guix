#!/bin/sh
#
# ensures the guix-daemon is running when running guix commands
#

# Run guix daemon
/root/.config/guix/current/bin/guix-daemon --build-users-group=guixbuild &
GUIX_DAEMON=$!

# Execute commands
exec "$@"
GUIX_RESULT=$?

# Kill guix daemon
kill -9 $GUIX_DAEMON

# Exit with guix status
exit $GUIX_RESULT
