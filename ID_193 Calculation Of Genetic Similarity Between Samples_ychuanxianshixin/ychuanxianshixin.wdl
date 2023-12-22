version 1.0

task task_ychuanxianshixin {
  input {
    String checkY
    String inputfileDir
    String inputFilePrefix
    String min
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    if [ "~{checkY}" == "T" ]; then
      rel_check="--rel-check"
    elif [ "~{checkY}" == "F" ]; then
      rel_check=""
    else
      echo "checkY must be one of T or F."
      exit 111
    fi
    /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --genome  ${rel_check} --min ~{min}
  >>>

  output {
    File outFile = "plink.genome"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 600
  }
}
workflow henbio_wf {
  call task_ychuanxianshixin
}
