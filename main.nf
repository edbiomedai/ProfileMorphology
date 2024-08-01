#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { ConvertToTiff } from './module/convert_to_tiff.nf'

filelist = Channel.fromPath(
    "${launchDir}/*.ndpi"
)

workflow ProfileMorphology {
    ConvertToTiff(filelist)
    tiff_out = ConvertToTiff.out
}

workflow {
    ProfileMorphology()
}