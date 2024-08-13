# Definitions
- Safety: for reasonable inputs, get reasonable outputs.
- Security: for unreasonable inputs, get reasonable outputs.

## Security Theatre
- Threat: Possibility of damage,
- Countermeasure: Limits possibility or consequence of damage,
  - mitigates threats, disables attacks, removes/reduces vulnerabilities.
- Vulnerabilities: Weakness in the system,
  - enables threats.
- Attacks: Exploitation of vulnerabilities to realize a threat.

## CIA 
- (C) Confidentiality: Information is disclosed to legitimate users.
- (I) Integrity: Information is created or modified by legitimate users.
- (A) Information is accessible to legitimate users.
Notice that CIA can be conflicting to each other in some scenarios.

## Risk Analysis & Policy, Mechanisms and Assurance
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

## Risk analysis
Given

Risk exposure = probability * impact

We can set up a risk table to list out all the possible risk with their 
risk exposure, and determine which risks to mitigate.

