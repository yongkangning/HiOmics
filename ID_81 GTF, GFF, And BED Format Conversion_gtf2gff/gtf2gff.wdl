version 1.0

task task_gtf2gff {
  input {
    String inPutFile
    String transType # gff2gtf gtf2gff gff2bed gtf2bed
    String resultFlie = "result." + sub(transType, "g[tf]f2", "")
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
    
    if [ "~{transType}" == "gff2gtf" ]; then
      agat_convert_sp_gff2gtf.pl -gff ~{inPutFile} -o ~{resultFlie}
    elif [ "~{transType}" == "gtf2gff" ]; then
      agat_convert_sp_gxf2gxf.pl -gff ~{inPutFile} --gvi 2.5 -o ~{resultFlie} --gvo 3
    elif [ "~{transType}" == "gff2bed" ]; then
      agat_convert_sp_gff2bed.pl --gff ~{inPutFile} -o ~{resultFlie}
    elif [ "~{transType}" == "gtf2bed" ]; then
      agat_convert_sp_gff2bed.pl --gff ~{inPutFile} -o ~{resultFlie}
    else
      echo "transType must be one of gff2gtf gtf2gff gff2bed gtf2bed."
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
  call task_gtf2gff
}