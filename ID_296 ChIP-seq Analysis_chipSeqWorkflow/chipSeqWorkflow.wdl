version 1.0

task task_chipSeqWorkflow {
  input {
    String sampleDescFile
    String sampleDir
    String readLength
    String nextflowPipelinePath
    String fastaFile
    String gtfFile
    String bwaIndex
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    
    export NXF_OFFLINE='TRUE'
    tail -n+2 ~{sampleDescFile} | awk -v FS=',' -v OFS=',' -v sampleDir=~{sampleDir} \
      'BEGIN{print "sample","fastq_1","fastq_2","antibody","control"} {print $1,sampleDir"/"$2,sampleDir"/"$3,$4,$5}' > metadata.csv

    nextflow run ~{nextflowPipelinePath}/nf-core-chipseq-2.0.0/workflow \
    -profile singularity \
    --input metadata.csv \
    --fasta ~{fastaFile} \
    --gtf ~{gtfFile} \
    --bwa_index ~{bwaIndex} \
    --read_length ~{readLength} \
    --outdir chipSeqWorkflow_result > run.log 2>&1

    tar -zcf chipSeqWorkflow_result.tar.gz chipSeqWorkflow_result
   >>>

  output {
    File outFile = "chipSeqWorkflow_result.tar.gz"
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
  call task_chipSeqWorkflow
}