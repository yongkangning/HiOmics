version 1.0

task task_ychuanshanweixiaoying {
  input {
    String type
    String inputfileDir
    String inputFilePrefix
    String inputFile2
    String inputFile3
    String epi1
    String epi2
    String outFile
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    if [ "~{type}" == "1" ]; then
      /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --pheno ~{inputFile2} --epistasis --epi1 ~{epi1} --noweb --out ~{outFile}
    elif [ "~{type}" == "2" ]; then
     /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --pheno ~{inputFile2} --epistasis --set-test --set ~{inputFile3} --epi1 ~{epi1} --epi2 ~{epi2} --noweb --out ~{outFile}
    elif [ "~{type}" == "3" ]; then
      /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --pheno ~{inputFile2} --epistasis --set-test --set ~{inputFile3} --epi1 ~{epi1} --epi2 ~{epi2} --noweb --out ~{outFile}
    elif [ "~{type}" == "4" ]; then
      /henbio/henbio_web/public/apps/tools/plink --file ~{inputfileDir}/~{inputFilePrefix} --pheno ~{inputFile2} --epistasis --set-test --set ~{inputFile3} --set-by-all --epi1 ~{epi1} --epi2 ~{epi2} --noweb --out ~{outFile}
    else
      echo "type must be one of 1 2 3 4."
      exit 111
    fi
    mkdir result
    tar -zcvf result.tar.gz result
  >>>

  output {
    Array[File] outFile = glob("result.epi*")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_ychuanshanweixiaoying
}
