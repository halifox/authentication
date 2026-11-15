Public synthetic test databases from a GPL-3.0 converter test suite. The test
password is `test`; no real account credentials are included.
Source: https://github.com/stratumauth/app/tree/86c4e7c520ce30a21fa2887f1ae484442f06225d/Stratum.Test/data

`recycle_aes_kdf.kdbx` is derived from the public `aes.kdbx` fixture using
`generate_variants.py` and Python cryptography 50.0.2. The script independently
authenticates and decrypts the source, adds a synthetic OTP in the recycle
group, then re-encrypts the payload with ChaCha20 and AES-KDF. Its fixed nonce
is for this public test fixture only. The original `chacha.kdbx` and
`recycle.kdbx` use 117 Argon2d iterations and are retained to test rejection
above the supported limit.
