process DeconvolveStains {
    tag "DeconvolveStains"
    conda "${projectDir}/envs/main_env.yml"
    memory "16 GB"
    time "1 h"
    cpus 8
    publishDir "${launchDir}/outputs/thumbs/deconv", mode: 'copy', pattern: "${base_name}_deconv.png"

    input:
        val base_name
        path zarr_path
        path json_path
    
    output:
        tuple val(base_name), path("${base_name}_deconv.zarr"), path("${base_name}_deconv.json"), emit: deconv_img
        path "${base_name}_deconv.png", emit: deconv_png
    
    script:
        """
        python ${projectDir}/src/deconvolve_stains.py \
            --zarr-path ${zarr_path} \
            --json-path ${json_path} \
            --zarr-out ${base_name}_deconv.zarr \
            --json-out ${base_name}_deconv.json \
            --thumb-out ${base_name}_deconv.png
        """
}