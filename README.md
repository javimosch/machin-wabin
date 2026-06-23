# machin-wabin

The **WhatsApp binary-node (stanza) codec** implemented in **[machin](https://github.com/javimosch/machin)** (MFL). WhatsApp frames its XMPP-like stanzas in a compact binary format with a token dictionary; this encodes and decodes that wire format — entirely on machin's `bytes` type, with **no new builtins**.

Part of [**awesome-machin**](https://github.com/javimosch/awesome-machin) — the machin ecosystem.

## Why it exists (dogfooding)

This is the **framing layer** of a native WhatsApp client in machin (the transport handshake is [machin-noise](https://github.com/javimosch/machin-noise); the message encoding is [machin-protobuf](https://github.com/javimosch/machin-protobuf)). It implements, faithfully:

- the **token dictionaries** (single-byte + 4 double-byte, `DictVersion 3`) — lifted verbatim from [tulir/whatsmeow](https://github.com/tulir/whatsmeow)'s `binary/token` into [`tokens.src`](tokens.src);
- **string compression** — single/double-byte tokens, nibble-packing (numeric), hex-packing, and length-delimited raw binary (`Binary8`/`Binary20`/`Binary32`);
- the **node tree** — `List8`/`List16` framing, tag + attributes + content, JID pairs.

It exists to prove machin's `bytes` surface is enough to implement a real, fiddly binary protocol — and the encoder's output is **byte-for-byte WhatsApp-compatible**, not merely self-consistent.

## Build & run

Needs the [machin](https://github.com/javimosch/machin) compiler (v0.34.0+) on `PATH` and a C compiler.

```bash
./build.sh                 # → ./machin-wabin
./machin-wabin             # encode→decode round-trip self-test
./machin-wabin <hex>       # decode a stanza and print it
```

```
$ machin-wabin
encoded stanza (14 bytes): f8061911030429f801f80356162b

decoded:
<iq to="s.whatsapp.net" type="get">
  <ping xmlns="urn:xmpp:ping"/>
</iq>

$ machin-wabin f8061911030429f801f80356162b
<iq to="s.whatsapp.net" type="get">
  <ping xmlns="urn:xmpp:ping"/>
</iq>
```

Those 14 bytes are exactly what WhatsApp sends — `0x19`=`iq`, `0x11`=`to`, `0x03`=`s.whatsapp.net`, `0x04`=`type`, `0x29`=`get`, … straight from the real token table.

## Verified

- The example stanza's bytes match **whatsmeow's actual token indices** (not just an internal round-trip).
- Every string path round-trips: single token, double token, nibble-packed (`1234567`), hex-packed (`AB12`), raw binary (`Hi there!`), and nested nodes with content.

## Status & limits

Covers what a client needs to read/write ordinary stanzas. Not yet: the companion/AD-JID and FB/interop JID variants (shown as `?<tag>`), and binary content blobs are rendered via the string path (fine for text, lossy for media bytes — decode those with the lower-level readers). The full client still needs the Signal/Double-Ratchet session layer and device pairing on top of this + machin-noise + machin-protobuf. (Heads-up: unofficial WhatsApp clients can get a number banned.)

## Layout

```
machin-wabin/
├── tokens.src    # token dictionaries (auto-generated from whatsmeow; do not hand-edit)
├── wabin.src     # the codec (encode/decode/inspect) + round-trip self-test
├── build.sh
└── README.md
```
