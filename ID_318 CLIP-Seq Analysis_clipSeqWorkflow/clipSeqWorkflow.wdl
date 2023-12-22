version 1.0

task task_clipSeqWorkflow {
  input {
    String sampleDescFile
    String sampleDir
    String species_genome
    String igenomes_base
    String peakcaller
    String nextflowPipelinePath
    String appBinDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    
    ~{appBinDir}/datacheck_v1.0 -i ~{sampleDescFile} -o metadata_temp.csv -c true -d true -s 1
    tail -n+2 metadata_temp.csv | awk -v FS=',' -v OFS=',' -v sampleDir=~{sampleDir} 'BEGIN{print "sample","fastq"} {print $1,sampleDir"/"$2}' > metadata.csv

    nextflow run ~{nextflowPipelinePath}/nf-core-clipseq-1.0.0/workflow \
    --input metadata.csv \
    --genome ~{species_genome} \
    --igenomes_base ~{igenomes_base} \
    --peakcaller ~{peakcaller} \
    --outdir clipSeqWorkflow_result > run.log 2>&1

    
    rm -rf clipSeqWorkflow_result/mapped
    rm -rf clipSeqWorkflow_result/premap

    tar -zcf clipSeqWorkflow_result.tar.gz clipSeqWorkflow_result
   >>>

  output {
    File outFile = "clipSeqWorkflow_result.tar.gz"
    File logFile = "run.log"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-clipseq-1-0-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 86400
  }
}
workflow henbio_wf {
  call task_clipSeqWorkflow
}