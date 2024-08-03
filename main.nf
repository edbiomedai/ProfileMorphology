#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ConvertToTiff } from './module/convert_to_tiff.nf'
include { SegmentTissue } from './module/segment_tissue.nf'
include { SegmentNuclei } from './module/segment_nuclei.nf'
include { SegmentCellCyto } from './module/segment_cell_cyto.nf'
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

    SegmentCellCyto(nuc_mask_out.base_name, nuc_mask_out.image_zarr, nuc_mask_out.image_json, nuc_mask_out.tissue_mask_zarr, nuc_mask_out.tissue_mask_json, nuc_mask_out.nuclei_mask_zarr, nuc_mask_out.nuclei_mask_json)
    full_seg_out = SegmentCellCyto.out

    DeconvolveStains(tiff_out.base_name, tiff_out.zarr_path, tiff_out.json_path)
    deconv_out = DeconvolveStains.out

    morph_prep = full_seg_out.full_out
        .join(deconv_out.deconv_img)
        .multiMap { it ->
            base_name: it[0]
            image_zarr: it[1]
            image_json: it[2]
            tissue_mask_zarr: it[3]
            tissue_mask_json: it[4]
            nuclei_mask_zarr: it[5]
            nuclei_mask_json: it[6]
            cell_mask_zarr: it[7]
            cell_mask_json: it[8]
            cyto_mask_zarr: it[9]
            cyto_mask_json: it[10]
            deconv_mask_zarr: it[11]
            deconv_mask_json: it[12]
        }
}

workflow {
    ProfileMorphology()
}