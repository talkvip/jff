<?php

// managesieve server port
$rcmail_config['managesieve_port'] = 4190;

// managesieve server address, default is localhost.
// Replacement variables supported in host name:
// %h - user's IMAP hostname
// %n - http hostname ($_SERVER['SERVER_NAME'])
// %d - domain (http hostname without the first part)
// For example %n = mail.domain.tld, %d = domain.tld
$rcmail_config['managesieve_host'] = '%h';

// authentication method. Can be CRAM-MD5, DIGEST-MD5, PLAIN, LOGIN, EXTERNAL
// or none. Optional, defaults to best method supported by server.
$rcmail_config['managesieve_auth_type'] = 'DIGEST-MD5';

// Optional managesieve authentication identifier to be used as authorization proxy.
// Authenticate as a different user but act on behalf of the logged in user.
// Works with PLAIN and DIGEST-MD5 auth.
$rcmail_config['managesieve_auth_cid'] = 'webmail';

// Optional managesieve authentication password to be used for imap_auth_cid
$rcmail_config['managesieve_auth_pw'] = '@@MANAGESIEVE_AUTH_PW@@';

// use or not TLS for managesieve server connection
// it's because I've problems with TLS and dovecot's managesieve plugin
// and it's not needed on localhost
$rcmail_config['managesieve_usetls'] = true;

// default contents of filters script (eg. default spam filter)
$rcmail_config['managesieve_default'] = '/etc/dovecot/sieve/default';

// Sieve RFC says that we should use UTF-8 endcoding for mailbox names,
// but some implementations does not covert UTF-8 to modified UTF-7.
// Defaults to UTF7-IMAP
$rcmail_config['managesieve_mbox_encoding'] = 'UTF-8';

// I need this because my dovecot (with listescape plugin) uses
// ':' delimiter, but creates folders with dot delimiter
$rcmail_config['managesieve_replace_delimiter'] = '';

// disabled sieve extensions (body, copy, date, editheader, encoded-character,
// envelope, environment, ereject, fileinto, ihave, imap4flags, index,
// mailbox, mboxmetadata, regex, reject, relational, servermetadata,
// spamtest, spamtestplus, subaddress, vacation, variables, virustest, etc.
// Note: not all extensions are implemented
$rcmail_config['managesieve_disabled_extensions'] = array();

// Enables debugging of conversation with sieve server. Logs it into <log_dir>/sieve
$rcmail_config['managesieve_debug'] = false;

