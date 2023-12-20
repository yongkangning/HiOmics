version 1.0

task task_cellrangerCount {
  input {
    String fastqDir
    String species
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    transcriptomeDir=$(cat /henbio/henbio_web/public/map_files/cellRanger_species_starIndex_map.txt | grep "^~{species}," | awk -F ',' '{print $2}')
    if [ "${transcriptomeDir}" == "" ]
    then
        echo "[ERRO] not support species: ~{species}."
        exit 123
    fi
    echo "species: ~{species}, transcriptomeDir: ${transcriptomeDir}."

    mkdir cellranger_count_result
    cellranger count --id=count_result --fastqs=~{fastqDir} --transcriptome=${transcriptomeDir} --no-bam
    mv count_result/outs/filtered_feature_bc_matrix cellranger_count_result/feature_bc_matrix
    mv count_result/outs/web_summary.html cellranger_count_result/
    mv count_result/outs/metrics_summary.csv cellranger_count_result/
    mv count_result/outs/molecule_info.h5 cellranger_count_result/
    tar -czvf cellranger_count_result.tar.gz cellranger_count_result

   >>>

  output {
    File outFile = "cellranger_count_result.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:cellranger-7-0-0"
    autoReleaseJob: false
    timeout: 36000
    cluster: cluster_config
    mounts: mount_paths
    systemDisk: "cloud_ssd 40"
    dataDisk: "cloud_ssd 250 /cromwell_root/"
  }
}
workflow henbio_wf {
  call task_cellrangerCount
}