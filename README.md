This is a fork of the implementation of [ACES](https://github.com/remytuyeras/aces), to include a full message recovery attack.

The attack is in `message_recovery.sage`, which will generate an ACES instance and iterate through all possible messages (i.e., integers modulo the modulus), encrypt them, then check that the key recovery attack recovers the same message.

A writeup of the ideas is in `aces-break.pdf`.
