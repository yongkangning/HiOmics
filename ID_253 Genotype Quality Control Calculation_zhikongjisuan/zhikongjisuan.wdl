version 1.0

task task_zhikongjisuan {
  input {
    String inputfileDir
    String inputFilePrefix
    String is_check_sex
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    if [ "~{is_check_sex}" == "T" ]; then
    /henbio/henbio_web/public/apps/tools/plink -file ~{inputfileDir}/~{inputFilePrefix} --freq --missing --hardy --check-sex --out result
    elif [ "~{is_check_sex}" == "F" ]; then
    /henbio/henbio_web/public/apps/tools/plink -file ~{inputfileDir}/~{inputFilePrefix} --freq --missing --hardy --out result
    else
    echo "is_check_sex must be one of T or F."
    exit 111
    fi
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile1 = "result.hwe"
  File outFile2 = "result.lmiss"
  File outFile3 = "result.imiss"
  File outFile4 = "result.sexcheck"
  File outFile5 = "result.frq"

  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_zhikongjisuan
}

