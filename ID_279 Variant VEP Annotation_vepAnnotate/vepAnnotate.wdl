version 1.0

task task_vepAnnotate {
  input {
    String vcfFile
    String vcfFileBaseName = basename(vcfFile)
    String sampleName = sub(basename(vcfFile), "\\..*", "")
    String referenceVersion
    String vepDbCache
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    cpu_cores=$(nproc)
    # cpu_cores=10
    
    vep \
    --dir_cache ~{vepDbCache} \
    --fork ${cpu_cores} \
    --refseq \
    --format vcf \
    -i ~{vcfFile} \
    --vcf \
    -o ~{sampleName}.annotate.vcf \
    --offline \
    --assembly ~{referenceVersion} \
    --use_given_ref \
    --canonical \
    --symbol \
    --force_overwrite

    gzip ~{sampleName}.annotate.vcf
   >>>

  output {
    Array[File] outFiles = ["~{sampleName}.annotate.vcf.gz","~{sampleName}.annotate.vcf_summary.html"]
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:ensembl-vep-108-2"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_vepAnnotate
}