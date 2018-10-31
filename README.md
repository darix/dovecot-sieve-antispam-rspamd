# Dovecot Antispam with Sieve (and rspamd)

Scripts and config to implement spam/ham learning via imap_sieve

https://wiki.dovecot.org/HowTo/AntispamWithSieve

https://wiki2.dovecot.org/Pigeonhole/Sieve/Extensions/SpamtestVirustest

## What does it do?

1. Implement the imap_sieve rules as mention in the wiki link above
   and provide also the scripts to call rspamc.

   You need to set the password for rspamc in /etc/dovecot/rspamd-controller-password

   This means we can move mails into the spam folder to train them as spam,
   and out of the spam folder to train them as ham.

2. Configure spamtest extension. The included config defaults to the
   score based rspamd headers but examples are provided for other options.

3. Global rule using the spamtest extension to sort all mails that are 100% spam
   into the spam folder. The rational behind the global rule is that we want all
   all spam mails in the spam folder. If the user moves them out of there afterwards,
   we learn them as ham. Anything that wasn't detected as 100% spam yet will be trained
   as spam if we move mails in. so this supports the first point

## Default paths used

dovecot config dir: /etc/dovecot

all sieve files and scripts: /usr/lib/dovecot/sieve/

config assumes all mailboxes are child of INBOX so INBOX/Spam for the spam folder.

## How to install

1. make install

   For packagers we provide DESTDIR support and also an option to just install the files (make install-files)
   as compiling those sieve files requires the dovecot config being reloaded so all the settings are active.

2. set password in /etc/dovecot/rspamd-controller-password

