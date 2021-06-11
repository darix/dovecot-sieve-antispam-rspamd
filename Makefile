JUNK_FOLDER=INBOX/Spam
GLOBAL_SIEVE_SCRIPT=global-spam.sieve

dovecot_config_dir=/etc/dovecot
sieve_dir=/usr/lib/dovecot/sieve
sieve_pipe_dir=/usr/lib/dovecot/sieve-pipe

install: install-files compile-sieve

build:
	sed -e 's|@JUNK_FOLDER@|$(JUNK_FOLDER)|g; s|@GLOBAL_SIEVE_SCRIPT@|$(GLOBAL_SIEVE_SCRIPT)|g' < 99-antispam_with_sieve.conf.in > 99-antispam_with_sieve.conf
	sed -e 's|@JUNK_FOLDER@|$(JUNK_FOLDER)|g; s|@GLOBAL_SIEVE_SCRIPT@|$(GLOBAL_SIEVE_SCRIPT)|g' < global-spam.sieve.in > global-spam.sieve
	sed -e 's|@JUNK_FOLDER@|$(JUNK_FOLDER)|g; s|@GLOBAL_SIEVE_SCRIPT@|$(GLOBAL_SIEVE_SCRIPT)|g' < global-try-spam.sieve.in > global-try-spam.sieve

install-files: build
	install -D -m 0644 99-antispam_with_sieve.conf  $(DESTDIR)$(dovecot_config_dir)/conf.d/99-antispam_with_sieve.conf
	install -D -m 0644 learn-ham.sieve              $(DESTDIR)$(sieve_dir)/learn-ham.sieve
	install -D -m 0644 learn-spam.sieve             $(DESTDIR)$(sieve_dir)/learn-spam.sieve
	install -D -m 0644 global-spam.sieve            $(DESTDIR)$(sieve_dir)/global-spam.sieve
	install -D -m 0644 global-try-spam.sieve        $(DESTDIR)$(sieve_dir)/global-try-spam.sieve
	install -D -m 0755 learn-ham.rspamd.script      $(DESTDIR)$(sieve_pipe_dir)/learn-ham.rspamd.script
	install -D -m 0755 learn-spam.rspamd.script     $(DESTDIR)$(sieve_pipe_dir)/learn-spam.rspamd.script
	install -D -m 0644 rspamd-controller.conf.sh    $(DESTDIR)$(dovecot_config_dir)/rspamd-controller.conf.sh

compile-sieve:
	doveadm reload
	sievec $(DESTDIR)$(sieve_dir)/learn-ham.sieve
	sievec $(DESTDIR)$(sieve_dir)/learn-spam.sieve
	sievec $(DESTDIR)$(sieve_dir)/global-spam.sieve
	sievec $(DESTDIR)$(sieve_dir)/global-try-spam.sieve
