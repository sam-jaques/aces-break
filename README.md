This is a fork of the implementation of [ACES](https://github.com/remytuyeras/aces), to include a full message recovery attack.

The attack is in `break.sage`, which will generate an ACES instance, recover the evaluated secret key, and check that this correctly decrypts all encrytable messages.

A writeup of the ideas is in `aces-break.pdf`.

# Requirements
This requires `pyaces`, and was tested with Sage 9.0.