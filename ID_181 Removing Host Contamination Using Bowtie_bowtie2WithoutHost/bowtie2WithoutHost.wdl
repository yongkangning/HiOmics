version 1.0

task task_bowtie2WithoutHost {
  input {
    String fastqRead1
    String fastqRead2
    String bowtie2Index
    String sampleName = sub(basename(fastqRead1), "_.*", "")
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    tar -zxf ~{bowtie2Index} -C ./
    bowtie2 --very-sensitive -p 4 -x bowtie2_index/bowtie2_index -1 ~{fastqRead1} -2 ~{fastqRead2} --un-conc-gz unmap_~{sampleName}_R%.fq.gz > /dev/null
   >>>

  output {
    File outFile1 = "unmap_~{sampleName}_R1.fq.gz"
    File outFile2 = "unmap_~{sampleName}_R2.fq.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:bowtie2-2-2-5"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 14400
  }
}
workflow henbio_wf {
  call task_bowtie2WithoutHost
}