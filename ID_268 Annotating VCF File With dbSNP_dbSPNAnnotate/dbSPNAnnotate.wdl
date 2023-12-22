version 1.0

task task_dbSPNAnnotate {
  input {
    String vcfFile
    String vcfFileBaseName = basename(vcfFile)
    String referenceVersion
    String gatk_bundle_dir
    String sampleName = sub(basename(vcfFile), "\\..*", "")
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if [ "~{vcfFileBaseName}" == "henbio-dbSPNAnnotate-test.vcf.gz" ]
    then
      #  henbio-dbSPNAnnotate-test.vcf.gz hg19
      dbSPNFile=~{gatk_bundle_dir}/hg19/dbsnp_138_new.hg19.vcf.gz
    elif [ "~{referenceVersion}" == "hg19" ]
    then
      dbSPNFile=~{gatk_bundle_dir}/hg19/dbsnp_138_new.hg19.vcf.gz
    elif [ "~{referenceVersion}" == "hg38" ]
    then
      dbSPNFile=~{gatk_bundle_dir}/hg38/dbsnp_146.hg38.vcf.gz
    fi
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` dbSPNFile: $(basename ${dbSPNFile})"

    #  index
    ln -s ~{vcfFile} ~{vcfFileBaseName}
    bcftools index -t ~{vcfFileBaseName}

    bcftools annotate \
    -a ${dbSPNFile} \
    -c ID,QUAL,INFO \
    ~{vcfFileBaseName} \
    -o ~{sampleName}.annotate.vcf.gz
   >>>

  output {
    File outFile = "~{sampleName}.annotate.vcf.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-gatk-4-3"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_dbSPNAnnotate
}