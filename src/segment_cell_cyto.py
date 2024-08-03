from argparse import ArgumentParser, Namespace
from scematk.io import read_zarr_bin_mask, read_zarr_lbl_mask
from scematk.segment import clip_mask
from scematk.segment.secondary import ExpansionSegmenter
from scematk.segment.tertiary import subtract_mask

def get_cli_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument('--tissue-mask-zarr', type=str)
    parser.add_argument('--tissue-mask-json', type=str)
    parser.add_argument('--nuclei-mask-zarr', type=str)
    parser.add_argument('--nuclei-mask-json', type=str)
    parser.add_argument('--cell-mask-zarr', type=str)
    parser.add_argument('--cell-mask-json', type=str)
    parser.add_argument('--cyto-mask-zarr', type=str)
    parser.add_argument('--cyto-mask-json', type=str)
    return parser.parse_args()

def main() -> None:
    args = get_cli_args()
    tissue_mask = read_zarr_bin_mask(args.tissue_mask_zarr, args.tissue_mask_json)
    nuclei_mask = read_zarr_lbl_mask(args.nuclei_mask_zarr, args.nuclei_mask_json)
    expansion_segmenter = ExpansionSegmenter(5)
    cell_mask = expansion_segmenter.run(nuclei_mask)
    cell_mask = clip_mask(cell_mask, tissue_mask)
    cell_mask.save(args.cell_mask_zarr, args.cell_mask_json)
    cell_mask = read_zarr_lbl_mask(args.cell_mask_zarr, args.cell_mask_json)
    cyto_mask = subtract_mask(cell_mask, nuclei_mask)
    cyto_mask.save(args.cyto_mask_zarr, args.cyto_mask_json)

if __name__=='__main__':
    main()