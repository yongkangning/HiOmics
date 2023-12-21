version 1.0

task task_salmonQuantify {
  input {
    String metadata_file
    String species
    Int sample_numbers
    Int data_disk_size = sample_numbers * 10
    String cluster_config
    String mount_paths
  }

  command <<<

    # set -o pipefail
    set -e
    
    mkdir -p quantify_result/{qc_before,qc_after,fastp,multiqc_before,multiqc_after,salmon}

    echo "metadata_file: ~{metadata_file}"
    seq_data_dir=$(dirname ~{metadata_file})

    echo "[INFO] "
    samples=$(cat ~{metadata_file} | wc -l)
    echo "input samples: ~{sample_numbers}  metadata samples: ${samples}. data_disk_size: ~{data_disk_size}"
    if [ ${samples} -ne ~{sample_numbers} ]
    then
      echo "[ERRO]"
      exit 111
    fi

    
    salmon_index=`cat /henbio/henbio_web/public/map_files/salmon_index_map.txt | grep "^~{species}," | awk -F ',' '{print $2}'`
    echo "salmon_index: ${salmon_index}"
    if [ "${salmon_index}" == "" ]
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
    echo "# 01.3 "
    fastqc quantify_result/fastp/*_clean_{1,2}.fq.gz -t 4 -o quantify_result/qc_after
    multiqc -d quantify_result/qc_after -o quantify_result/multiqc_after
    
    cat ~{metadata_file}  | \
    rush -k -j 2 \
      -v seq_data_dir=${seq_data_dir} \
      -v salmon_index=${salmon_index} \
      '
        salmon quant --gcBias -l A -p 8 \
        -1 {seq_data_dir}/{2} \
        -2 {seq_data_dir}/{3} \
        -i {salmon_index} \
        -o quantify_result/salmon/{1}
      '

    echo "## "
    python /henbio/henbio_web/public/apps/scripts/fastp_stat.py quantify_result/fastp ~{metadata_file}

    echo "## "
    multiqc -f -d quantify_result/salmon -o quantify_result/multiqc_salmon

    
    cd quantify_result
    tar -czvf  quant.sf.tar.gz $(find salmon -name quant.sf)
    rm -rf salmon/*
    mv quant.sf.tar.gz salmon/
    cd ../
    
    
    rm -rf quantify_result/qc_before
    rm -rf quantify_result/qc_after
    rm -rf quantify_result/fastp/*.gz
    tar -czvf quantify_result.tar.gz quantify_result
    
   >>>

  output {
    File outFile = "quantify_result.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-rna-seq-salmon-1-0"
    autoReleaseJob: false
    timeout: 86400
    cluster: cluster_config
    mounts: mount_paths
    systemDisk: "cloud_ssd 40"
    dataDisk: "cloud_ssd " + data_disk_size + " /cromwell_root/"
  }
}
workflow henbio_wf {
  call task_salmonQuantify
}