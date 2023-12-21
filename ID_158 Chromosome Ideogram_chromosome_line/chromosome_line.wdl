task task_chromosome_line {
  String appBinDir
  String RLibPath
  String inputFile1
  String inputFile2
  String inputFile3
  String labeltype
  String outputFileName
  String cluster_config
  String mount_paths
  
  
  command <<<  
    set -o pipefail
    set -e
    cp ${appBinDir}/datacheck_v1.0 /usr/local/bin/
    datacheck_v1.0 -i ${inputFile1} -o inputFile1.txt -c true -d true -s 0
    datacheck_v1.0 -i ${inputFile2} -o inputFile2.txt -c true -d true -s 0
    datacheck_v1.0 -i ${inputFile3} -o inputFile3.txt -c true -d true -s 0
   ulimit -s unlimited
    Rscript ${appBinDir}/chromosome_line_docker.R ${RLibPath} inputFile1.txt inputFile2.txt inputFile3.txt ${labeltype} ${outputFileName}
	#  mkdir result
	#mv ${outputFileName}*.pdf result/
	#  tar -czvf result.tar.gz result
	
	  >>>

  output {
  File outFile = "${outputFileName}.pdf" 
  #File outFile = "result.tar.gz"
  }
 
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-r-base-4-2-0-v1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: true
    timeout: 600
  }
}
workflow henbio_wf {
  call task_chromosome_line
  output{
    task_chromosome_line.outFile
  }
}