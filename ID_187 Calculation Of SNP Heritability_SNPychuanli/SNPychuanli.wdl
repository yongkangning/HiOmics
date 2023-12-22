version 1.0

task task_SNPychuanli {
  input {
    String inputfileDir
    String inputFilePrefix
    String inputfile1
    String method
    String outFile
    String cluster_config
    String mount_paths
}

  command <<<
    set -o pipefail
    set -e
    if [ "~{method}" == "0" ]; then
    /henbio/henbio_web/public/apps/tools/gcta-1.94.1 --bfile ~{inputfileDir}/~{inputFilePrefix} --make-grm --make-grm-alg ~{method} --out g1
    /henbio/henbio_web/public/apps/tools/gcta-1.94.1 --grm g1 --pheno ~{inputfile1} --reml --out ~{outFile}
    elif [ "~{method}" == "1" ]; then
    /henbio/henbio_web/public/apps/tools/gcta-1.94.1 --bfile ~{inputfileDir}/~{inputFilePrefix} --make-grm --make-grm-alg ~{method} --out g2
    /henbio/henbio_web/public/apps/tools/gcta-1.94.1 --grm g2 --pheno  ~{inputfile1}  --reml --out ~{outFile}
    else
    echo "method must be one of 0 or 1."
    exit 111
    fi
    #mkdir result
    #tar -czvf result.tar.gz result
    >>>


  output {
  File outFile = "result.hsq"
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
  call task_SNPychuanli
}
