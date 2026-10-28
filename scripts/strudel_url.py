#!/usr/bin/env python3
# dj-hermes Strudel share-link encoder.
#
# The long strudel.cc share URL is base64(code), percent-encoded into the
# URL fragment (verified against strudel.cc's own shareCode() util and the
# official embed docs). This lets an agent hand back a playable link
# without ever opening a browser:
#
#   python3 strudel_url.py encode path/to/beat.strudel.cc   # file or literal code
#   python3 strudel_url.py decode 'https://strudel.cc/#...'
#
# See skills/dj-hermes/references/strudel-vs-maelstrom.md for the full
# maelstrom-vs-Strudel API translation the encoded code must respect.


def code2hash(code: str) -> str:
    import base64
    import urllib.parse
    b64 = base64.b64encode(code.encode("utf-8")).decode("ascii")
    return urllib.parse.quote(b64, safe="")


def hash2code(fragment: str) -> str:
    import base64
    import urllib.parse
    fragment = fragment.split("#", 1)[1] if "#" in fragment else fragment
    return base64.b64decode(urllib.parse.unquote(fragment)).decode("utf-8")


def main():
    import argparse
    import os

    p = argparse.ArgumentParser(description="Encode/decode strudel.cc share URLs")
    p.add_argument("mode", choices=["encode", "decode"])
    p.add_argument("source", help="code or .strudel.cc file (encode) | URL or fragment (decode)")
    args = p.parse_args()

    if args.mode == "encode":
        src = args.source
        if src.endswith(".cc") and os.path.isfile(src):
            with open(src) as f:
                src = f.read()
        print(f"https://strudel.cc/#{code2hash(src)}")
    else:
        print(hash2code(args.source))


if __name__ == "__main__":
    main()
