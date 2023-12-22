version 1.0

task task_wgsSequenceAlignmentPlus {
  input {
    String fastqDir
    String metaDataFile
    String gatk_bundle_dir
    String appDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    cpu_cores=$(nproc)

    ~{appDir}/datacheck_v1.0 -i ~{metaDataFile} -o metadata.txt -c -d

    
    cat metadata.txt | while read line
    do
      fastq1=$(echo ${line} | awk '{print $2}')
      if [ ! -f ~{fastqDir}/${fastq1} ]
      then
        echo " ${fastq1} "
        exit 111
      fi    
      fastq2=$(echo ${line} | awk '{print $3}')
      if [ ! -f  ~{fastqDir}/${fastq2} ]
      then
        echo " ${fastq2} "
        exit 111
      fi
    done

    sampleCount=`cat metadata.txt | awk '{print $1}' | sort | uniq |wc -l`
    if [ ${sampleCount} -ne 1 ]
    then
      echo " ~{metaDataFile} "
      exit 222
    fi
    sample_name=`cat metadata.txt | head -1 | awk '{print $1}'`
    if [ ! -f  ~{fastqDir}/${sample_name}*.gz ]
    then
      echo " ~{fastqDir}/${sample_name}*.gz "
      exit 111
    fi    
    
    
    mkdir fastqc && echo "[INFO] do fastqc:" && \
    fastqc -f fastq -t ${cpu_cores} ~{fastqDir}/${sample_name}*.gz  -o fastqc  \
      &&  echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` fastqc Done."

    mkdir fastp && echo "[INFO] fastp "
    cat metadata.txt | \
    rush -k -j 2 \
    -v fastqDir=~{fastqDir} \
      '
        fastp \
          -w 8 \
          -i {fastqDir}/{2} \
          -o fastp/`echo {2} | sed s/\.gz$//g`_clean_1.fq.gz \
          -I {fastqDir}/{3} \
          -O fastp/`echo {2} | sed s/\.gz$//g`_clean_2.fq.gz \
          -j fastp/`echo {2} | sed s/\.gz$//g`.json \
          -h fastp/`echo {2} | sed s/\.gz$//g`.html \
          -z 4 -q 20 -u 40 -n 10
      '
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` fastp Done."

    
    mkdir bwa && echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` bwa align:"
    cat metadata.txt | \
    rush -k -j 1 \
      '
        bwa-mem2 mem \
          -t 16 \
          -o bwa/`echo {2} | sed s/\.gz$//g`.sam \
          -R "@RG\tID:{1}\tPL:illumina\tSM:{1}" \
          ~{gatk_bundle_dir}/bwa-mem2_hg38_index/hg38 \
          fastp/`echo {2} | sed s/\.gz$//g`_clean_1.fq.gz \
          fastp/`echo {2} | sed s/\.gz$//g`_clean_2.fq.gz
      '
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` bwa align Done."
    
    # sort bam
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` sort bam by position:"
    cat metadata.txt | rush -k -j 2 'samtools sort -@ 8 -o bwa/`echo {2} | sed s/\.gz$//g`.sorted.bam  bwa/`echo {2} | sed s/\.gz$//g`.sam'
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` sort bam by position Done."

    # merge bam
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` merge multiple bam:"
    samtools merge -@ ${cpu_cores} -o ${sample_name}.sorted.bam bwa/*.sorted.bam
    echo "${sample_name}.sorted.bam" >> outFile.txt
    echo "[INFO] `date '+%Y-%m-%d %H:%M:%S'` merge multiple bam."

    rm -rf bwa
    rm -f fastqc/*fastqc.zip
    tar -czvf fastqc.tar.gz fastqc
    # find bwa/  -name "*sorted.bam" > outFile.txt
    echo "fastqc.tar.gz" >> outFile.txt
   >>>

  output {
    Array[File] resultFiles = read_lines("outFile.txt")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-gatk-4-3"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    # 24h
    timeout: 86400
  }
}
workflow henbio_wf {
  call task_wgsSequenceAlignmentPlus
}