version 1.0

task task_drawKrona {
  input {
    String appBinDir
    String inputFile
    String outputFile

    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    if test -d ~{inputFile}
    then
      echo "This a dir"
      find ~{inputFile}/ -type f | while read line;
      do
        file_name=$(basename ${line})
        echo ${file_name}
        echo "file_name: ${file_name}"
        out_prefix=${file_name%.*}
        python ~{appBinDir}/drawKrona.py -r ~{inputFile}/${file_name} -o ${out_prefix}.krona
      done
      ktImportText $(echo $(find ./ -type f -name "*.krona" | sort)) -o all_krona.html -n root

    else
      echo "This is a file."
      file_name=$(basename ~{inputFile})
      echo "file_name: ${file_name}"
      out_prefix=${file_name%.*}
      python ~{appBinDir}/drawKrona.py -r ~{inputFile} -o ${out_prefix}.krona
      ktImportText ${out_prefix}.krona -o ~{outputFile} -n root
    fi
   
   >>>

  output {
    File outFile = outputFile
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:conda-with-krona-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_drawKrona
}