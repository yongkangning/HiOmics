version 1.0

task task_deepvariant {
  input {
    String bamFile
    String modelType
    String referenceVersion
    String gatk_bundle_dir
    String sampleName = sub(basename(bamFile), "\\..*", "")
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    cpu_cores=$(nproc)
    #cpu_cores=10

    if [ "$(basename ~{bamFile})" == "NA12878_S1.chr20.10_10p1mb.bam" ]
    then
      #  NA12878_S1.chr20.10_10p1mb.bam hg19
      ref_file=~{gatk_bundle_dir}/hg19/ucsc.hg19.chr20.unittest.fasta  
    elif [ "~{referenceVersion}" == "hg19" ]
    then
      ref_file=~{gatk_bundle_dir}/hg19/ucsc.hg19.fasta
    elif [ "~{referenceVersion}" == "hg38" ]
    then
      ref_file=~{gatk_bundle_dir}/hg38/Homo_sapiens_assembly38.fasta
    fi
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` ref_file: $(basename ${ref_file})"

    # index bam
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` samtools index bam:" && \
    samtools index ~{bamFile} \
    && echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` samtools index bam done."

    # deepvariant
    # mkdir logs
    # mkdir intermediate_results
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` deepvariant begin:" && \
    /opt/deepvariant/bin/run_deepvariant \
      --model_type=~{modelType} \
      --ref=${ref_file} \
      --reads=~{bamFile} \
      --output_vcf=~{sampleName}.vcf.gz \
      --output_gvcf=~{sampleName}.g.vcf.gz \
      --num_shards=${cpu_cores} && echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` deepvariant done."
   >>>

  output {
    Array[File] outFiles = ["~{sampleName}.vcf.gz","~{sampleName}.g.vcf.gz","~{sampleName}.vcf.gz.tbi","~{sampleName}.g.vcf.gz.tbi","~{sampleName}.visual_report.html"]
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:google-deepvariant-1-4-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    # 24h
    timeout: 86400
  }
}
workflow henbio_wf {
  call task_deepvariant
}