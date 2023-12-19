version 1.0

task task_drawKrona {
  input {
    String inputFile
    String outputFile

    String ossTargetDir

    String appBinDir
    String RLibPath
    String cromwellDir
  }

  command <<<
    set -o pipefail
    set -e

    # download input from oss
    ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp oss:/~{inputFile} ./inputFile1.txt

    if test -d inputFile1.txt
    then
      echo "This a dir"
      find inputFile1.txt/ -type f | while read line;
      do
        file_name=$(basename ${line})
        echo ${file_name}
        echo "file_name: ${file_name}"
        out_prefix=${file_name%.*}
        python ~{appBinDir}/drawKrona.py -r inputFile1.txt/${file_name} -o ${out_prefix}.krona
      done
      ktImportText $(echo $(find ./ -type f -name "*.krona" | sort)) -o all_krona.html -n root

    else
      echo "This is a file."
      file_name=$(basename inputFile1.txt)
      echo "file_name: ${file_name}"
      out_prefix=${file_name%.*}
      python ~{appBinDir}/drawKrona.py -r inputFile1.txt -o ${out_prefix}.krona
      ktImportText ${out_prefix}.krona -o ~{outputFile} -n root
    fi
    # update result to oss
    task_id=`echo $PWD | sed -e s"#~{cromwellDir}/##" -e s"#/execution##"`
    ls ~{outputFile} stdout stderr | xargs -P 3 -I {}  ~{appBinDir}/ossutil64 -c ~{appBinDir}/ossutilconfig  cp -f {} oss:/~{ossTargetDir}/${task_id}/
   
   >>>

  output {
    File outFile = outputFile
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:conda-with-krona-v1"
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_drawKrona
}