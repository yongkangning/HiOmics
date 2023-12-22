version 1.0

task task_extractSnpIndel {
  input {
    String vcfFile
    String vcfFileBaseName = basename(vcfFile)
    String referenceVersion
    String sampleName = sub(basename(vcfFile), "\\..*", "")
    String gatk_bundle_dir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if [ "~{vcfFileBaseName}" == "henbio-extractSnpIndel-test.vcf.gz" ]
    then
      #  henbio-extractSnpIndel-test.vcf.gz hg19
      ref_file=~{gatk_bundle_dir}/hg19/ucsc.hg19.chr20.unittest.fasta
    elif [ "~{referenceVersion}" == "hg19" ]
    then
      ref_file=~{gatk_bundle_dir}/hg19/ucsc.hg19.fasta
    elif [ "~{referenceVersion}" == "hg38" ]
    then
      ref_file=~{gatk_bundle_dir}/hg38/Homo_sapiens_assembly38.fasta
    fi
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` ref_file: $(basename ${ref_file})"

    #  index
    ln -s ~{vcfFile} ~{vcfFileBaseName}
    bcftools index -t ~{vcfFileBaseName} 
    
    gatk  SelectVariants \
    -R ${ref_file} \
    -V ~{vcfFileBaseName} \
    -O ~{sampleName}.snp.vcf.gz \
    -select-type SNP && echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` extract snp done."

    gatk  SelectVariants \
    -R ${ref_file} \
    -V ~{vcfFileBaseName} \
    -O ~{sampleName}.indel.vcf.gz \
    -select-type INDEL && echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` extract indels done."
   >>>

  output {
    Array[File] outFiles = ["~{sampleName}.snp.vcf.gz","~{sampleName}.snp.vcf.gz.tbi","~{sampleName}.indel.vcf.gz","~{sampleName}.indel.vcf.gz.tbi"]
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-gatk-4-3"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_extractSnpIndel
}