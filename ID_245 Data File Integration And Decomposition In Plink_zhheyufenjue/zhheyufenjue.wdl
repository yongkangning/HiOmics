version 1.0

task task_zhheyufenjue {
  input {
    String inputfileDir
    String inputFilePrefix
    String data_dir
    String mergelist
    String type
    String thin
    String chr
    String from
    String to
    String mysnps
    String snp
    String window
    String myid
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    cat ~{mergelist} | sed  '/^$/d' | sed "s#^#~{data_dir}/#g" > merge.txt
    if [ "~{type}" == "type2" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --thin ~{thin} --make-bed --out result
    elif [ "~{type}" == "type3" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --chr ~{chr}  --make-bed --out result
    elif [ "~{type}" == "type4" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --chr ~{chr} --from-kb ~{from} --to-kb ~{to} --make-bed --out result
    elif [ "~{type}" == "type5" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --extract ~{mysnps} --make-bed --out result
    elif [ "~{type}" == "type6" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --snp ~{snp} --window ~{window} --make-bed --out result
    elif [ "~{type}" == "type7" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --exclude ~{mysnps} --make-bed --out result
    elif [ "~{type}" == "type8" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --keep ~{myid}  --make-bed --out result
    elif [ "~{type}" == "type9" ]; then
    /henbio/henbio_web/public/apps/tools/plink --bfile ~{inputfileDir}/~{inputFilePrefix} --merge-list merge.txt --make-bed --out mynewdata
    /henbio/henbio_web/public/apps/tools/plink --bfile mynewdata --remove ~{myid}  --make-bed --out result
    else
    echo "type must be one of type2 type3 type4 type5 type6 type7 type8 type9."
    exit 111
    fi
    #mkdir result
    #tar -czvf result.tar.gz result
   >>>

  output {
  File outFile1 = "result.bed"
  File outFile2 = "result.bim"
  File outFile3 = "result.fam"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-samtools-1-15"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 600
  }
}
workflow henbio_wf {
  call task_zhheyufenjue
}

