from argparse import ArgumentParser, Namespace

from PIL import Image
from scematk.io import read_zarr_ubimg, tiff_to_zarr


def get_cli_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument("--image-path", type=str)
    parser.add_argument("--out-zarr", type=str)
    parser.add_argument("--out-json", type=str)
    parser.add_argument("--out-thumb", type=str)
    return parser.parse_args()


def main() -> None:
    args = get_cli_args()
    tiff_to_zarr(args.image_path, args.out_zarr, args.out_json)
    image = read_zarr_ubimg(args.out_zarr, args.out_json)
    thumb = image.get_thumb().astype("uint8")
    thumb_image = Image.fromarray(thumb)
    thumb_image.save(args.out_thumb)


if __name__ == "__main__":
    main()
