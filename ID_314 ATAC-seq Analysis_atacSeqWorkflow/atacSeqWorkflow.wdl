version 1.0

task task_atacSeqWorkflow {
  input {
    String sampleDescFile
    String sampleDir
    String readLength
    String nextflowPipelinePath
    String species_genome
    String igenomes_base
    String aligner
    String peakMode
    String peakModeParameter = if peakMode=="narrow" then "--narrow_peak" else " "
    String appBinDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    
    ~{appBinDir}/datacheck_v1.0 -i ~{sampleDescFile} -o metadata_temp.csv -c true -d true -s 1
    tail -n+2 metadata_temp.csv | awk -v FS=',' -v OFS=',' -v sampleDir=~{sampleDir} 'BEGIN{print "sample","fastq_1","fastq_2","replicate"} {print $1,sampleDir"/"$2,sampleDir"/"$3,$4}' > metadata.csv

    
    export NXF_OFFLINE='TRUE'
    nextflow run ~{nextflowPipelinePath}/nf-core-atacseq-2.0/workflow \
    -profile singularity \
    --input metadata.csv \
    --genome ~{species_genome} \
    --igenomes_base ~{igenomes_base} \
    --aligner ~{aligner} ~{peakModeParameter} \
    --read_length ~{readLength} \
    --outdir atacSeqWorkflow_result > run.log 2>&1

    
    find atacSeqWorkflow_result/ -type f -name "*.bam" | xargs rm
    find atacSeqWorkflow_result/ -type f -name "*.bam.bai" | xargs rm

    tar -zcf atacSeqWorkflow_result.tar.gz atacSeqWorkflow_result
   >>>

  output {
    File outFile = "atacSeqWorkflow_result.tar.gz"
    File logFile = "run.log"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:nextflow-22-10-6"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 86400
  }
}
workflow henbio_wf {
  call task_atacSeqWorkflow
}