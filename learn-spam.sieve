require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags"];

addflag "\\Seen";
socket :copy "rspam-learn-spam";
