version 1.0

task task_chromsizes {
  input {
    String inputfile
    String number
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    seqkit fx2tab --name --only-id -l ~{inputfile} > chromsizes.txt
    cat chromsizes.txt | grep -v "_" | grep "chr[0-9]" > hg19_chromsizes.txt
    bedtools   makewindows -g hg19_chromsizes.txt -w  ~{number} > result.bed
   >>>

  output {
    File outFile = "result.bed"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_chromsizes
}




