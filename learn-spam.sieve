require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags"];

if environment :matches "imap.user" "*" {
  set "username" "${1}";
}

addflag "\\Seen";
pipe :copy "learn-spam.script" [ "${username}" ];
