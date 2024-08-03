#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ConvertToTiff } from './module/convert_to_tiff.nf'
include { SegmentTissue } from './module/segment_tissue.nf'
include { SegmentNuclei } from './module/segment_nuclei.nf'
include { DeconvolveStains } from './module/deconvolve_stains.nf'

filelist = Channel.fromPath(
    "${launchDir}/*.ndpi"
)

workflow ProfileMorphology {
    ConvertToTiff(filelist)
    tiff_out = ConvertToTiff.out

    SegmentTissue(tiff_out.base_name, tiff_out.zarr_path, tiff_out.json_path)
    tis_mask_out = SegmentTissue.out

    SegmentNuclei(tis_mask_out.base_name, tis_mask_out.image_zarr, tis_mask_out.image_json, tis_mask_out.tissue_mask_zarr, tis_mask_out.tissue_mask_json)
    nuc_mask_out = SegmentNuclei.out

    DeconvolveStains(tiff_out.base_name, tiff_out.zarr_path, tiff_out.json_path)
    deconv_out = DeconvolveStains.out
    deconv_out.deconv_img.view()
}

workflow {
    ProfileMorphology()
}