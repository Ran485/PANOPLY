task panoply_normalize_ms_data_report {
  File tarball
  String label
  String type
  String tmpDir
  File yaml
  String? normalizeProteomics

  Int? memory
  Int? disk_space
  Int? num_threads

  command {
    set -euo pipefail
    if [ ${normalizeProteomics} ]; then
      if [ ${normalizeProteomics} = "FALSE" ]; then
        norm=FALSE
      fi
      if [ ${normalizeProteomics} = "TRUE" ]; then
        norm=TRUE
      fi
    else
      # Find the flag for normalize.proteomics in the yaml:
      cfg=${yaml}
      echo "library(yaml);yaml=read_yaml('$cfg');norm=yaml[['normalize.proteomics']];writeLines(as.character(norm), con='norm.txt')" > cmd.r
      Rscript cmd.r
      norm=`cat norm.txt`
    fi
    if [ $norm = FALSE ]; then
      echo 'no normalization performed' > "norm_"${label}".html"
    else
      Rscript /home/pgdac/src/rmd-normalize.r ${tarball} ${label} ${type} ${tmpDir}
    fi
  }

  output {
    File report = "norm_" + "${label}" + ".html"
  }

  runtime {
    docker : "broadcptacdev/panoply_normalize_ms_data_report:latest"
    memory : select_first ([memory, 8]) + "GB"
    disks : "local-disk " + select_first ([disk_space, 20]) + " SSD"
    cpu : select_first ([num_threads, 1]) + ""
  }

  meta {
    author : "Karsten Krug"
    email : "karsten@broadinstitute.org"
  }
}

workflow panoply_normalize_ms_data_report_workflow {
	call panoply_normalize_ms_data_report
}
