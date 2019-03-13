require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags"];

addflag "\\Seen";
socket :copy "rspamd-learn-spam";
