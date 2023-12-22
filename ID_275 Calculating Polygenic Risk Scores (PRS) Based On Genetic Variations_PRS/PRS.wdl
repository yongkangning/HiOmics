version 1.0

task task_PRS {
  input {
    String appDir
    String base
    String inputfileDir
    String inputFilePrefix
    String stat
    String binary_target
    String pheno
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    Rscript ~{appDir}/PRSice.R  --prsice /henbio/henbio_web/public/apps/tools/PRSice_linux --base ~{base} --target ~{inputfileDir}/~{inputFilePrefix} --thread 1 --stat ~{stat} --binary-target ~{binary_target} --pheno ~{pheno} --out result
    mkdir output
    mv *.best output/
    mv *.summary output/
    mv *.png output/
    mv *.prsice output/
    tar -czvf result.tar.gz output

   >>>

  output {
    File outFile = "result.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-r-base-4-2-0-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_PRS
}