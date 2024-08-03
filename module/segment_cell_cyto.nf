process SegmentCellCyto {
    tag "SegmentCellCyto"
    conda "${projectDir}/envs/main_env.yml"
    memory "32 GB"
    time "1 h"
    cpus 8
    
    input:
        val base_name
        path image_zarr
        path image_json
        path tissue_mask_zarr
        path tissue_mask_json
        path nuclei_mask_zarr
        path nuclei_mask_json
    
    output:
        tuple val(base_name), path(image_zarr), path(image_json), path(tissue_mask_zarr), path(tissue_mask_json), path(nuclei_mask_zarr), path(nuclei_mask_json), path("${base_name}_cellmask.zarr"), path("${base_name}_cellmask.json"), path("${base_name}_cytomask.zarr"), path("${base_name}_cytomask.json"), emit: full_out
    
    script:
        """
        python ${projectDir}/src/segment_cell_cyto.py \
            --tissue-mask-zarr ${tissue_mask_zarr} \
            --tissue-mask-json ${tissue_mask_json} \
            --nuclei-mask-zarr ${nuclei_mask_zarr} \
            --nuclei-mask-json ${nuclei_mask_json} \
            --cell-mask-zarr ${base_name}_cellmask.zarr \
            --cell-mask-json ${base_name}_cellmask.json \
            --cyto-mask-zarr ${base_name}_cytomask.zarr \
            --cyto-mask-json ${base_name}_cytomask.json
        """
}