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

3. Adapt `sieve_spamtest_max_value` in `99-antispam_with_sieve.conf` or
   change to a different `sieve_spamtest_status_type`.

4. Configure `extended_spam_headers = true` in
   `/etc/rspamd/local.d/milter_headers.conf` (unless you're using the
   `"X-Spam:"` header in `99-antispam_with_sieve.conf`)

# Internals

## rspamd max score

The "max" score reported by rspamd is the "required" score, which is
calculated by [`rspamd_task_get_required_score`] as the first configured
rate of [`reject`, `soft reject`, `rewrite subject`, `add header`,
`greylist`, `noaction`][`enum rspamd_action_type`].

So if you configured `reject = 15`, then your max score is `15`.  If you
didn't configure `reject`, `soft reject` and `rewrite subject`, but
`"add header" = 10`, then your max score is `10`.

## sieve spamtest score

spamtest calculates a spam score; normally in the range `0...10`, or
`0...100` as `spamtest :percent` with the `spamtestplus` extension
(dovecot uses a float `0...1` internally).

When using a `score` based configuration, this score depends on a "max"
score.  The `99-antispam_with_sieve.conf` example file uses a fixed
`sieve_spamtest_max_value` value (which you should change to the same
value you use for `"add header"` in rspamd.)

You can also parse the rspamd max score (see above) from the
`"X-Spamd-Result:"` header. Let's say you consider mail with `rspamd
score >= 10` spam, but use `reject = 15` - i.e. only reject mails you're
really really sure are spam - then you'd want to move mails with a score
`>= 7` (`>= 67%`) into a spam folder; you need to adapt
`global-spam.sieve` accordingly.

You could also use the `"X-Spamd: [Yes|No]"` header provided by the
`"add header" = ...` action (modify `99-antispam_with_sieve.conf`
accordingly); this maps certain header values to fixed spamtest values
(range `0...10`; if it can't find a value it defaults to `0`).

[`rspamd_task_get_required_score`]: https://github.com/rspamd/rspamd/blob/f9d5c7051dba5f9acd97f160ea07981a264d64bf/src/libserver/task.c#L1537
[`enum rspamd_action_type`]: https://github.com/rspamd/rspamd/blob/f9d5c7051dba5f9acd97f160ea07981a264d64bf/src/client/rspamc.c#L167

# Related bugs

- *milter_headers: export add_header score*: https://github.com/rspamd/rspamd/issues/2699

   As noted above the rspamd max score exported by `milter_headers` is
   not a good scale to measure "100% spam" rating; exporting the `"add
   header"` score would provide a better measure.
