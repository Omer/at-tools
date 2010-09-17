# sup #

Sup is a tool to send computing support requests via the terminal.

## Usage. ##

Sup is primarly designed to take input from within the program, not from terminal flags, but the latter are accepted by the program as laid out below.
If flags are used, their values will be set as the default values for the appropriate fields.

    Usage: sup [OPTIONS] [SUBJECT] [MESSAGE]

      	-h, --help                       Display this screen.

	General

    	-u, --user USERNAME              The username to use when sending the report. Defaults to the username of the current login.
    	-m, --machine MACHINE            The machine which you are reporting a problem with. Defaults to the current machine name, if available.

	Additional

	    -e, --email EMAIL                An alternative email address for the support request. If not specified, Computing Support will use USERNAME@sms.ed.ac.uk
	    -s, --serious                    Marks the request as urgently requiring attention.
