version 1.0

task task_base {
  input {
    String metadata
    #String groupFile
    String fastqDir
    String barcode_left_length
    String barcode_rigth_length
    String primer_left_len
    String primer_rigth_len
    String uniques_max
    String minuniquesize
    String db
    String appBinDir
    String annotation_db
    String cluster_config
    String mount_paths
  }

  command <<<
    cpu_cores=$(nproc)

    
    local_path=$PWD
    oss_path=${local_path/\/cromwell_root/oss:/}
    oss_path=$(dirname "$oss_path")
    # echo "local_path: $local_path"
    # echo "oss_path: ${oss_path}"


    
    sed  "s/\s*$//g" ~{metadata} > metadata_temp1.tsv
    ~{appBinDir}/datacheck_v1.0 -i metadata_temp1.tsv -o metadata_temp2.tsv -c true -d true -s 0
    tail -n+2 metadata_temp2.tsv | awk -v FS='\t' -v OFS='\t' 'BEGIN{print "sampleID","forwardReads","reverseReads","Group"} {print $1,$2,$3,$4}' > metadata.tsv
    
    
    cat /dev/null > check_before_run_result.txt
    tail -n+2 metadata.tsv | while read line;
    do
        sample_id=`echo ${line} |  awk '{print $1}'`
        read1=`echo ${line} |  awk '{print $2}'`
        read2=`echo ${line} |  awk '{print $3}'`
        group=`echo ${line} |  awk '{print $4}'`

        
        transverse_line_count=$(echo "${sample_id} ${group}" | grep "-" |wc -l)
        if [ ${transverse_line_count} -gt 0  ];then
            echo "[ERRO] `date +'%Y-%m-%d %H:%M:%S'` " >>  check_before_run_result.txt
        fi

        
        if [ ! -f ~{fastqDir}/${read1} ]; then
            echo "[ERRO] `date +'%Y-%m-%d %H:%M:%S'` " >>  check_before_run_result.txt
        else
            
            ~{appBinDir}/pigz -t -p ${cpu_cores} ~{fastqDir}/${read1} > /dev/null 2>&1
            if [ $? -gt 0  ];then
              echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` ${read1}" >>  check_before_run_result.txt
            fi 
        fi
        if [ ! -f ~{fastqDir}/${read2} ]; then
            echo "[ERRO] `date +'%Y-%m-%d %H:%M:%S'` " >>  check_before_run_result.txt
        else
            
            ~{appBinDir}/pigz -t -p ${cpu_cores} ~{fastqDir}/${read2} > /dev/null 2>&1
            if [ $? -gt 0  ];then
              echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` ${read2}" >>  check_before_run_result.txt
            fi
        fi
    done

    set -eo pipefail
    erro_count=$(cat check_before_run_result.txt |wc -l)
    if [ ${erro_count} -gt 0  ];then
        echo ""
        cat check_before_run_result.txt
        exit 1111
    fi

    
    if [ "~{annotation_db}" == "silva" ]
    then
      annotation_db_file=~{db}/db/silva_16s_v123.fa
    elif [ "~{annotation_db}" == "rdp" ]
    then
      annotation_db_file=~{db}/db/rdp_16s_v18.fa
    else
      annotation_db_file=~{db}/db/silva_16s_v123.fa
    fi
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` annotation_db_file: `basename ${annotation_db_file}`"


    mkdir {temp,16_result}

    
    
    ~{appBinDir}/seqkit stat ~{fastqDir}/*.f*q.gz | sed s"#~{fastqDir}/##g" > 16_result/seq_stat.txt
    
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp 16_result/seq_stat.txt  ${oss_path}/call-task_ampliconSeq/
 
    echo "1-"
    echo "1.2 "
    
    tail -n+2 metadata.tsv | \
      rush -j ${cpu_cores} \
        -v fastqDir=~{fastqDir} \
        -v sample_name={1},fastq1={2},fastq2={3} \
        '
          vsearch --fastq_mergepairs {fastqDir}/{fastq1} \
            --reverse {fastqDir}/{fastq2} \
            --relabel {sample_name}. \
            --fastqout temp/{sample_name}.merged.fq
        '

    echo "1.3 "
    
    cat temp/*.merged.fq > temp/all_sample.fq

    echo "2-"
    
    
    stripleft=$(python -c "print(~{barcode_left_length} + ~{primer_left_len})")
    stripright=$(python -c "print(~{primer_rigth_len} + ~{barcode_rigth_length})")
    echo "stripleft:  ${stripleft}"
    echo "stripright: ${stripright}"

    vsearch --fastx_filter temp/all_sample.fq \
      --fastq_stripleft ${stripleft} \
      --fastq_stripright ${stripright} \
      --fastq_maxee_rate 0.01 \
      --fastaout temp/filtered.fa

    
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 3.1  Dereplicate"
    ## 3.1  Dereplicate
    ## minuniquesize 5 
    vsearch --derep_fulllength temp/filtered.fa \
      --minuniquesize ~{minuniquesize} --sizeout --relabel Uni_ \
      --output temp/uniques.fa

    uniq_count=`cat temp/uniques.fa | grep ">" | wc -l`
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` : ${uniq_count}"

    if [ $uniq_count -gt ~{uniques_max}  ];then
      echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` "
      cat temp/uniques.fa | grep ">" | head -~{uniques_max} | sed 's/>//' > seq_id
      ~{appBinDir}/seqkit grep -f seq_id temp/uniques.fa/uniques.fa > temp/new_uniques.fa
      mv -f temp/new_uniques.fa temp/uniques.fa/uniques.fa
    fi

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 3.2 (Cluster)OTU/(denoise)"
    
    vsearch --cluster_unoise temp/uniques.fa \
      --relabel ASV_ \
      --qmask none --sizein --sizeout \
      --centroids temp/ASV_seqs_raw.fa

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 3.3 "
    
    
    vsearch --uchime2_denovo temp/ASV_seqs_raw.fa \
      --nonchimeras temp/ASV_seqs.fa
    
    sed -i 's/;.*//' temp/ASV_seqs.fa

    
    
    #vsearch --uchime_ref temp/ASV_seqs_raw.fa \
    #-db ~{db}/db/silva_16s_v123.fa \
    #--nonchimeras temp/ASV_seqs.fa

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 3.4 "
    mkdir -p 16_result/1-denoise/raw
    cp -f temp/ASV_seqs.fa 16_result/1-denoise/raw/ASV_seqs.fa

    ## id(0.97)：
    vsearch --usearch_global temp/filtered.fa \
    --db 16_result/1-denoise/raw/ASV_seqs.fa \
    --id 0.97 \
    --threads ${cpu_cores} \
    --otutabout 16_result/1-denoise/raw/ASV_table.tsv

    
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 4.1 "
    ## silva_16s_v123.fa  rdp_16s_v18.fa
    vsearch --sintax 16_result/1-denoise/raw/ASV_seqs.fa \
      --db ${annotation_db_file} \
      --sintax_cutoff 0.1 \
      --tabbedout 16_result/1-denoise/raw/ASV.sintax

    
    
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 4.2 "
    Rscript ~{db}/script/otutab_filter_nonBac.R \
      --input 16_result/1-denoise/raw/ASV_table.tsv \
      --taxonomy 16_result/1-denoise/raw/ASV.sintax \
      --output 16_result/1-denoise/ASV_table.tsv \
      --stat 16_result/1-denoise/ASV_nonBac.stat \
      --discard 16_result/1-denoise/ASV.sintax.discard

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 4.3 "
    cut -f 1 16_result/1-denoise/ASV_table.tsv | tail -n+2 > 16_result/1-denoise/otutab.id
    ~{appBinDir}/seqkit grep -f 16_result/1-denoise/otutab.id  16_result/1-denoise/raw/ASV_seqs.fa -w 80 -o 16_result/1-denoise/ASV_seqs.fa

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 4.4 "
    # 4.4 
    awk 'NR==FNR{a[$1]=$0}NR>FNR{print a[$1]}' \
      16_result/1-denoise/raw/ASV.sintax 16_result/1-denoise/otutab.id > 16_result/1-denoise/ASV.sintax

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 4.5 "
    # 2.4 
   
    Rscript ~{db}/script/otutab_rare.R --input 16_result/1-denoise/ASV_table.tsv \
      --depth 0 --seed 1 \
      --normalize 16_result/1-denoise/ASV_table_rare.tsv \
      --output 16_result/1-denoise/vegan.tsv


    
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp -r 16_result/1-denoise/  ${oss_path}/call-task_ampliconSeq/1-denoise

    
    mkdir 16_result/2-taxonomy
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 5.1 "
    
    cut -f 1,4 16_result/1-denoise/ASV.sintax | sed 's/\td/\tk/;s/:/__/g;s/,/;/g;s/"//g' > 16_result/2-taxonomy/taxonomy_temp.tsv

    
    awk 'BEGIN{OFS=FS="\t"}{delete a; a["k"]="Unassigned";a["p"]="Unassigned";a["c"]="Unassigned";a["o"]="Unassigned";a["f"]="Unassigned";a["g"]="Unassigned";a["s"]="Unassigned";\
      split($2,x,";");for(i in x){split(x[i],b,"__");a[b[1]]=b[2];} \
      print $1,a["k"],a["p"],a["c"],a["o"],a["f"],a["g"],a["s"];}' \
      16_result/2-taxonomy/taxonomy_temp.tsv > 16_result/2-taxonomy/ASV_temp.tax

    sed 's/;/\t/g;s/.__//g;' 16_result/2-taxonomy/ASV_temp.tax | cut -f 1-8 | \
    sed '1 s/^/OTUID\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n/' > 16_result/2-taxonomy/taxonomy.tsv
    rm -f 16_result/2-taxonomy/taxonomy_temp.tsv 16_result/2-taxonomy/ASV_temp.tax

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` "
    
    for i in p c o f g;do
      usearch -sintax_summary 16_result/1-denoise/ASV.sintax \
      -otutabin 16_result/1-denoise/ASV_table_rare.tsv -rank ${i} \
      -output 16_result/2-taxonomy/sum_${i}.txt
    done
    sed -i 's/(//g;s/)//g;s/\"//g;s/\#//g;s/\/Chloroplast//g' 16_result/2-taxonomy/sum_*.txt

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 5.3 "
    
    echo 'p c o f g' | tr ' ' '\n' | \
      rush -k \
        -v db=~{db} \
        -v metadata=metadata.tsv \
      '
        Rscript {db}/script/tax_stackplot.R \
          --input 16_result/2-taxonomy/sum_{}.txt --design {metadata} \
          --group Group --output 16_result/2-taxonomy/sum_{}.stackplot \
          --legend 8 --width 178 --height 118
      '

    
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp -r 16_result/2-taxonomy/  ${oss_path}/call-task_ampliconSeq/2-taxonomy

    
    mkdir -p 16_result/3-diversity/alpha
    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 6.1 "
    usearch -alpha_div 16_result/1-denoise/ASV_table_rare.tsv \
      -output 16_result/3-diversity/alpha/alpha.txt

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 6.2 "
    usearch -alpha_div_rare 16_result/1-denoise/ASV_table_rare.tsv \
      -output 16_result/3-diversity/alpha/alpha_rare.txt \
      -method without_replacement

    
    sed -i "s/-/\t0.0/g" 16_result/3-diversity/alpha/alpha_rare.txt

    
    Rscript ~{db}/script/alpha_rare_curve.R \
      --input 16_result/3-diversity/alpha/alpha_rare.txt --design metadata.tsv \
      --group Group --output 16_result/3-diversity/alpha \
      --width 120 --height 59

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 6.3. "
    
    
    Rscript ~{db}/script/otu_mean.R \
      --input 16_result/1-denoise/ASV_table.tsv \
      --metadata metadata.tsv \
      --group Group --thre 0 \
      --scale TRUE --zoom 100 --all TRUE --type mean \
      --output 16_result/3-diversity/alpha/ASV_table_mean.txt

    
    awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=2;i<=NF;i++) a[i]=$i;} \
      else {for(i=2;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
      16_result/3-diversity/alpha/ASV_table_mean.txt > 16_result/3-diversity/alpha/ASV_group_exist.txt

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 6.4 "
    
    echo -e "-a\n-b\n-c\n-d\n-g" > a.txt
    tail -n+2 metadata.tsv | awk '{print $4}' | sort | uniq |head -5 > b.txt
    # -a WT -b KO -c OE
    groups=`awk -v ORS=" " 'NR==FNR{a[i]=$0;i++}NR>FNR{print a[j]" "$0;j++}' a.txt b.txt`
    bash ~{db}/script/sp_vennDiagram.sh \
      -f 16_result/3-diversity/alpha/ASV_group_exist.txt \
      ${groups} \
      -w 3 -u 3 \
      -p "groups"

    mv 16_result/3-diversity/alpha/ASV_group_exist.txt.groups.vennDiagram.pdf 16_result/3-diversity/alpha/alpha_vennDiagram.pdf
    rm -f 16_result/3-diversity/alpha/ASV_group_exist.txt.groups.vennDiagram.r


    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 6.5 "
    head -n1 16_result/1-denoise/vegan.tsv | cut -f 2- | tr '\t' '\n' | \
    rush -k \
      -v db=~{db} \
      -v metadata=metadata.tsv \
      '
        Rscript {db}/script/alpha_boxplot.R --alpha_index {} \
          --input 16_result/1-denoise/vegan.tsv --design {metadata} \
          --group Group --output 16_result/3-diversity/alpha/alpha \
          --width 178 --height 118
      '

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` "
    head -n1 16_result/1-denoise/vegan.tsv|cut -f 2- | tr '\t' '\n' | \
    rush -k \
      -v db=~{db} \
      -v metadata=metadata.tsv \
    '
      Rscript {db}/script/alpha_barplot.R --alpha_index {} \
        --input 16_result/1-denoise/vegan.tsv --design {metadata} \
        --group Group --output 16_result/3-diversity/alpha/ \
        --width 178 --height 118
    '

    # 7 Beta diversity
    mkdir -p 16_result/3-diversity/beta

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 7.1 "
    usearch -cluster_agg  16_result/1-denoise/ASV_seqs.fa -treeout 16_result/3-diversity/beta/ASV.tree

    echo "[INFO] `date +'%Y-%m-%d %H:%M:%S'` 7.2 ：bray_curtis, euclidean, jaccard, manhatten, unifrac"
    usearch -beta_div 16_result/1-denoise/ASV_table_rare.tsv -tree 16_result/3-diversity/beta/ASV.tree \
      -filename_prefix 16_result/3-diversity/beta/beta_

    echo 'bray_curtis euclidean jaccard manhatten unifrac'| tr ' ' '\n' | \
      rush -k -j 5 \
      -v db=~{db} \
      -v metadata=metadata.tsv \
      '
        

      '

    # 8
    mkdir -p 16_result/4-lefse/
    echo "8.1"
    Rscript ~{db}/script/format2lefse.R \
      --input 16_result/1-denoise/ASV_table.tsv \
      --taxonomy 16_result/2-taxonomy/taxonomy.tsv \
      --design metadata.tsv \
      --group Group \
      --threshold 0.4 \
      --output 16_result/4-lefse/LEfSe

    
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp -r 16_result/3-diversity  ${oss_path}/call-task_ampliconSeq/3-diversity
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp -r 16_result/4-lefse  ${oss_path}/call-task_ampliconSeq/4-lefse
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp stdout  ${oss_path}/call-task_ampliconSeq/
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp stderr  ${oss_path}/call-task_ampliconSeq/
    
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp oss://henbio/henbio_web/public/workflow/16s_pipeline/README.txt  ${oss_path}/call-task_ampliconSeq/
   >>>

  output {
    File LEfSe1 = "16_result/4-lefse/LEfSe.txt"
    File LEfSe2 = "16_result/4-lefse/LEfSe2.txt"
    File ASV_seq = "16_result/1-denoise/ASV_seqs.fa"
    File ASV_table = "16_result/1-denoise/ASV_table.tsv"
  }

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:henbio-16s-v4"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 86400
  }
}

task task_lefse {
  input {
    File lefse_in
    String appBinDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e

    mkdir lefse_res
    format_input.py ~{lefse_in} lefse_res/lefse_in.txt -c 1  -o 1000000
    run_lefse.py lefse_res/lefse_in.txt lefse_res/lefse_LDA.tsv -l 2 -w 0.05
    plot_res.py lefse_res/lefse_LDA.tsv lefse_res/lefse_LDA.pdf --format pdf
    plot_cladogram.py lefse_res/lefse_LDA.tsv lefse_res/lefse_cladogram.pdf --format pdf

    
    local_path=$PWD
    oss_path=${local_path/\/cromwell_root/oss:/}
    oss_path=$(dirname "$oss_path")
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp -r lefse_res  ${oss_path}/call-task_ampliconSeq/4-lefse/lefse_res

   >>>

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:lefse-1-0-0"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 3600
  }
}

task task_picrust2 {
  input {
    File otuFastaFile
    File otuAbundanceFile
    String appBinDir
    String cluster_config
    String mount_paths
  }

  command <<<
    set -o pipefail
    set -e
    cpu_cores=$(nproc)

    source activate picrust2
    picrust2_pipeline.py -s ~{otuFastaFile} -i ~{otuAbundanceFile} -o picrust2 -p ${cpu_cores}

    
    local_path=$PWD
    oss_path=${local_path/\/cromwell_root/oss:/}
    oss_path=$(dirname "$oss_path")
    ~{appBinDir}ossutil64 -c ~{appBinDir}ossutilconfig  -f cp -r picrust2  ${oss_path}/call-task_ampliconSeq/5-picrust2

   >>>

  runtime {
    docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:picrust2-2-5-1"
    cluster: cluster_config
    mounts: mount_paths
    autoReleaseJob: false
    timeout: 18000
  }
}

workflow henbio_wf {
  input {
    String metadata
    #String groupFile
    String fastqDir
    String barcode_left_length
    String barcode_rigth_length
    String primer_left_len
    String primer_rigth_len
    String uniques_max = 20000
    String minuniquesize = 5
    String db
    String appBinDir
    String annotation_db
    String base_cluster_config
    String lefse_cluster_config
    String picrust2_cluster_config
    String mount_paths
  }
  call task_base {
    input:
      metadata = metadata,
      fastqDir = fastqDir,
      barcode_left_length = barcode_left_length,
      barcode_rigth_length = barcode_rigth_length,
      primer_left_len = primer_left_len,
      primer_rigth_len = primer_rigth_len,
      uniques_max = uniques_max,
      minuniquesize = minuniquesize,
      db = db,
      appBinDir = appBinDir,
      annotation_db = annotation_db,
      cluster_config = base_cluster_config,
      mount_paths = mount_paths
  }

  call task_lefse {
    input:
      lefse_in = task_base.LEfSe2,
      appBinDir = appBinDir,
      cluster_config = lefse_cluster_config,
      mount_paths = mount_paths
  }

  call task_picrust2 {
    input:
      otuFastaFile = task_base.ASV_seq,
      otuAbundanceFile = task_base.ASV_table,
      appBinDir = appBinDir,
      cluster_config = picrust2_cluster_config,
      mount_paths = mount_paths
  }

}