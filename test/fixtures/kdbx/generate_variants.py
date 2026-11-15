"""Rewrap the public AES fixture as a synthetic ChaCha20 recycle-bin fixture.

Requires Python cryptography 50.0.2. The fixed key material and nonce are for
public test data only; never use this script to protect real credentials.
"""

import gzip
import hmac
import struct
import xml.etree.ElementTree as ET
from hashlib import sha256, sha512
from pathlib import Path

from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

FIXTURES = Path(__file__).resolve().parent
CHACHA_ID = bytes.fromhex('d6038a2b8b6f4cb5a524339a31dbb59a')
TEST_NONCE = bytes.fromhex('000102030405060708090a0b')


def uint32(value):
    return struct.pack('<I', value)


def data_block(index, data, hmac_base):
    block_id = struct.pack('<Q', index)
    size = uint32(len(data))
    block_key = sha512(block_id + hmac_base).digest()
    tag = hmac.digest(block_key, block_id + size + data, 'sha256')
    return tag + size + data


def read_source_header(source):
    offset = 12
    fields = {}
    while True:
        field_id = source[offset]
        size = int.from_bytes(source[offset + 1:offset + 5], 'little')
        offset += 5
        fields[field_id] = source[offset:offset + size]
        offset += size
        if field_id == 0:
            return fields, offset


def read_kdf_parameters(encoded):
    offset = 2
    parameters = {}
    while encoded[offset] != 0:
        name_length = int.from_bytes(encoded[offset + 1:offset + 5], 'little')
        name = encoded[offset + 5:offset + 5 + name_length].decode()
        offset += 5 + name_length
        length = int.from_bytes(encoded[offset:offset + 4], 'little')
        parameters[name] = encoded[offset + 4:offset + 4 + length]
        offset += 4 + length
    return parameters


def read_source_payload(source, fields, header_end):
    parameters = read_kdf_parameters(fields[11])
    composite = sha256(sha256(b'test').digest()).digest()
    transform = Cipher(algorithms.AES(parameters['S']), modes.ECB()).encryptor()
    for _ in range(int.from_bytes(parameters['R'], 'little')):
        composite = transform.update(composite)
    transformed = sha256(composite).digest()
    seed = fields[4]
    master_key = sha256(seed + transformed).digest()
    hmac_base = sha512(seed + transformed + b'\x01').digest()
    header_key = sha512(b'\xff' * 8 + hmac_base).digest()
    header = source[:header_end]
    assert sha256(header).digest() == source[header_end:header_end + 32]
    assert hmac.digest(header_key, header, 'sha256') == source[header_end + 32:header_end + 64]

    offset = header_end + 64
    index = 0
    ciphertext = bytearray()
    while True:
        size = int.from_bytes(source[offset + 32:offset + 36], 'little')
        block = source[offset + 36:offset + 36 + size]
        framed = data_block(index, block, hmac_base)
        assert source[offset:offset + len(framed)] == framed
        offset += len(framed)
        index += 1
        if size == 0:
            break
        ciphertext.extend(block)
    assert offset == len(source)

    decryptor = Cipher(algorithms.AES(master_key), modes.CBC(fields[7])).decryptor()
    padded = decryptor.update(bytes(ciphertext)) + decryptor.finalize()
    unpadder = padding.PKCS7(128).unpadder()
    payload = gzip.decompress(unpadder.update(padded) + unpadder.finalize())
    return payload, master_key, hmac_base, header_key


def add_recycled_entry(payload):
    # Preserve the inner header and all protected values from the source.
    offset = 0
    while True:
        field_id = payload[offset]
        size = int.from_bytes(payload[offset + 1:offset + 5], 'little')
        offset += 5 + size
        if field_id == 0:
            break
    document = ET.fromstring(payload[offset:])
    group = document.find('./Root/Group')
    metadata = document.find('./Meta')
    recycle_uuid = metadata.find('RecycleBinUUID')
    if recycle_uuid is None:
        recycle_uuid = ET.SubElement(metadata, 'RecycleBinUUID')
    recycle_uuid.text = 'AQEBAQEBAQEBAQEBAQEBAQ=='
    recycled_group = ET.SubElement(group, 'Group')
    ET.SubElement(recycled_group, 'UUID').text = recycle_uuid.text
    ET.SubElement(recycled_group, 'Name').text = 'Deleted'
    entry = ET.SubElement(recycled_group, 'Entry')
    field = ET.SubElement(entry, 'String')
    ET.SubElement(field, 'Key').text = 'otp'
    ET.SubElement(field, 'Value').text = (
        'otpauth://totp/Deleted:recycled?secret=JBSWY3DPEHPK3PXP&issuer=Deleted'
    )
    return payload[:offset] + ET.tostring(document, encoding='utf-8', xml_declaration=True)


def main():
    source = (FIXTURES / 'aes.kdbx').read_bytes()
    fields, header_end = read_source_header(source)
    payload, master_key, hmac_base, header_key = read_source_payload(source, fields, header_end)
    assert fields[7] != TEST_NONCE
    fields[2] = CHACHA_ID
    fields[7] = TEST_NONCE
    header = source[:12] + b''.join(
        bytes([field_id]) + uint32(len(value)) + value
        for field_id, value in fields.items()
    )
    encryptor = Cipher(
        algorithms.ChaCha20(master_key, bytes(4) + TEST_NONCE), mode=None
    ).encryptor()
    compressed = gzip.compress(add_recycled_entry(payload), mtime=0)
    ciphertext = encryptor.update(compressed) + encryptor.finalize()
    result = (
        header
        + sha256(header).digest()
        + hmac.digest(header_key, header, 'sha256')
        + data_block(0, ciphertext, hmac_base)
        + data_block(1, b'', hmac_base)
    )
    (FIXTURES / 'recycle_aes_kdf.kdbx').write_bytes(result)


if __name__ == '__main__':
    main()
