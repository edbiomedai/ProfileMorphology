from argparse import ArgumentParser, Namespace
from PIL import Image
from scematk.io import read_zarr_bin_mask, read_zarr_ubimg
from scematk.process import Processor
from scematk.process.colour import RGBToGrey
from scematk.process.contrast import GammaContrast
from scematk.process.morphology import BinaryClosing, BinaryOpening
from scematk.segment.tissue import OtsuThresholder

def get_cli_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument('--zarr-path', type=str)
    parser.add_argument('--json-path', type=str)
    parser.add_argument('--zarr-out', type=str)
    parser.add_argument('--json-out', type=str)
    parser.add_argument('--thumb-out', type=str)
    return parser.parse_args()

def main() -> None:
    args = get_cli_args()
    image = read_zarr_ubimg(args.zarr_path, args.json_path)
    preprocessor = Processor([RGBToGrey(), GammaContrast(2)])
    postprocessor = Processor([BinaryClosing(2), BinaryOpening(2)])
    otsu_thresholder = OtsuThresholder(
        preprocessor=preprocessor,
        postprocessor=postprocessor
    )
    tissue_mask = otsu_thresholder.fit_and_run(image)
    tissue_mask.save(args.zarr_out, args.json_out)
    tissue_mask = read_zarr_bin_mask(args.zarr_out, args.json_out)
    thumb = tissue_mask.get_thumb()
    thumb = thumb * 255
    thumb = thumb.astype("uint8")
    thumb = Image.fromarray(thumb)
    thumb.save(args.thumb_out)

if __name__=="__main__":
    main()