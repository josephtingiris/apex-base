The /base working directory structure, which relates to revision control systems, is modeled after the Filesystem Hierarchy Standard 3.0

See: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

It is extended at the root to include the following additional structures

    /base/srv/[account]
    /base/machine/[*|hostgroup|hostname]

# /base/
Follow FHS 3.0, each sub-directory MAY contain standard sub-directories.
Each and every sub-directory of /base/ MAY contain a file called "README" or "README.md" (to denote information about the contents of the directory, notes, etc)
MAY contain /base/srv/
MAY contain /base/machine/
MUST NOT contain any other non-standard sub-directories.
/base/srv/
Follow FHS 3.0, each sub-directory MAY contain standard sub-directories.
MAY contain /base/srv/[account] sub-directories.
MUST NOT contain any other non-standard sub-directories.
/base/srv/[account]
Follow FHS 3.0, each sub-directory MAY contain standard sub-directories.
MAY contain /base/srv/[account]/[domain] directories
MUST NOT contain any other non-standard sub-directories.
/base/srv/[account]/[domain]
Follow FHS 3.0, each sub-directory MAY contain standard sub-directories.
MAY contain /base/srv/[account]/[domain]/[sub-domain] directories
MUST NOT contain any other non-standard sub-directories.
/base/srv/[account]/[domain]/[sub-domain]
Follow FHS 3.0, each sub-directory MAY contain standard sub-directories.
MAY contain /base/srv/[account]/[domain]/html directories (to denote httpd document root accessible files)
MAY contain /base/srv/[account]/[domain]/httpd.conf.d file(s) (to denote httpd document root configuration)
MUST NOT contain any other non-standard sub-directories.
/base/srv/[account]/[domain]/[sub-domain/]html
Contains apache read/write files
MUST NOT contain sensitive information that should not be visible
