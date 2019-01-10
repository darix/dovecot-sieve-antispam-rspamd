require ["fileinto", "mailbox", "spamtest", "relational", "comparator-i;ascii-numeric"];

# don't create INBOX/Spam; only sort mail if it already exists
if mailboxexists "INBOX/Spam" {
  if spamtest :value "ge" :comparator "i;ascii-numeric" "10" {
    fileinto :create "INBOX/Spam";
    stop;
  }
}
