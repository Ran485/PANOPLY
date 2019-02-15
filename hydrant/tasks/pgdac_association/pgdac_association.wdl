task pgdac_association_piped {
  File tarball   # output from pgdac_harmonize or pgdac_normalize_ms_data
  File? groupsFile
  String type
  String? subType
  File? params
  String codeDir = "/prot/proteomics/Projects/PGDAC/src"
  String outFile = "pgdac_association-output.tar"

  Int? memory
  Int? disk_space
  Int? num_threads
  Int? num_preemptions


  command {
    set -euo pipefail
    /prot/proteomics/Projects/PGDAC/src/run-pipeline.sh assoc -i ${tarball} -t ${type} -c ${codeDir} -o ${outFile} ${"-g " + groupsFile} ${"-m " + subType} ${"-p " + params}
  }

  output {
    File outputs = "${outFile}"
  }

  runtime {
    docker : "broadcptac/pgdac_association:1"
    memory : select_first ([memory, 16]) + "GB"
    disks : "local-disk " + select_first ([disk_space, 40]) + " SSD"
    cpu : select_first ([num_threads, 1]) + ""
    preemptible : select_first ([num_preemptions, 0])
  }

  meta {
    author : "Ramani Kothadia"
    email : "rkothadi@broadinstitute.org"
  }
}

task pgdac_association_sep {
  File filteredData
  String? analysisDir
  File? groupsFile
  String type
  String? subType
  File? params
  String codeDir = "/prot/proteomics/Projects/PGDAC/src"
  String outFile = "pgdac_association-output.tar"

  Int? memory
  Int? disk_space
  Int? num_threads
  Int? num_preemptions


  command {
    set -euo pipefail
    /prot/proteomics/Projects/PGDAC/src/run-pipeline.sh assoc -f ${filteredData} -t ${type} -c ${codeDir} -r ${analysisDir} -o ${outFile} -g ${groupsFile} ${"-m " + subType} ${"-p " + params}
  }

  output {
    File outputs = "${outFile}"
  }

  runtime {
    docker : "broadcptac/pgdac_association:1"
    memory : select_first ([memory, 16]) + "GB"
    disks : "local-disk " + select_first ([disk_space, 40]) + " SSD"
    cpu : select_first ([num_threads, 1]) + ""
    preemptible : select_first ([num_preemptions, 0])
  }

  meta {
    author : "Ramani Kothadia"
    email : "rkothadi@broadinstitute.org"
  }
}


workflow pgdac_association_workflow {
    Boolean isPiped
    File inputTarOrFiltered
    String? analysisDir
    File? groupsFile
    String dataType
    if(isPiped){
        call pgdac_association_piped{
            input:
                tarball=inputTarOrFiltered,
                type=dataType
        }
    }
    if(!isPiped){
        call pgdac_association_sep{
            input:
                filteredData=inputTarOrFiltered,
                analysisDir=analysisDir,
                type=dataType,
                groupsFile=groupsFile
        }
    }
}