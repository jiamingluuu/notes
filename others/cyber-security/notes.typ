#set text(size: 12pt)
#set heading(numbering: "1.")
#set page(numbering: "1")

#outline(indent: auto)
#pagebreak()
= Definitions
- Safety: for reasonable inputs, get reasonable outputs.
- Security: for unreasonable inputs, get reasonable outputs.

*Security Theatre*
- Threat: Possibility of damage,
- Countermeasure: Limits possibility or consequence of damage,
  - mitigates threats, disables attacks, removes/reduces vulnerabilities.
- Vulnerabilities: Weakness in the system,
  - enables threats.
- Attacks: Exploitation of vulnerabilities to realize a threat.

*CIA*
- (C) Confidentiality: Information is disclosed to legitimate users.
- (I) Integrity: Information is created or modified by legitimate users.
- (A) Availability: Information is accessible to legitimate users.
Notice that CIA can be conflicting to each other in some scenarios.

== Risk Analysis & Policy, Mechanisms and Assurance
Risk analysis and security policy
- Goal: Infer what can go wrong with the system.
- Outcome: A set of security goals.
- Principle: You never prevent threats, you lower the risk.
Mechanisms
- Goal: Define a strategy to realize the security goals.
- Outcome: Set of security mechanisms.
- Principle: Deploying security mechanisms has a cost.
Assurance
- Goal: Make sure that the security mechanisms realize the security goals.
- Outcome Methodology.
- Principle: Full assurance cannot be achieved.

== Risk analysis
Given

$ "Risk exposure" = "probability" times "impact" $

We can set up a risk table to list out all the possible risk with their 
risk exposure, and determine which risks to mitigate.

#pagebreak()
= Cryptography 
*Design Principles*
- Kerkoff Principle: The security of a crypto system must not rely on keeping the algorithm secret.
- Diffusion: Mixing-up symbols.
- Confusion: Replacing a symbol with another.
- Randomization: Repeated encryptions of the same text are different.


== Symmetric Cryptography
*Requirements*

We use the same key $k$ for encryption $E_k$ and decryption $D$:
- $D_k (E_k (m)) = m$ for every key $k$ and $E, D$.
- $E_k$ and $D_k$ are easy to compute.
- Given $c = E_k (m)$, it is hard to find the plaintext $m$.

*Attacks*
- *Exhaustive Search* (brute force)
- *Ciphertext only*: know one or several random ciphertext.
- *Known plaintext*: know one or several pairs of *random* plaintext and their corresponding ciphertext.
- *Chosen plaintext*: know one or several pairs of *chosen plaintext* and their corresponding ciphertext.
- *Chosen cipher text*: know one or several pairs of plaintext and their corresponding *chosen ciphertext*.

=== Stream Cipher
*XOR* cipher:
- Message and key are xor-ed together
$ E_k (m) = k xor m $
$ D_k (c) = k xor c $
However, this cipher is vulnerable to known-plaintext attack
$ k = (k xor m) xor m $

*Mauborgne Cipher* 
- Use the key $k$ as a seed for random number generator and xor with the message
$ E_k (m) = m xor "RNG"(k) $
Vulnerable to key re-use attack:
$
C_1 &= k xor m_1\
C_2 &= k xor m_2\
C_1 xor C_2 &= m_1 xor m_2
$

=== Block Cipher 
Ideal block cipher 
- Combines confusion and diffusion.
- Changing single bit in plaintext block or key results in changes to approximately half the ciphertext bits.

*DES* (Data Encryption Standard)

DES is broken in 1998 and 2006. And Nesting encryption process is not a valid counter-measure.
$ 2"DES"_(k_1, k_2) (m) = E_(k_2)(E_(k_1) (m)) $

To broke this paradigm we can brute for the result of $E_(k_1)(m)$ and $D_(k_2)(c)$, for every possible key pair $(k_1, k_2)$. Then match the valid key candidate. The effective key space only doubled, from 56 bits become 57 bits. 

However, triple DES is widely used 
$ 3"DES"_(k_1, k_2, k_3) (m) = E_(k_3) (D_(k_2) (E_(k_1) (m))), $
with effective key length 112 bits.

*AES* (Advanced Encryption Standard)

It has different encryption modes:
- ECB: electronic code book. Each plaintext block is encrypted independently with the key
  - Fast, easy to perform parallelization.
  - But same block is encrypted to same ciphertext (violates diffusion)
#figure(
  image("./img/ecb.png", width: 70%),
  caption: "AES ECB mode"
)
- CBC: cipher block chaining
  - Repeating plaintext blocks are not exposed in the ciphertext.
  - No parallelism.
#figure(
  image("./img/cbc.png", width: 70%),
  caption: "AES ECB mode"
)
- CFB: cipher feedback
- CTR: counter
  - High entropy and parallelism.
  - Vulnerable to key-reused attack 
#figure(
  image("./img/ctr.png", width: 70%),
  caption: "AES ECB mode"
)

#table(
  columns: 4,
  inset: 10pt,
  align: horizon,
  table.header(
    [Name], [Type], [Key size (bits)], [Speed (cycle/byte)],
  ),
  [RC4], [stream], [40-2048], [8],
  [ChaCha20], [stream], [128/256], [4],
  [DES], [block], [block: 64, key: 56], [50],
  [Rijndael], [block], [block: 128, key: 128192256], [18-20]
)

The trade-off between stream cipher and block cipher:
- stream cipher is fast but has low diffusion, whereas
- block cipher is slow but has high diffusion.

== Asymmetric Cryptography
*Function Requirements*
- $D_(K s) (D_(K p) (m)) = D_(K p) (D_(K s) (m)) = m$ for every key pair $(K p, K s)$.
  - Easy to generate the key pair.
  - Encryption and decryption are easy to compute.
- Hard to matching key $K s$ given $K p$
#table(
  columns: 4,
  inset: 10pt,
  align: horizon,
  table.header(
    [Name], [Speed (cycle/byte)], [Key size (bits)], [Effective key length (bits)]
  ),
  [RSA], [$10^6$], [1024], [80],
  [RSA], [$10^6$], [2048], [112],
  [RSA], [$10^6$], [3072], [128],
  [RSA], [$10^6$], [4096], [140],
  [RSA], [$10^6$], [15360], [224-256],
  [ECC], [$10^6$], [256], [128],
  [ECC], [$10^6$], [448], [224-256],
)

*Summary between symmetric and asymmetric cryptography*:
- Symmetric is fast but has key agreement. 
  - That is, parties is able to generate a secrete key even if an eavesdropper is listening to the communication channel. 
  - Often used to encrypt message 
- Asymmetric is slow but does not have key agreement.
  - Used for encrypt shared key or hash.
== Hash Functions
$ H(m) = x $
An ideal hash function satisfies:
- PR (Preimage Resistance): given $x$ it is hard to find $m$.
- PR2 (Second Preimage Resistance): given $H, m, x$ it is hard to find $m'$ such that 
$ H(m) = H(m') = x. $
- CR (Collision Resistance): given $H$, it is hard to find $m, m'$ such that 
$ H(m) = H(m') $

=== Security Issue 
Due to birthday paradox:

"There are 50% chance that 2 
people have the same birthday in 
a room of 23 people"

Therefore if given hash function of $n$-bits output, a collision can be found 
in around $2^(n/2)$ evaluations. Hence SHA-256 has 128 bits security.

*SHA-2*
#figure(
  image("./img/sha2.png", width: 70%),
  caption: "MD5, SHA-1, SHA-2"
)

*SHA-3*
#figure(
  image("./img/sha3.png", width: 70%),
  caption: "SHA-3"
)

=== Hash as MAC 
MAC stands for message authentication code, commonly used for key exchange, 
certificate... Given message $m$ and key $k$, people often sends a whole message
$ m parallel "MAC"_k (m) $ 
together. One variant is HMAC, which use a hash function on the message 
and the key. 
- But in practice, if the HMAC is badly designed, for instance, using SHA2 and let $"MAC"_k (m) = H(k parallel m)$, then Mallory can perform hash length extension attack on the message sent.
- Good HMAC example
$ 
&"HMAC"_k (m) = H(k parallel m parallel k)\
&"HMAC"_k (m) = H((k xor "opad") parallel H((k xor "ipad") parallel m)\
$

#pagebreak()
= Key Exchange Protocols
== Digital Signature 
MAC we have discussed provide a decent method of verification under the scenario of no prior trust is given to the connection. Whereas it is easy to be forged. To solve this issue, digital signature is introduced, where it is 
- commonly used in key exchange 

== Symmetric Protocols
Symmetric protocols utilize the advantage of symmetric cryptography to provide
communication with confidentiality and integrity. The protocol defines a
procedure of key exchange which ensures two parties are able to defend 
themselves from the attack of a malicious party during communication. Once the 
shared key $k$ is set up, they can communicate by:
- Encrypt and MAC (E&M)
$ "AE"_k (m) = E_k (m) parallel H_k (m) $
- MAC then Encrypt (MtE)
$ "AE"_k (m) = E_k (m parallel H_k (m)) $
- Encrypt then MAC (EtM)
$ "AE"_k (m) = E_k (m) parallel H_k (E_k (m)) $
#figure(
  image("./img/symmetric-protocol.png", width: 70%),
  caption: "Communication in symmetric protocol"
)
However, the primary issue with symmetric protocols is how to make an agreement
on the shared key used $K_(a b)$ used between to parties, say, Alice and Bob.

The naive way is for every connection in a network, a shared key is exchange 
physically using a secure channel. Therefore, $1/2 n(n-1)$ keys are required for
a network with $n$ nodes.

A better solution is purposed as a KDC (key distributed center) manages all the
keys used, with premisses:
- the key exchange channel between KDC and each party is secure,
- KDC is trusted.
Before, there were a vulnerable version of key exchange protocol
#figure(
  image("./img/vulnerable-kdc.png", width: 70%),
  caption: "Vulnerable KDC"
)
If the key $K_(a b)$ is compromised, then Mallory is able to perform replay 
attack.
#figure(
  image("./img/kdc-the-fix.png", width: 70%),
  caption: "Fixed KDC"
)
But the existence of KDC has drawbacks:
- it is a single point of failure,
- one cannot exchange key with another when zero knowledge.

To solve this, we have DH (Diffie-Hellman) protocol:
- Alice
  - generate $g, p$ as public key, where $g$ is small (2, 5, 7...) and $p$ is at least 2048 bits.
  - choose $a$, a 2048 bits private key
  - compute $"dhA" = g^a mod p$
  - send $p, "dhA", n_0$ to Bob
- Then Bob
  - choose $b$, another 2048 bits private key 
  - compute $"dhB" = g^b mod p$
  - send $"dhB", n_1$ back to Alice
- The session key $K$ is 
$ K = g^(a b) mod p  = (g^a mod p)^b mod p = (g^b mod p)^a mod p. $
#figure(
  image("./img/dh-with-auth.png", width: 70%),
  caption: "DH key exchange with authentication"
)

== Asymmetric Protocols
Asymmetric protocols are used in mutual authentication, where two parties want 
to engage in the communication and confirm the opposite site is the party they 
intended to talk to.
#figure(
  image("./img/vulnerable-asymmetric.png", width: 70%),
  caption: "Vulnerable key exchange asymmetric protocol"
)
However, this protocol is vulnerable to Man-in-the-Middle (MitM) attack:
- Alice greets to Mallory with ${N_A, A}_(K_(p m))$.
- Mallory receives Alice's greeting message.
- Mallory sends Alice's greeting message to Bob ${N_A, A}_(K_(p b))$.
- Bob replies Alice with his nonce ${N_A, N_B}_(K_(p a))$.
- Alice sends Mallory Bob's nonce ${N_B}_(K_(p m))$.
- Mallory sends the nonce to Bob ${N_B}_(K_(p b))$.
- Bob recognize Mallory as Alice.

The fix is simple, Bob adds his credentials when sending nonce to Alice
#figure(
  image("./img/fixed-asymmetric-protocol.png", width: 70%),
  caption: "Fix asymmetric protocol"
)
However, still, this key exchange protocol has KDC as a single point of failure.
A feasible alternative is to use DH key exchange, which is commonly seen in TLS
#figure(
  image("./img/tls1.2.png", width: 70%),
  caption: "TLS 1.2"
)
#figure(
  image("./img/tls1.3.png", width: 70%),
  caption: "TLS 1.3 with one-way authentication"
)
TLS 1.3 is better than 1.2 as it is:
- only have one round in the handshake
- faster (by using ECC)
- certificate is encrypted
- protocol has been formally proven 
Note: both 1.3 and 1.2 does *not* has security issue, they are still used in 
modern network protocols.
== Trust Models 
Trust models establish the authenticity of the binding between someone and its 
public key. We have:
- (Decentralized) Web of Trust 
  - The person trusted by your friend is trustworthy
- (Centralized) PKI - Public Key Infrastructure
  - Trust the certificates assigned by certificate authority (CA)
  - If one trust the upper CA, then all the subsequent and lower CA are trusted.

#pagebreak()
= Network Security
The possible attacks of an attacker contains:
- Scanning: survey the network and its hosts.
- Eavesdropping: read messages.
- Spoofing: forge illegitimate messages.
- DOS (Denial of Service): disrupt the communication.
== Network Layers and Vulnerabilities
#figure(
  image("./img/network-layer.png", width: 45%),
  caption: "Network Layers"
)
#box(
 columns(2, gutter: 11pt)[
#figure(
  image("./img/network-layering.png", width: 100%),
  caption: "Network Layers"
)
#colbreak()
#figure(
  image("./img/layer-details.png", width: 100%),
  caption: "Network Layers"
)
 ]
)

Each layer has their own role:
=== Link Layer
Responsible for the reliable transmission of data across a physical link.
- MAC (media access control) addressing: enable devices to identify the source and destination of frames on the local network.
- A host can be connect to several hosts or networks through multiple interfaces. The connection can either be 
  - point-to-point, connected to a single host, or
  - by bus link, connected to an entire network.

It is hard for a malicious party to attack in the point-to-point mode of
connection. Whereas for bus link (aka. LAN, local area network), the attack 
becomes much easier.

*Packet Sniffing*
- An attacker sets its network interface is _promiscuous mode_ to capture all traffic.

=== Network Layer
Determine the path used for transferring data package from the source to 
destination across multiple interconnected networks.

*ARP* (Address Resolution Protocol)
- Used between link and network layer.
- Map IP address to MAC address within a local network segment.
- *Attack*: ARP cache poisoning
  - An attacker can broadcast fake IP-MAC mappings to the other hosts on the network.

*IP* (Internet Protocol)
- Each message has the IP address of the issuer and recipient.
- Routers route packet based on their routing table and a default rout.
- *Attack*: IP Spoofing
  - Router do not validate the source.
  - Receiver cannot tell that the source ahs been spoofed.
  - So an attacker can generate rwo IP packets with custom IP source fields.

*ICMP* (Internet Control Message Protocol)
- Exchange information about the network.
  - *Attack*: Host Discovery
    - By default, hosts answer to ICMP echo request messages.
    - So an attacker can scan the entire network to find IP address of active hosts.
  - *Attack*: ICMP Ping Flood
    - An attacker can overwhelm a host by sending multiple ICMP echo requests.

=== Transport Layer
Providing end-to-end communication services for applications running on 
different hosts.
- Allows hosts to have multiple connections through ports.
- Allows messages to be fragmented in to small IP packets.
- Make sure that all packets are received.

*TCP* (Transmission Control Protocol)
- The sender divides data=stream into packets sequence number is attacked to every packet.
- The receiver checks for packet errors, re-assembles packets in correct order to recreate stream.
- ACK are sent when packets are well received and lost/corrupt packets are re-sent.
- *Attack*: Port scanning
  - Using the 3-way handshake, an attacker can scan for all open ports for a given host.
- *Attack*: TCP-syn flooding
  - Overwhelm a host by sending multiple TCP SYN requests.
- *Attack*: TCP Connection Reset
  - Each TCP connection has an associated state sequence number
  - An attacker can guess (or sniff) the current sequence number for an existing connection and send packet with reset flag, which will close the connection.
  
*UDP* (User Datagram Protocol)
- Connectionless transport-layer protocol.
- No ack, no flow control, no message continuation, no reliability guarantees.
- *Attack*: UDP flood
  - When a UDP packet is received on a non-opened port, the host replies with an ICMP Destination Unreachable
  - An attacker can send a large number of UDP packets to all ports of target host.

=== Application Layer
Enabling communication between applications running on different hosts.

*BPG* (Border Gateway Protocol)
- Each router has a routing table to IP messages, BGP is the protocol for establishing routes.
- *Attack* Route hijacking
  - An attacker can advertise fake routes.

*DNS* (Domain Name Server)
- Internet applications relies on canonical hostname rather than IP addresses
- DNS servers translates domain names into IP addresses.
- *Attack* DNS cache poisoning 
  - An attacker can advertise fake DNS information

*HTTP* (Hyper-Text Transfer Protocol)
- Governing the exchange of information between web clients and web servers.

  
== Countermeasures on Network Threats
=== TLS (Transport Layer Security)
HTTPS = HTTP + TLS (SSL)
- With TLS, a transport layer protection, the communication is prevent from all kinds of spoofing and eavesdropping.
  - Integrity is guaranteed: authentication handshake.
  - Confidentiality is guaranteed: end-to-end secure channel.
- *Attack*: SSL Stripping
  - Webpages can be delivered either with HTTPS or HTTP.
  - Browser can automatically switch between HTTP and HTTPS.
  - An attacker can perform MitM attack and remove the SSL protection.

=== Preventing Packet Sniffing
Ethernet 
  - Isolate Ethernet traffics (no straightforward packet sniffing)
  - Hub: broadcast all messages on all ports.
  - Switch: forward messages on specific port based on their MAC addresses.
Wireless network
  - Encrypt message before sending them over the air.

=== Preventing Spoofing
Preventing DNS spoofing 
- DNSSEC: DNS Security Extensions, provides authentication (but not encryption) between DNS servers.
  - not widely deployed 
- DNS over HTTPS: provides authentication and encryption between client/server and server/server 
  - pushed by Google and Mozilla

Preventing rout hijacking (BGP)
- Bogon Filtering: deny route advertised by hosts with spoofed addresses

=== Preventing DOS attacks 
Preventing TCP-syn flooding 
- TCP-syn cookie: prevents from maintaining a queue of half-opened TCP connections.

Preventing DOS and DDOS attacks in general 
- Network Ingress Filtering
  - Deny access to network traffic with spoofed DOS and DDOS.
  - Ensure that traffic is traceable to its correct source network.

=== Preventing Scanning Attacks 
Preventing host discovery and port-scanning 
- Host Discovery: ICMP can be disabled or reserved to hosts on the same network 
- Port Scanning: TCP connections can be rejected if a source attempts to initiate multiple connections on multiple ports simultaneously.
- However such countermeasures are impossible in practice because 
  - each host needs to have packet filtering capability across different hardware, OS, and versions,
  - the admin needs to have administrative privilege on every host to push the packet filtering policy
== Firewall
Defines a logical defense parameter and acts an access control between two networks.
- packet filtering based on IP address 
- inbound traffic from the Internet trying to get into the protected network 
- outbound traffic going the other way
There are two types of firewalls
- Stateless packet filtering, purely based on the IP address and the port 
- Stateful packet filtering, tracks the status of every connection (TCP 3 way handshake) 

*DMS* (DeMilitarized Zone) 
- isolates exposed public servers
#figure(
  image("./img/dmz.png", width: 70%),
  caption: "DMZ"
)
== Intrusion Detection 
How do we know when malicious party enters our network?
*IDS* (Instruction Detection Systems)
- Often operate in stealth mode, connected in the local network.
- There are two wats to build an IDS 
  - Signature-based IDS, have a pre-defined malicious message pattern
  - Heuristic-based IDS, builds a model of acceptable message exchange pattern (use machine learning).
- The IDS normally lookup the headers, packet contents (payload), the packet fragmentation.
- However, the main issue of IDS is that, if a nomad host is hacker, Mallory is able to use his/her machine to access the local network service and skirt supervision of IDS.

*IPS* (Intrusion Prevention System)
- IPS = IDS + Firewall
== VPN (Virtual Private Network)
Tunneling protocol
- Alice's message is encapsulated and sent to the VPN server.
- The VPN extract this traffic and send it to the destination 
- It provides anonymity (from the IP perspective) as no one knows Alice's IP address.

=== Tor (The Onion Router)
#figure(
  image("./img/tor.png", width: 70%),
  caption: "TOR"
)
In TOR, no one knows about Alice's IP and content at once.
- The content can be seen at the exit node, so whatever Alice does illegally on the Internet, the exit node might be blame for it.
- TOR prevents client being identified by using IP address. However, TOR does not prevent client being identified based on the application information.

#pagebreak()
= Human Authentication
- Identification is assigning a set of data to a person or an organization 
- Authentication is making a sage link between a subject and one or several of identities.
== Authentication Factors
In general, it can be classified into three types:
- Something that you know:
  - Password, PIN number, secrete questions ...
  - *Good as long as* the user remember the secrete and nobody can uncover or guess this secret.
  - *Gets compromised* when someone else knows this secret and is able to use it.
- Something that you have: 
  - IDs, physical key, mobile phone ...
  - *Good as long as* they are not lost and damaged
  - *Gets compromised* when someone can duplicate or fake them
- Something that you are or do (biometrics)
  - Fingerprint, voice recognition, face recognition
  - robustness depends on the precision of this measure 
  - *Good as long as* you act or look like the same and nobody can pretend the way you act.
  - *Gets compromised* when someone can nearly act like you.
The way of storing password can also lead vulnerabilities
- In clear: really bad
- Hashed: bad
  - one can use rainbow table to lookup the hash of commonly seen Password
- Salted Hash: better and easy to manage
  - on the client side, before the password is passed to the server, pad the password with a chunk of meaningless bytes.
- Encrypted (best but complex to manage) 
  - how to decrypt?

#pagebreak()
= System Security 
== Vulnerabilities
The security of OS often compromised when 
- is process is crashed
- a process can have an undesirable behavior
- legitimate user execute a malicious software
To find program vulnerabilities, we can 
- find a bug yourself and investigate
- take a look at CVE alerts (Common Vulnerabilities and Exposures)
#figure(
  image("./img/timeline-of-vulnerabilities.png", width: 70%),
  caption: "Timeline of Vulnerabilities"
)
== Attacks
*Stack overflow*



*TOCTOU* (Time Of Check to Time Of Use)
#figure(
  image("./img/toctou.png", width: 70%),
  caption: "TOCTOU"
)
== Countermeasures on System Threats
*Type-safe program*
- cannot access arbitrary memory addresses
- cannot corrupt their own memory 
- do not crash

For `C` program, we can set `FORTIFY_SOURCE` when compiling source code with 
`GCC`, which provides buffer overflow checks for unsafe `C` libraries.

*Canaries* 
- The compiler modifies every function's prologue and epilogue regions to place and check a value (canary) on the stack.
- When a buffer overflows, the canary is overwritten. The programs detects it before the function returns and an exception is raised.

*DEP/NX* (None Executable Stack) 
- The program marks important structures in memory as non-executable.
- The program generates an hardware-level exception if one is trying to execute those memory regions- This makes normal stack buffer overflows impossible.

*ASLR* (Address Space Layout Randomization)
- The OS randomize the location (random offset) where the standard libraries and other elements are stored in memory.
- Harder for the attacker to guess the address of a `lib-c` subroutine.

*PIC/PIE* (Position Independent Code/Executables)
- with PIC, code is compiled with relative addressing that are resolved dynamically when executed by calling a function to obtain the return value on stack.

*Sandbox* 
- A tightly-controlled set of resources for untrusted programs to run in.

== Defensive Programming
Adopting good programming practices
- Modularity 
  - Have separate modules for separate functionalities.
  - Easier to find security flows when components are independent.
- Encapsulation
  - Limit the interaction between the components.
  - Avoid wrong usage of the components.
- Information hiding 
  - Hide the implementation, but
  - this does not import security
- Check the inputs, even between components that belongs to the same application.
- Be fault tolerant by having a consistent policy to handle failure.
- Reuse known and widely used code by using design patterns and exiting libraries.

Use formal methods to generate a program 
- mathematical description of the problem 
- proof of correctness 
- executable code or hardware design

= Web Security 
A web application consists of 
- front-end, application running on client' side.
- back-end, application running on server's side.

Session 
- *Session ID* is an unique and unforgeable token
  - stored in cookie
  - bind to key/value paris data, which is stored on the server.
- User can create, modify, delete the session ID in the cookie.
- But cannot access the key/value pairs stored on the server.

Mixed-content happens when:
- an HTTPS page contains elements served with HTTP
- an HTTPS page transfers control to another HTTP page within the same domain 
  - credentials (authentication cookie) will be sent over HTTP.
  - modern browser block or warn mixed-content.

== Backend Vulnerabilities