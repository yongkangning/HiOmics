version 1.0

task task_trans_plink {
  input {
    String inputfileDir
    String inputFilePrefix # gff2gtf gtf2gff gff2bed gtf2bed
    String type
    String outFile
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e

    mkdir result
    if [ "~{type}" == "recode2makebed" ]; then
      /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --make-bed --out ~{outFile}
    elif [ "~{type}" == "recode2transpose" ]; then
      /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --recode --transpose --out ~{outFile}
    elif [ "~{type}" == "makebed2recode" ]; then
      /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --recode --out ~{outFile}
    elif [ "~{type}" == "makebed2transpose" ]; then
      /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --recode --transpose --out ~{outFile}
    elif [ "~{type}" == "transpose2recode" ]; then
      /henbio/henbio_web/public/apps/tools/plink --tfile ~{inputfileDir}/~{inputFilePrefix} --recode --out ~{outFile}
    elif [ "~{type}" == "transpose2mabebed" ]; then
      /henbio/henbio_web/public/apps/tools/plink --tfile ~{inputfileDir}/~{inputFilePrefix} --make-bed --out ~{outFile}
    else
      echo "type must be one of recode2makebed recode2transpose makebed2recode makebed2transpose transpose2recode transpose2mabebed."
      exit 111
    fi
    tar -czvf result.tar.gz result
   >>>

  output {
    Array[File] outFile = glob("result.*")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-transform-tools-v2-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_trans_plink
}