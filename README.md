# Dovecot Antispam with Sieve and rspamd

Scripts and config to implement spam/ham learning via imap_sieve.

## What does it do?

1. Implement the imap_sieve rules as mention in the wiki link above
   and provide also the scripts to call rspamc.

   You need to set the password for rspamc in `/etc/dovecot/rspamd-controller.password`.

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

- dovecot config dir: `/etc/dovecot`
- all sieve files: `/usr/lib/dovecot/sieve/`
- all sieve pipe scripts: `/usr/lib/dovecot/sieve-pipe/`
- config assumes all mailboxes are child of `INBOX`; so `INBOX/Spam` is
  used for the spam folder.  All mailboxes named `Trash` or end in
  `/Trash` (including `INBOX/Trash`) are considered trash, i.e. moving
  mails from Spam to trash doesn't learn them as ham.

## How to install

1. make install

   For packagers we provide `DESTDIR` support and also an option to just
   install the files (make install-files) as compiling those sieve files
   requires the dovecot config being reloaded so all the settings are
   active.

2. set password in `/etc/dovecot/rspamd-controller.password`

3. Adapt `sieve_spamtest_max_value` in `99-antispam_with_sieve.conf`

4. Configure `extended_spam_headers = true` in
   `/etc/rspamd/local.d/milter_headers.conf` (unless you're using the
   `"X-Spam:"` header in `99-antispam_with_sieve.conf`)

## Configuration

1. Rspamd controller password for learning: write directly into
   `/etc/dovecot/rspamd-controller.password`

2. `sieve_spamtest_max_value` in `99-antispam_with_sieve.conf`: use the
   same score as you use for `"add header"` (or `add_header`) in rspamd.

   Or change to a different scoring system (see [Internals](#Internals)
   section below).

3. (Optional) `/etc/dovecot/rspamd-controller.conf.sh` can be used to
   customize the learning scripts (which will simply use the defauls if
   the config file is missing).

   `RSPAMD_CLASSIFIER=bayes_user` and `per_user` statistics should be
   used carefully (https://rspamd.com/doc/configuration/statistic.html):

   > However, you should ensure that Rspamd is called at the finally
   > delivery stage (e.g. LDA mode) to avoid multi-recipients messages.
   > In case of a multi-recipient message, Rspamd would just use the
   > first recipient for user-based statistics which might be
   > inappropriate for your configuration (however, Rspamd prefers SMTP
   > recipients over MIME ones and prioritize the special LDA header
   > called Delivered-To that can be appended by -d options for rspamc)

4. Instead of creating `INBOX/Spam` and sorting mail for all users, you
   can let your users opt-in: when you use `global-try-spam.sieve` as
   `sieve_before` script, it will only sort mails for a user if
   `INBOX/Spam` already exists.

# Further reading

- https://wiki.dovecot.org/HowTo/AntispamWithSieve
- https://wiki2.dovecot.org/Pigeonhole/Sieve/Extensions/SpamtestVirustest
- https://tools.ietf.org/html/rfc5235 (Sieve: Spamtest and Virustest Extensions)
- https://rspamd.com/doc/configuration/statistic.html
- https://rspamd.com/doc/modules/milter_headers.html

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

## rspamc password

Although not explained directly in the docs, the controller password can
(and should!) be passed through a file.

Reading the [`rspamc_password_callback`] source shows that if the passed
option starts with `.` or `/` it is interpreted as filename, and the
password is read from the file.

[`rspamc_password_callback`]: https://github.com/rspamd/rspamd/blob/f9d5c7051dba5f9acd97f160ea07981a264d64bf/src/client/rspamc.c#L340

## imap.user / $USER

To prevent users training other users' statistics, the learning script
use [`$USER`] to determine the imap user.  This should be same as
[`imap.user`] from the sieve environment.

This is sadly not documented.

[`imap.user`]: https://github.com/dovecot/pigeonhole/blob/43f5835b3830830cb84a04a5a06c7e6b15cc21df/src/plugins/imapsieve/ext-imapsieve-environment.c#L28
[`$USER`]: https://github.com/dovecot/pigeonhole/blob/43f5835b3830830cb84a04a5a06c7e6b15cc21df/src/plugins/sieve-extprograms/sieve-extprograms-common.c#L547

# Related bugs

- "rspamc learn fails for already learned messages": https://github.com/rspamd/rspamd/issues/2691

   The following messages in the log *may* be harmless (when learning a
   mail a second time):

    ```
    dovecot[...]: imap(...): program `/.../learn-spam.rspamd.script' terminated with non-zero exit code 1
    dovecot[...]: imap(...): Error: sieve: pipe action: failed to execute to program `learn-spam.rspamd.script': refer to server log for more information.   [YYYY-MM-DD HH:mm:ss]
    dovecot[...]: imap(...): Error: sieve: Execution of script /.../learn-spam.sieve failed
    ```

- *milter_headers: export add_header score*: https://github.com/rspamd/rspamd/issues/2699

   As noted above the rspamd max score exported by `milter_headers` is
   not a good scale to measure "100% spam" rating; exporting the `"add
   header"` score would provide a better measure.
