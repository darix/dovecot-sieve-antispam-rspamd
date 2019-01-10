# Path to file containing the controller password
# (Or, if it doesn't start with '/' or '.', the password itself.
# But it might leak the password through ps to other users)
RSPAMD_CONTROLLER_PASSWORD=/etc/dovecot/rspamd-controller.password
# passed to rspamc with the -h option (host and port)
RSPAMD_CONTROLLER_SOCKET=
# if set uses curl instead of rspamc; should start with http: or https:
RSPAMD_CONTROLLER_HOST=
# classifier to learn for (default by rspamc: bayes), e.g. `bayes_user`
RSPAMD_CLASSIFIER=
