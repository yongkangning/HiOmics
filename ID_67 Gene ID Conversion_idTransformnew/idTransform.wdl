version 1.0

task task_idTransform {
  input {
    String appBinDir
    String inputFile
    String outputFile
    String dbPath
    String species
    String query_column
    Map[String, Boolean] need
    String need_gene_stable_id = need["gene_stable_id"]
    String need_gene_name = need["gene_name"]
    String need_gene_synonym = need["gene_synonym"]
    String need_ncbi_gene_id = need["ncbi_gene_id"]
    String need_ncbi_gene_description = need["ncbi_gene_description"]
    String cluster_config
    String mount_paths
  }

  command <<<
    export PYTHONPATH=/henbio/henbio_web/public/python/python3.9/site-packages
    python ~{appBinDir}/idTransform.py ~{inputFile} ~{outputFile} ~{dbPath}/~{species}.db ~{query_column} ~{need_gene_stable_id} ~{need_gene_name} ~{need_gene_synonym} ~{need_ncbi_gene_id} ~{need_ncbi_gene_description}
  >>>

  output {
    File outFile = outputFile
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:python-3.9.12"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}
workflow henbio_wf {
  call task_idTransform
}