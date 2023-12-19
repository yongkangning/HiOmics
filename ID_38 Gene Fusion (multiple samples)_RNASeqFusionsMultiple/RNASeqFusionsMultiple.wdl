version 1.0

task test_sample_files {
    input {
        String metaFile
        Array[Array[String]] dataInfo = read_tsv("oss:/" + metaFile)
        String dataDir = sub(metaFile, "/" + basename(metaFile), "")
        String mount_paths
    }

    command <<<

        set -o pipefail
        set -e
        cat ~{metaFile} | while read line;
        do
            sampleId=`echo $line | awk '{print $1}'`
            read1=`echo $line | awk '{print $2}'`
            read2=`echo $line | awk '{print $3}'`

            if [ -f "~{dataDir}/${read1}" -a -f "~{dataDir}/${read2}" ];then
                echo "read1: ~{dataDir}/${read1}"
                echo "read2: ~{dataDir}/${read2}"
            else
                echo "${sampleId} Read1 or Read2 File is not exist!"
                exit 111
            fi
        done

    >>>

    runtime {
        docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
        cluster: "OnDemand bcs.es.c.large img-ubuntu-vpc"
        mounts: mount_paths
        autoReleaseJob: false
        timeout: 600
  }

    output {
        String dataDir = dataDir
        Array[Array[String]] metaData = dataInfo
        # Array[Array[String]] metaData = read_tsv(metaFile)
    }
}

task star_and_arriba {
    input {
        String sampleId
        String fastq1
        String fastq2
        String species
        String ref_dir
        String arriba_db_dir

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
            exit 112
        fi

        # STAR and generate fusions
        echo "STAR and generate fusions: "
        time /arriba_v2.3.0/run_arriba.sh \
          ~{ref_dir}/~{species}/Genome_Index_STAR \
          ~{ref_dir}/~{species}/$gtf \
          ~{ref_dir}/~{species}/$ref \
          ~{arriba_db_dir}/$blacklist \
          ~{arriba_db_dir}/$known_fusions \
          ~{arriba_db_dir}/$protein_domains \
          12 \
          ~{fastq1} \
          ~{fastq2}

        # rename by sample
        echo "rename by sample: "
        mv Aligned.sortedByCoord.out.bam  ~{sampleId}_Aligned.sortedByCoord.out.bam
        mv Aligned.sortedByCoord.out.bam.bai  ~{sampleId}_Aligned.sortedByCoord.out.bam.bai
        mv fusions.discarded.tsv  ~{sampleId}_fusions.discarded.tsv
        mv fusions.tsv  ~{sampleId}_fusions.tsv
        mv Log.final.out  ~{sampleId}_Log.final.out
        mv SJ.out.tab  ~{sampleId}_SJ.out.tab

        # draw draw_fusions
        echo "draw draw_fusions: "
        time Rscript /arriba_v2.3.0/draw_fusions.R \
          --annotation=~{ref_dir}/~{species}/$gtf \
          --fusions=~{sampleId}_fusions.tsv \
          --output=~{sampleId}_fusions.pdf \
          --proteinDomains=~{arriba_db_dir}/$protein_domains \
          --alignments=~{sampleId}_Aligned.sortedByCoord.out.bam \
          --cytobands=~{arriba_db_dir}/$cytobands

    >>>

    runtime {
        docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:uhrigs-arriba-2.3.0"
        cluster: cluster_config
        mounts: mount_paths
        autoReleaseJob: true
        timeout: 86400
  }

    output {
        File fusions_file = sampleId + "_fusions.tsv"
        File fusions_pdf_file = sampleId + "_fusions.pdf"
        File fusions_discarded_file = sampleId + "_fusions.discarded.tsv"
        File log_final_out_file = sampleId + "_Log.final.out"
        File sj_out_tab_file = sampleId + "_SJ.out.tab"
    }
}

task gather_result_file {
    input {
        Array[File] fusions_files
        Array[File] fusions_pdf_files
        Array[File] fusions_discarded_files
        Array[File] log_final_out_files
        Array[File] sj_out_tab_files

        String mount_paths
    }

    command <<<

        mkdir result
        mv ~{sep=" " fusions_files} result/
        mv ~{sep=" " fusions_pdf_files} result/
        mv ~{sep=" " fusions_discarded_files} result/
        mv ~{sep=" " log_final_out_files} result/
        mv ~{sep=" " sj_out_tab_files} result/

    >>>

    runtime {
        docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:debian-latest"
        cluster: "OnDemand bcs.es.c.large img-ubuntu-vpc"
        mounts: mount_paths
        autoReleaseJob: true
        timeout: 600
    }

    output {
        Array[File] resultFiles = glob("./result/*")
    }
}

workflow henbio_wf {
    input {
        File metaFile
        String species
        String ref_dir
        String arriba_db_dir

        String cluster_config
        String mount_paths
    }

    call test_sample_files {
        input:
            metaFile = metaFile,
            mount_paths = mount_paths
    }
    scatter (sample in test_sample_files.metaData) {
        call star_and_arriba {
            input:
                sampleId = sample[0],
                fastq1 = test_sample_files.dataDir + "/" + sample[1],
                fastq2 = test_sample_files.dataDir + "/" + sample[2],
                species = species,
                ref_dir = ref_dir,
                arriba_db_dir = arriba_db_dir,
                cluster_config = cluster_config,
                mount_paths = mount_paths
        }
    }
    call gather_result_file {
        input:
            fusions_files = star_and_arriba.fusions_file,
            fusions_pdf_files = star_and_arriba.fusions_pdf_file,
            fusions_discarded_files = star_and_arriba.fusions_discarded_file,
            log_final_out_files = star_and_arriba.log_final_out_file,
            sj_out_tab_files = star_and_arriba.sj_out_tab_file,
            mount_paths = mount_paths
    }
}