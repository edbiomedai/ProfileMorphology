from argparse import ArgumentParser, Namespace
from csbdeep.data import Normalizer, normalize_mi_ma
import numpy as np
from scematk.io import read_zarr_bin_mask, read_zarr_lbl_mask, read_zarr_ubimg
from scematk.segment import clip_mask
from shutil import rmtree
from stardist.models import StarDist2D
import zarr

class MyNormalizer(Normalizer):
    def __init__(self, mi, ma):
        self.mi, self.ma = mi, ma
        
    def before(self, x, axes):
        return normalize_mi_ma(x, self.mi, self.ma, dtype=np.float32)
    
    def after(*args, **kwargs):
        assert False
        
    @property
    def do_after(self):
        return False

def get_cli_args() -> Namespace:
    parser = ArgumentParser()
    parser.add_argument("--zarr-path", type=str)
    parser.add_argument("--json-path", type=str)
    parser.add_argument("--tissue-zarr", type=str)
    parser.add_argument("--tissue-json", type=str)
    parser.add_argument("--zarr-out", type=str)
    parser.add_argument("--json-out", type=str)
    return parser.parse_args()

def main() -> None:
    args = get_cli_args()
    tissue_mask = read_zarr_bin_mask(args.tissue_zarr, args.tissue_json)
    mi, ma = 0, 255
    normalizer = MyNormalizer(mi, ma)
    zarr_image = zarr.open(args.zarr_path)
    store = zarr.DirectoryStore('temp.zarr')
    out_zarr = zarr.create(shape=zarr_image.shape[:2], chunks=(4096, 4096), dtype=np.int32, store=store)
    sd_model = StarDist2D.from_pretrained("2D_versatile_he")
    _, _ = sd_model.predict_instances_big(
        zarr_image,
        axes="YXC",
        block_size=4096,
        min_overlap=128,
        context=128,
        normalizer=normalizer,
        n_tiles=(4,4,1),
        labels_out=out_zarr,
        prob_thresh=0.2,
        nms_thresh=0.3,
    )
    nuclei_mask = read_zarr_lbl_mask('temp.zarr', args.json_path)
    clipped_nuclei_mask = clip_mask(nuclei_mask, tissue_mask)
    clipped_nuclei_mask.save(args.zarr_out, args.json_out)
    rmtree('temp.zarr')

if __name__=='__main__':
    main()