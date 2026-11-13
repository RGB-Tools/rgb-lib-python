"""Script to check the installed rgb-lib package loads and works."""

import rgb_lib


def main():
    """Load the native library and generate a set of keys."""
    keys = rgb_lib.generate_keys(
        rgb_lib.BitcoinNetwork.REGTEST,
        rgb_lib.WitnessVersion.TAPROOT,
    )
    if not keys.mnemonic:
        raise RuntimeError("generate_keys returned no mnemonic")
    print("native library loaded, keys generated")


if __name__ == "__main__":
    main()
