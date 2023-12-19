version 1.0

task task_svgTransform {
  input {
    String appBinDir
    String inFile
    String outType
    String outFile = sub(basename(inFile), ".svg", "." + outType)
    String docker_img = if outType == "pdf" then "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:svg2pdf-v1" else "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:svgexport-v1"
    String cluster_config
    String mount_paths
  }

  command <<<

    set -o pipefail
    set -e
        
    if [ ~{outType} == "pdf" ]
    then
        Rscript ~{appBinDir}/svgTransform_v1.0.R ~{inFile} ~{outFile}
    else
        svgexport ~{inFile} ~{outFile}
    fi
 
   >>>

  output {
    File resultFile = outFile
  }

  runtime {
    docker: docker_img
    timeout: 600
    cluster: cluster_config
    mounts: mount_paths
    # systemDisk: "cloud_ssd 40"
    # dataDisk: "cloud_ssd 250 /cromwell_root/"
  }
}
workflow henbio_wf {
  call task_svgTransform
}