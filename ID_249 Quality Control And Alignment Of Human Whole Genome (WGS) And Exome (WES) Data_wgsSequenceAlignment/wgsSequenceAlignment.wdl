version 1.0

task task_wgsSequenceAlignment {
  input {
    String fastqRead1
    String fastqRead2
    String sample_name = sub(basename(fastqRead1), "_.*", "")
    String gatk_bundle_dir
    String cluster_config
    String mount_paths
  }

  command <<<
    cpu_cores=$(nproc)

    
    # read1
    if [ ! -f ~{fastqRead1} ]
    then
      echo "[ERRO] `date '+%Y-%m-%d %H:%M:%S'`  ~{fastqRead1} "
      exit 111
    fi

    # read2
    if [ ! -f ~{fastqRead2} ]
    then
      echo "[ERRO] `date '+%Y-%m-%d %H:%M:%S'`  ~{fastqRead2} "
      exit 111
    fi

    if [ ! -d ~{gatk_bundle_dir} ]
    then
      echo "[ERRO] `date '+%Y-%m-%d %H:%M:%S'`  ~{gatk_bundle_dir} "
      exit 111
    fi

    
    fastq_base_dir=$(dirname ~{fastqRead1})
    FileCount=`ls ${fastq_base_dir}/~{sample_name}*.gz |wc -l`
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` fastq FileCount: ${FileCount}."
    if [ ${FileCount} -ne 2 ]
    then
      echo "[ERRO] `date '+%Y-%m-%d %H:%M:%S'`  fastq read1 file name: `basename ~{fastqRead1}`"
      echo "[ERRO] `date '+%Y-%m-%d %H:%M:%S'`  fastq read2 file name: `basename ~{fastqRead2}`"
      echo "[ERRO] `date '+%Y-%m-%d %H:%M:%S'` "
      exit 222
    fi

    set -o pipefail
    set -e

    
    mkdir fastqc && echo "[INFO] do fastqc:" && \
    fastqc -f fastq -t ${cpu_cores} ${fastq_base_dir}/~{sample_name}*.gz  -o fastqc  \
      &&  echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` fastqc Done."

    mkdir fastp && echo "[INFO] fastp " && \
    fastp \
      -i ~{fastqRead1} \
      -I ~{fastqRead2} \
      -o fastp/~{sample_name}_clean.R1.fastq.gz \
      -O fastp/~{sample_name}_clean.R2.fastq.gz \
      -j fastp/~{sample_name}.json \
      -h fastp/~{sample_name}.html \
      -z 4 -q 20 -u 40 -n 10 &&  echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` fastp Done."

    
    mkdir bwa && echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` bwa align:" && \
    bwa-mem2 mem \
      -t ${cpu_cores} \
      -o bwa/~{sample_name}.sam \
      -R "@RG\tID:~{sample_name}\tPL:illumina\tSM:~{sample_name}" \
      ~{gatk_bundle_dir}/bwa-mem2_hg38_index/hg38 \
      fastp/~{sample_name}_clean.R1.fastq.gz \
      fastp/~{sample_name}_clean.R2.fastq.gz &&  echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` bwa align Done."
    # sort bam
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` sort bam by position:" && \
    samtools sort -@ ${cpu_cores} -o bwa/~{sample_name}.sorted.bam  bwa/~{sample_name}.sam && \
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` sort bam by position Done."
    rm -f bwa/~{sample_name}.sam
    rm -f fastqc/*fastqc.zip
    tar -czvf fastqc.tar.gz fastqc
   >>>

  output {
    File bamFile = "bwa/~{sample_name}.sorted.bam"
    File fastqcFile = "fastqc.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-gatk-4-3"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 36000
  }
}
workflow henbio_wf {
  call task_wgsSequenceAlignment
}