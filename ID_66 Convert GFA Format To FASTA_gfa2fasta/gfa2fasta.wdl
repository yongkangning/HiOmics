version 1.0

task task_gfa2fasta {
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
      find ~{inputFile} -type f -name "*.gfa" | while read line;
      do
        inFileName=$(basename $line)
        outFileName=${inFileName%.*}
        awk '/^S/{print ">"$2"\n"$3}' ${line} | fold -w 80 > ${outFileName}.fa
      done
    else
      echo "This is a file."
      outFileName=~{inputFile}
      outFileName=$(basename $outFileName .gfa)
      # outFileName=${outFileName%.*}
      awk '/^S/{print ">"$2"\n"$3}' ~{inputFile} | fold -w 80 > ${outFileName}.fa
    fi
   
   >>>

  output {
    Array[File] outFiles = glob("*.fa")
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 86400
  }
}
workflow henbio_wf {
  call task_gfa2fasta
}