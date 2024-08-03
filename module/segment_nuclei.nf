process SegmentNuclei {
    tag "SegmentNuclei"
    conda "${projectDir}/envs/main_env.yml"
    memory "16 GB"
    time "12 h"
    cpus 16

    input:
        val base_name
        path image_zarr
        path image_json
        path tissue_mask_zarr
        path tissue_mask_json
    
    output:
        val base_name, emit: base_name
    
    script:
        """
        python ${projectDir}/src/segment_nuclei.py \
            --zarr-path ${image_zarr} \
            --json-path ${image_json} \
            --tissue-zarr ${tissue_mask_zarr} \
            --tissue-json ${tissue_mask_json} \
            --zarr-out ${base_name}_nucleimask.zarr \
            --json-out ${base_name}_nucleimask.json
        """
}