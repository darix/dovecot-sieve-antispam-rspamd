dovecot_config_dir=/etc/dovecot
sieve_pipe_bin_dir=/usr/lib/dovecot/sieve/

install: install-files compile-sieve

install-files:
	install -D -m 0644 99-antispam_with_sieve.conf  $(DESTDIR)$(dovecot_config_dir)/conf.d/99-antispam_with_sieve.conf
	install -D -m 0644 learn-ham.sieve              $(DESTDIR)$(sieve_pipe_bin_dir)/learn-ham.sieve
	install -D -m 0644 learn-spam.sieve             $(DESTDIR)$(sieve_pipe_bin_dir)/learn-spam.sieve
	install -D -m 0644 global-spam.sieve            $(DESTDIR)$(sieve_pipe_bin_dir)/global-spam.sieve
	install -D -m 0644 global-try-spam.sieve        $(DESTDIR)$(sieve_pipe_bin_dir)/global-try-spam.sieve
	install -D -m 0755 learn-ham.rspamd.script      $(DESTDIR)$(sieve_pipe_bin_dir)/learn-ham.rspamd.script
	install -D -m 0755 learn-spam.rspamd.script     $(DESTDIR)$(sieve_pipe_bin_dir)/learn-spam.rspamd.script
	install -D -m 0644 rspamd-controller.conf.sh    $(DESTDIR)$(dovecot_config_dir)/rspamd-controller.conf.sh

compile-sieve:
	doveadm reload
	sievec $(DESTDIR)$(sieve_pipe_bin_dir)/learn-ham.sieve
	sievec $(DESTDIR)$(sieve_pipe_bin_dir)/learn-spam.sieve
	sievec $(DESTDIR)$(sieve_pipe_bin_dir)/global-spam.sieve
	sievec $(DESTDIR)$(sieve_pipe_bin_dir)/global-try-spam.sieve
