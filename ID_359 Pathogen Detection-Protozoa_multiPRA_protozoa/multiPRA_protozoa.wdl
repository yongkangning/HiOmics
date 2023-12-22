version 1.0

task task_multiPRA_protozoa {
    input {
        String fastq1
        String fastq2

        String cluster_config
        String mount_paths
    }

    command <<<
        set -eo pipefail
        cpu_cores=$(nproc)
        # cpu_cores=10

        singularity exec --bind /henbio/henbio_web:/henbio/henbio_web /henbio/henbio_web/public/workflow/multiPRA/multiPRA-V1.3.2.sif multiPRA.py \
        -1 ~{fastq1} \
        -2 ~{fastq2} \
        --loc /henbio/henbio_web/public/workflow/multiPRA/databases_aliyun.txt \
        -p ${cpu_cores} \
        --db Protozoa -O $HOME/result

        #cp $HOME/result/report.docx  ./
        find $HOME/result/bak/mg/stat/ -name "positive.strain.*.txt" -exec mv {} ./pathogene.protozoa.xls \;
    >>>

    output {
        #File report = "report.docx"
        #File? sample_pos = "sample.xlsx"
        #File? sample_neg = "sample.negative.xlsx"
        File? result = "pathogene.protozoa.xls"
    }
 
    runtime {
        docker: "registry.cn-shenzhen.aliyuncs.com/henbio-pro/henbio:nextflow-22-10-6"
        cluster: cluster_config
        mounts: mount_paths
        autoReleaseJob: false
        timeout: 36000
    }
}

workflow henbio_wf {
    call task_multiPRA_protozoa
}