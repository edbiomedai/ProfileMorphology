from argparse import ArgumentParser, Namespace

from PIL import Image
from scematk.deconvolve import NativeSKImageStainDeconvolver
from scematk.io import read_zarr_ubimg
from scematk.process.contrast import LinearContrast


def get_cli_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument("--zarr-path", type=str)
    parser.add_argument("--json-path", type=str)
    parser.add_argument("--zarr-out", type=str)
    parser.add_argument("--json-out", type=str)
    parser.add_argument("--thumb-out", type=str)
    return parser.parse_args()


def main() -> None:
    args = get_cli_args()
    image = read_zarr_ubimg(args.zarr_path, args.json_path)
    nskid = NativeSKImageStainDeconvolver()
    deconv_image = nskid.run(image)
    deconv_image.save(args.zarr_out, args.json_out)
    deconv_image = read_zarr_ubimg(
        args.zarr_out, args.json_out, channel_names=["stain1", "stain2"]
    )
    lc = LinearContrast(5)
    thumb = lc.run(deconv_image).get_thumb().astype("uint8")
    thumb_image = Image.fromarray(thumb)
    thumb_image.save(args.thumb_out)


if __name__ == "__main__":
    main()
