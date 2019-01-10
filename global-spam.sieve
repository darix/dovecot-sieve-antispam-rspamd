require ["fileinto", "mailbox", "spamtest", "relational", "comparator-i;ascii-numeric"];

if spamtest :value "ge" :comparator "i;ascii-numeric" "10" {
  fileinto :create "INBOX/Spam";
  stop;
}
