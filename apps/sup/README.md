WIP:

# sup #

Sup is a tool to send computing support requests via the command line.

## Usage. ##

Usage: sup [OPTIONS] "title" "message"

    	-h, --help                       Display this screen.

	General

    	-u, --user USERNAME              The username to use when sending the report. Defaults to the username of the current login.
    	-m, --machine MACHINE            The machine which you are reporting a problem with. Defaults to the current machine name, if available.

	Additional

	    -e, --email EMAIL                An alternative email address for the support request. If not specified, Computing Support will use USERNAME@sms.ed.ac.uk
	    -s, --serious                    Marks the request as urgently requiring attention.

