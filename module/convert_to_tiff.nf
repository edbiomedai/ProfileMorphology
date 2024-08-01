process ConvertToTiff {
    tag "ConvertToTIFF"
    conda "${projectDir}/envs/main_env.yml"
    memory "8 GB"
    time "1 h"
    cpus 1
    publishDir "${launchDir}/outputs/thumbs/raw", mode: 'copy', pattern: "${image.baseName}_raw.png"

    input:
        path image
    
    output:
        val "${image.baseName}", emit: base_name
        path "${image.baseName}.zarr", emit: zarr_path
        path "${image.baseName}.json", emit: json_path
        path "${image.baseName}_raw.png", emit: png_path

    script:
        """
        python ${projectDir}/src/convert_to_tiff.py \
            --image-path ${image} \
            --out-zarr ${image.baseName}.zarr \
            --out-json ${image.baseName}.json \
            --out-thumb ${image.baseName}_raw.png
        """
}