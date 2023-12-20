version 1.0

task task_genbank2gff3 {
  input {
    String inputFile
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if test -d ~{inputFile}
    then
      echo "This a dir"
      bp_genbank2gff3 --split --dir ~{inputFile} --out result
    else
      echo "This is a file."
      bp_genbank2gff3 --split ~{inputFile} --out result
    fi
    # 打包压缩
    # 删除fa格式的序列文件
    rm -f result/*.fa
    tar -zcvf result.tar.gz result
   
   >>>

  output {
    File outFiles = "result.tar.gz"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:bioperl-v1-7-2"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_genbank2gff3
}