version 1.0

task task_extractVcfByChr {
  input {
    String vcfFile
    String vcfFileBaseName = basename(vcfFile)
    String sampleName = sub(basename(vcfFile), "\\..*", "")
    String chrName
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    #  index
    ln -s ~{vcfFile} ~{vcfFileBaseName}
    bcftools index -t ~{vcfFileBaseName}
    
    echo "123"
    chrCount=`bcftools view ~{vcfFileBaseName} | grep -v "#" | grep "^chr[0-9]" |head |wc -l`
    echo ${chrCount}
    if [ ${chrCount} -gt 0 ]
    then
      inChr=~{chrName}
    else
      inChr=`echo ~{chrName} | tr 'A-Z' 'a-z' | tr -d 'chr'`
    fi
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` chrCount: ${chrCount} chrName: ${inChr}"

    bcftools filter -r ${inChr} ~{vcfFileBaseName} -Oz -o ~{sampleName}.~{chrName}.vcf.gz
   >>>

  output {
    File outFile = "~{sampleName}.~{chrName}.vcf.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-gatk-4-3"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_extractVcfByChr
}