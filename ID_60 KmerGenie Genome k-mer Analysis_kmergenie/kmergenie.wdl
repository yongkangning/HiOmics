version 1.0

task task_kmergenie {
  input {
    String fastqRead1
    String fastqRead2
    String minKmer
    String maxKmer
    String step
    String mode    
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    mkdir /kmergenie_tmp && export TMPDIR=/kmergenie_tmp  
    echo -e "~{fastqRead1}\n~{fastqRead2}" > file_list.txt
    kmergenie file_list.txt -o result -l ~{minKmer} -k ~{maxKmer} -s ~{step} -t 8 ~{mode}
   >>>

  output {
    Array[File] out_pdf = glob("result*")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:jdselwyn-kmergenie-1-7051"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 7200
  }
}

workflow henbio_wf {
  call task_kmergenie
}