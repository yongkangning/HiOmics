version 1.0

task task_bam2fastq {
  input {
    String bamFile
    String sampleName = basename(bamFile, ".bam")
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    samtools sort -n -@4 -o ~{sampleName}.sort.bam ~{bamFile}
    samtools fastq -@4 -1 ~{sampleName}_R1.fq.gz -2 ~{sampleName}_R2.fq.gz -s /dev/null -0 /dev/null ~{sampleName}.sort.bam -c 9

   >>>

  output {
    File outFile1 = "~{sampleName}_R1.fq.gz"
    File outFile2 = "~{sampleName}_R2.fq.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_bam2fastq
}