#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

filelist = Channel.fromPath(
    "${launchDir}/*.ndpi"
)

workflow ProfileMorphology {

}