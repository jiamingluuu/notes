#set text(size: 13pt)
#set heading(numbering: "1.")

#outline(indent: auto)
= Definitions
- Safety: for reasonable inputs, get reasonable outputs.
- Security: for unreasonable inputs, get reasonable outputs.

== Security Theatre
- Threat: Possibility of damage,
- Countermeasure: Limits possibility or consequence of damage,
  - mitigates threats, disables attacks, removes/reduces vulnerabilities.
- Vulnerabilities: Weakness in the system,
  - enables threats.
- Attacks: Exploitation of vulnerabilities to realize a threat.

== CIA 
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
  image("./img/ecb.png", width: 100%),
  caption: "AES ECB mode"
)
- CBC: cipher block chaining
  - Repeating plaintext blocks are not exposed in the ciphertext.
  - No parallelism.
#figure(
  image("./img/cbc.png", width: 100%),
  caption: "AES ECB mode"
)
- CFB: cipher feedback
- CTR: counter
  - High entropy and parallelism.
  - Vulnerable to key-reused attack 
#figure(
  image("./img/ctr.png", width: 100%),
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
- PR2 (Second Preimage Resistance): given $H, m, x$ it is hard to find $m'$ such that $H(m) = H(m') = x$.
- CR (Collision Resistance): given $H$, it is hard to find $m, m'$ such that $H(m) = H(m')$.

=== Security Issue 
Due to birthday paradox:

"There are 50% chance that 2 
people have the same birthday in 
a room of 23 people"

Therefore if given hash function of $n$-bits output, a collision can be found 
in around $2^(n/2)$ evaluations. Hence SHA-256 has 128 bits security.

*SHA-2*
#figure(
  image("./img/sha2.png", width: 100%),
  caption: "MD5, SHA-1, SHA-2"
)

*SHA-3*
#figure(
  image("./img/sha3.png", width: 100%),
  caption: "SHA-3"
)

=== Hash as MAC 
MAC stands for message authentication code, commonly used for key exchange, 
certificate... Given message $m$ and key $k$, people often sends a whole message
$ m parallel "MAC"_k (m) $ 
together. One variant is HMAC, which use a hash function on the message 
and the key. 
- But in practice, if the HMAC is badly designed, for instance, using SHA2 and let $"MAC"_k (m) = H(k parallel m)$, then mallory can perform hash length extension attack on the message sent.
- Good HMAC example
$ 
&"HMAC"_k (m) = H(k parallel m parallel k)\
&"HMAC"_k (m) = H((k xor "opad") parallel H((k xor "ipad") parallel m)\
$