version 1.0

task task_fixgff3 {
  input {
    String inPutFile
    String fileType
    String resultFlie = "fixed_" + basename(inPutFile)
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    if [ "~{fileType}" == "gff" ]; then
      agat_convert_sp_gxf2gxf.pl -gff ~{inPutFile} -o ~{resultFlie}
    elif [ "~{fileType}" == "gtf" ]; then
      #  2.5 is suposed to be gtf
      agat_convert_sp_gxf2gxf.pl -gff ~{inPutFile} --gvi 2.5 -o ~{resultFlie} --gvo 2.5
    else
      echo "fileType must be one of gff and gtf."
      exit 111
    fi

   >>>

  output {
    File outFile = resultFlie
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-transform-tools-v2-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}
workflow henbio_wf {
  call task_fixgff3
}