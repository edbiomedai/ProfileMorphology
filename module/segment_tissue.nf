process SegmentTissue {
    tag "SegmentTissue"
    conda "${projectDir}/envs/main_env.yml"
    memory "16 GB"
    time "1 h"
    cpus 8
    publishDir "${launchDir}/outputs/thumbs/tissuemask", mode: 'copy', pattern: "${base_name}_tissuemask.png"

    input:
        val base_name
        path zarr_path
        path json_path
    
    output:
        val base_name, emit: base_name
        path "${base_name}_tissuemask.zarr", emit: tissue_mask_zarr
        path "${base_name}_tissuemask.json", emit: tissue_mask_json
        path "${base_name}_tissuemask.png", emit: tissue_mask_png
    
    script:
        """
        python ${projectDir}/src/segment_tissue.py \
            --zarr-path ${zarr_path} \
            --json-path ${json_path} \
            --zarr-out ${base_name}_tissuemask.zarr \
            --json-out ${base_name}_tissuemask.json \
            --thumb-out ${base_name}_tissuemask.png
        """
}