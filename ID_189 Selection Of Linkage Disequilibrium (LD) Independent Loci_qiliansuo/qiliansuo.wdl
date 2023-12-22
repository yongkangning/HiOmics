version 1.0

task task_qiliansuo {
  input {
    String type
    String inputfileDir
    String inputFilePrefix
    String chaunkou
    String qianyu
    String shanchu
    String r2yuzhe
    String cluster_config
    String mount_paths
}

  command <<<
    set -o pipefail
    set -e
    if [ "~{type}" == "type1" ]; then
    /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --indep ~{chaunkou} ~{qianyu} ~{shanchu} --out result
    elif [ "~{type}" == "type2" ]; then
    /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --indep-pairwise ~{chaunkou} ~{qianyu} ~{r2yuzhe}  --out result
    else
    echo "type must be one of type1 or type2."
    exit 111
    fi
    #mkdir result
    #tar -zcvf result.tar.gz result
    >>>


  output {
    Array[File] outFile = glob("result*")
}

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-r-base-4-2-0-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_qiliansuo
}
