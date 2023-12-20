version 1.0

task task_starQuantify {
  input {
    String metadata_file
    String species
    String species_type
    String align_intron_max = if species_type == "animal" then "1000000" else "5000"
    Int sample_numbers
    Int data_disk_size = sample_numbers * 25
    String cluster_config
    String mount_paths
  }

  command <<<

    # set -o pipefail
    set -e
    
    mkdir -p quantify_result/{qc_before,qc_after,fastp,multiqc_before,multiqc_after,star,STAR}

    echo "metadata_file: ~{metadata_file}"
    seq_data_dir=$(dirname ~{metadata_file})

    echo "[INFO] "
    samples=$(cat ~{metadata_file} | wc -l)
    echo "input samples: ~{sample_numbers}  metadata samples: ${samples}. data_disk_size: ~{data_disk_size}"
    if [ ${samples} -ne ~{sample_numbers} ]
    then
      echo "[ERRO] "
      exit 111
    fi    

    
    star_index=`cat /henbio/henbio_web/public/map_files/star_index_map.txt | grep "^~{species}," | awk -F ',' '{print $2}'`
    echo "star_index: ${star_index}"
    if [ "${star_index}" == "" ]
    then
      echo "[ERRO] not support species: ~{species}."
      exit 222
    fi
    echo "species: ~{species}"
    echo "# 01.1 fastqc "
    
    fastqc ${seq_data_dir}/*.gz -t 16 -o quantify_result/qc_before
    multiqc -d quantify_result/qc_before -o quantify_result/multiqc_before
    
    echo "# 01.2 fasp "
    cat ~{metadata_file} | \
    rush -k -j 3 \
    -v seq_data_dir=${seq_data_dir} \
      '
        fastp \
          -i {seq_data_dir}/{2} \
          -o quantify_result/fastp/{1}_clean_1.fq.gz \
          -I {seq_data_dir}/{3} \
          -O quantify_result/fastp/{1}_clean_2.fq.gz \
          -j quantify_result/fastp/{1}.json \
          -h quantify_result/fastp/{1}.html \
          -q 20 -u 40 -n 10
      '
    echo "
    fastqc quantify_result/fastp/*_clean_{1,2}.fq.gz -t 4 -o quantify_result/qc_after
    multiqc -d quantify_result/qc_after -o quantify_result/multiqc_after
    
    cat ~{metadata_file}  | \
    rush -k -j 2 \
      -v star_index=${star_index} \
      '
        STAR --runMode alignReads --runThreadN 8 \
          --readFilesIn quantify_result/fastp/{1}_clean_1.fq.gz quantify_result/fastp/{1}_clean_2.fq.gz \
          --readFilesCommand zcat \
          --genomeDir {star_index} \
          --outFileNamePrefix quantify_result/star/{1}. \
          --outFilterType BySJout \
          --outSAMattributes NH HI AS NM MD \
          --outFilterMultimapNmax 20 \
          --alignSJoverhangMin 8 \
          --alignSJDBoverhangMin 1 \
          --alignIntronMin 20 \
          --alignIntronMax ~{align_intron_max} \
          --alignMatesGapMax 1000000 \
          --outFilterMatchNminOverLread 0.66 \
          --outFilterScoreMinOverLread 0.66 \
          --winAnchorMultimapNmax 70 \
          --seedSearchStartLmax 45 \
          --outSAMattrIHstart 0 \
          --outSAMstrandField intronMotif \
          --genomeLoad LoadAndKeep \
          --outReadsUnmapped Fastx \
          --outSAMtype BAM Unsorted \
          --quantMode TranscriptomeSAM GeneCounts
      '

    echo "
    python /henbio/henbio_web/public/apps/scripts/fastp_stat.py quantify_result/fastp ~{metadata_file}

    echo "
    # echo -e "sample\ttotal_reads\talignment_rate" > quantify_result/hisat2/mapping_summary.txt
    python /henbio/henbio_web/public/apps/scripts/star_mapping_result.py ~{metadata_file} quantify_result/star mapping_summary.txt

    
    files=$(cat  ~{metadata_file} | awk -v ORS=" " '{print "quantify_result/star/"$1".ReadsPerGene.out.tab"}')
    paste ${files} | tail -n +5 | \
    awk 'BEGIN{OFS=FS="\t" }{line=$1; for(i=2;i<=NF;i++) if(i%2==0 && i%4!=0) line=line"\t"$i; print line;}' \
      > quantify_result/star/GeneCountMatrix.txt
    
    header=$(awk -v ORS="\t" 'BEGIN{ print "Geneid" } {print $1}'  ~{metadata_file} | sed 's/\t$//g')
    sed -i "1s/^/$header\n/" quantify_result/star/GeneCountMatrix.txt
    mv quantify_result/star/mapping_summary.txt quantify_result/STAR/
    mv quantify_result/star/GeneCountMatrix.txt quantify_result/STAR/
    mv quantify_result/star/*.Log.final.out quantify_result/STAR/

    
    rm -rf quantify_result/qc_before
    rm -rf quantify_result/qc_after
    rm -rf quantify_result/fastp/*.gz
    rm -rf quantify_result/star
    tar -czvf quantify_result.tar.gz quantify_result
    
   >>>

  output {
    File outFile = "quantify_result.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-rna-seq-quantify-1-0"
    autoReleaseJob: false
    timeout: 86400
    cluster: cluster_config
    mounts: mount_paths
    systemDisk: "cloud_ssd 40"
    dataDisk: "cloud_ssd " + data_disk_size + " /cromwell_root/"
  }
}
workflow henbio_wf {
  call task_starQuantify
}