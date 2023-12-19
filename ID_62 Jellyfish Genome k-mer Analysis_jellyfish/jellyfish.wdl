version 1.0

task task_jellyfish {
  input {
    String fastqRead1
    String fastqRead2
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    filename1=~{fastqRead1}
    filename2=~{fastqRead2}
    suffix1="${filename1##*.}"
    suffix2="${filename1##*.}"
    if [ "${suffix1}" == "gz" -a "${suffix2}" == "gz" ]
    then
      echo "gz filles."
          
      for file in ~{fastqRead1} ~{fastqRead2}
      do
        { gunzip -c ${file} > ./$(basename ${file} .gz)
        }&
      done
      wait
      jellyfish count -C -m 21 -s 1000000000 -t 10 -o reads.jf $(basename ~{fastqRead1} .gz) $(basename ~{fastqRead2} .gz)
    else
      jellyfish count -C -m 21 -s 1000000000 -t 10 -o reads.jf  ~{fastqRead1} ~{fastqRead2}
    fi
    # gunzip -c ~{fastqRead1} > ./gunzip_R1.fq
    # gunzip -c ~{fastqRead2} > ./gunzip_R2.fq
    # jellyfish count -C -m 21 -s 1000000000 -t 10 -o reads.jf gunzip_R1.fq gunzip_R2.fq

    jellyfish histo -t 10 reads.jf > reads.histo
   >>>

  output {
    File out_histo = "reads.histo"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:jellyfish-2-2-10"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}


task task_genomescope {
  input {
    String appBinDir
    File histoFile
    String readLength
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    Rscript ~{appBinDir}/genomescope.R ~{histoFile} 21 ~{readLength} result
    cp ~{histoFile} result/reads.histo
   >>>

  output {
    File readsHistoFile = "result/reads.histo"
    File plotFile = "result/plot.png"
    File plotLogFile = "result/plot.log.png"
    File modelFile = "result/model.txt"
    File summaryFile = "result/summary.txt"
    File progressFile = "result/progress.txt"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:rstudio-r-base-4.2.0-focal"
    cluster: "OnDemand bcs.es.c.large img-ubuntu-vpc"
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 600
  }
}

workflow henbio_wf {
  input {
    String fastqRead1
    String fastqRead2
    String readLength
    String cluster_config
    String mount_paths
  }
  call task_jellyfish {
    input: 
      fastqRead1 = fastqRead1,
      fastqRead2 = fastqRead2,
      cluster_config = cluster_config,
      mount_paths = mount_paths
  }
  call task_genomescope {
    input: 
      histoFile = task_jellyfish.out_histo,
      readLength = readLength,
      mount_paths = mount_paths
  }
}