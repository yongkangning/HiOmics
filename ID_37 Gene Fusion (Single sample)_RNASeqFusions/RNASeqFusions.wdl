version 1.0

task task_RNASeqFusions {
  input {
    String fastq1
    String fastq2
    String species
    String cluster_config
    String mount_paths
  }
  command <<<

    set -o pipefail
    set -e
    # what species
    if [ "~{species}" == "Homo_sapiens" ]
    then
      ref=Homo_sapiens.GRCh38.dna.primary_assembly.fa
      ref=Homo_sapiens.GRCh38.dna.primary_assembly.fa
      gtf=Homo_sapiens.GRCh38.107.gtf
      blacklist=blacklist_hg38_GRCh38_v2.3.0.tsv.gz
      known_fusions=known_fusions_hg38_GRCh38_v2.3.0.tsv.gz
      protein_domains=protein_domains_hg38_GRCh38_v2.3.0.gff3
      cytobands=cytobands_hg38_GRCh38_v2.3.0.tsv
    elif [ "~{species}" == "Mus_musculus" ]
    then
      ref=Mus_musculus.GRCm39.dna.primary_assembly.fa.gz
      gtf=Mus_musculus.GRCm39.107.gtf.gz
      blacklist=blacklist_mm39_GRCm39_v2.3.0.tsv.gz
      known_fusions=known_fusions_mm39_GRCm39_v2.3.0.tsv.gz
      protein_domains=protein_domains_mm39_GRCm39_v2.3.0.gff3
      cytobands=cytobands_mm39_GRCm39_v2.3.0.tsv
    else
        echo "unknow species: ~{species}, only support Homo_sapiens and Mus_musculus"
        exit 123
    fi
    # star and generate fusions
    echo "run star and generate fusions:"
    time /arriba_v2.3.0/run_arriba.sh \
      /henbio/henbio_web/public/db/reference/~{species}/Genome_Index_STAR \
      /henbio/henbio_web/public/db/reference/~{species}/$gtf \
      /henbio/henbio_web/public/db/reference/~{species}/$ref \
      /henbio/henbio_web/public/db/arriba/database/$blacklist \
      /henbio/henbio_web/public/db/arriba/database/$known_fusions \
      /henbio/henbio_web/public/db/arriba/database/$protein_domains \
      12 \
      ~{fastq1} \
      ~{fastq2}
    ## draw draw_fusions
    echo "draw draw_fusions:"
    time Rscript /arriba_v2.3.0/draw_fusions.R \
      --annotation=/henbio/henbio_web/public/db/reference/~{species}/$gtf \
      --fusions=fusions.tsv \
      --output=fusions.pdf \
      --proteinDomains=/henbio/henbio_web/public/db/arriba/database/$protein_domains \
      --alignments=Aligned.sortedByCoord.out.bam \
      --cytobands=/henbio/henbio_web/public/db/arriba/database/$cytobands
    # move the result files to the output dir
    mkdir result/
    mv fusions.tsv fusions.discarded.tsv fusions.pdf Log.final.out SJ.out.tab  result/

  >>>

  output {
    Array[File] resultFilse = ["result/fusions.tsv","result/fusions.discarded.tsv","result/fusions.pdf","result/Log.final.out","result/SJ.out.tab"]
    # Array[File] resultFilse = ["fusions.tsv","fusions.discarded.tsv","fusions.pdf","Log.final.out","SJ.out.tab"]
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:uhrigs-arriba-2.3.0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 18000
  }
}
workflow henbio_wf {
  call task_RNASeqFusions
}