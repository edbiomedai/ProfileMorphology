#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ConvertToTiff } from './module/convert_to_tiff.nf'
include { SegmentTissue } from './module/segment_tissue.nf'
include { DeconvolveStains } from './module/deconvolve_stains.nf'

filelist = Channel.fromPath(
    "${launchDir}/*.ndpi"
)

workflow ProfileMorphology {
    ConvertToTiff(filelist)
    tiff_out = ConvertToTiff.out

    SegmentTissue(tiff_out.base_name, tiff_out.zarr_path, tiff_out.json_path)
    tis_mask_out = ConvertToTiff.out

    DeconvolveStains(tiff_out.base_name, tiff_out.zarr_path, tiff_out.json_path)
    deconv_out = DeconvolveStains.out
}

workflow {
    ProfileMorphology()
}