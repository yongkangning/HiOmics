version 1.0

task task_phyml {
  input {
    String inputFile
    String inputFileBaseName=basename(inputFile)
    String type
    String p
    String d
    String b
    String m
    String f
    String v
    String a
    String o

    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    cp ~{inputFile} ./
    if [ "~{type}" == "type1" ]; then
      /henbio/henbio_web/public/apps/tools/PhyML -i ~{inputFileBaseName} -p ~{p} -d ~{d} -b ~{b} -m ~{m} -f ~{f} -v ~{v} -a ~{a} -o ~{o}
    elif [ "~{type}" == "type2" ]; then
      /henbio/henbio_web/public/apps/tools/PhyML -i ~{inputFileBaseName} -p ~{p} -d ~{d} -b ~{b} -m ~{m} -f ~{f} -v ~{v} -o ~{o}
    elif [ "~{type}" == "type3" ]; then
      /henbio/henbio_web/public/apps/tools/PhyML -i ~{inputFileBaseName} -d ~{d} -b ~{b} -m ~{m} -f ~{f} -v ~{v} -a ~{a} -o ~{o}
    elif [ "~{type}" == "type4" ]; then
      /henbio/henbio_web/public/apps/tools/PhyML -i ~{inputFileBaseName} -d ~{d} -b ~{b} -m ~{m} -f ~{f} -v ~{v} -o ~{o}
    else
      echo "type must be one of type1 type2 type3 type4."
      exit 111
    fi
   >>>

  output {
    File outFile1 = "~{inputFileBaseName}_phyml_tree.txt"
    File outFile2 = "~{inputFileBaseName}_phyml_boot_trees.txt"
    File outFile3 = "~{inputFileBaseName}_phyml_boot_stats.txt"
    File outFile4 = "~{inputFileBaseName}_phyml_stats.txt"
}
  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 108000
  }
}
workflow henbio_wf {
  call task_phyml
}

