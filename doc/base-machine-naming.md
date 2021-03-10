All machines have requirements for host, interface, and domain names.

This is the host, interface, & domain name standard.

### LOCALITY[-ACCOUNT-][dev/qa/prod/stg/test]SERVICE#[-][INTERFACE] # max 63 chars

* **LOCALITY-**                       = 0-6 chars [must have trailing dash '-']
* **[ACCOUNT-]**                      = 0-4 chars [must have trailing dash '-']
* **[dev/qa/prod/rep/stg/test]**      = 0-4 chars, required for non-production
* **SERVICE**                         = 2-32 chars, required (must be one of the supported host_environments)
* **[#]**                             = 0-4 chars
* **[-INTERFACE]**                    = 0-15 chars
* **[.DOMAIN]**                       = subject to change

_These are constraints that should be acknowledged._

* All parts of a name must be lowercase.
* Everything within brackets [] is optional.
* LOCALITY must start with an alphabet character (a-z).
* When possible LOCALITY should prefer airport abbreviations (e.g. atl)
* All non-production machines MUST have one of the environments prefixed to their SERVICE, so people can code algorithms that automatically adapt code to specific environments.

* If an environment is prefixed to the SERVICE then it must be one of the following:
    * dev   = Development
    * qa    = Quality Assurance
    * prod  = Production
    * rep   = Replication
    * stg   = Staging
    * test  = Test

* Omitting [-ACCOUNT-] would explicitly mean that it's a machine that services multiple accounts.
* For most machines, [-ACCOUNT-] is needed for security & inventory purposes, to know who the machine(s) are dedicated to.
* Omitting [-][INTERFACE] implies it's the (short) hostname (aka machine name).

* The complete name MUST NOT contain any of the following characters.
    * backslash (\)
    * slash mark (/)
    * colon (:)
    * asterisk (*)
    * question mark (?)
    * quotation mark (")
    * less than sign (<)
    * greater than sign (>)
    * vertical bar (|)

**_A)_** _HOST_, or machine names must be 63 characters or less. Having the LOCALITY (e.g. atl) in the name makes administration easier and more intuitive. Specifying a SERVICE like 'prod' isn't really necessary, but having it as part of the name will not explicitly violate the above semantics (as long as the whole name is 63 characters or less). Simply not having 'dev', 'qa', 'stg', or 'test' in the name is sufficient to denote a production machine (or a machine that services a SERVICE for all environments).

_CAVEAT: Windows machines prior to Windows 2012 must be 15 characters or less._

Here are some valid HOST name examples,

* atl-vpn

* atl-mit-core01
* atl-mit-cnc01
* atl-mit-devcnc01
* atl-mit-qacnc01
* atl-mit-stgcnc01

**_B)_** _INTERFACE_ names can be any length, as long as the complete name is less than 63 characters. These names are primarily used by multi-homed hosts, for DNS & DHCP.

_NOTE: For DHCP 'host' (interface) definitions that are fixed, a MAC address is required and the definition statement in the dhcpd.fixed.conf must have a unique name. The name can not be the MAC address. It makes the most sense to use the host name, but because many hosts have multiple interfaces another identifier is needed or conflicts will result. In this case, what should be done is append [-INTERFACE] to the host name._

Here are some INTERFACE name examples,

* atl-mit-cnc01-eno1
* atl-cnc01-bond0
* atl-cnc01-bond0-0

* atl-mit-win-lac1 (Windows Ethernet Local Area Connection 0 [1,2,3,etc])

