version 1.0

task task_bam2fasta {
  input {
    String bamFile
    String sampleName = basename(bamFile, ".bam")
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    samtools view ~{bamFile} |awk '{OFS="\t"; print ">"$3"_"$1 "\n"$10}' -> ~{sampleName}.fa

   >>>

  output {
    File outFile = "~{sampleName}.fa"
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
  call task_bam2fasta
}