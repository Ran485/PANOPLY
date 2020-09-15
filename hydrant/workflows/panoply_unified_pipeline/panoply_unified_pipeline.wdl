import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac_MM:panoply_main_MM/versions/41/plain-WDL/descriptor" as main_wdl
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac_MM:panoply_blacksheep_MM/versions/7/plain-WDL/descriptor" as blacksheep_wdl
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac:panoply_mo_nmf_gct/versions/3/plain-WDL/descriptor" as mo_nmf_wdl
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac:panoply_immune_analysis/versions/15/plain-WDL/descriptor" as immune_wdl
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac_MM:make_pairs_MM/versions/1/plain-WDL/descriptor" as make_pairs
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac_MM:panoply_unified_assemble_results_MM/versions/1/plain-WDL/descriptor" as assemble_wdl


workflow panoply_unified_workflow {
  File? prote_ome
  File? phospho_ome
  File? acetyl_ome
  File? ubiquityl_ome
  File? rna_data      #version 1.3 only!
  File? cna_data
  File? sample_annotation
  File? yaml
  String job_id
  File? groupsFile
  File? gene_set_database
  
  
  Array[File] omes = ["${prote_ome}", "${phospho_ome}", "${acetyl_ome}", "${ubiquityl_ome}"]
  Array[File] data = ["${rna_data}", "${cna_data}"]
  
  call make_pairs.make_pairs as type_pairs {
    input:
      files = data,
      suffix = "-aggregate.gct"

  }

  call make_pairs.make_pairs as ome_pairs {
    input:
      files = omes,
      suffix = "-aggregate.gct"

  }

  ### MAIN:
  scatter (pair in ome_pairs.zipped) {
    if ("${pair.right}" != "") {
      String ptmsea = if "${pair.left}"=="phosphoproteome" then "TRUE" else "FALSE"
        call main_wdl.panoply_main as pome {
          input:
            ## include all required arguments from above
            input_pome="${pair.right}",
            ome_type="${pair.left}",
            job_identifier="${job_id}-${pair.left}",
            run_ptmsea="${ptmsea}",
            input_cna="${cna_data}",
            input_rna_v3="${rna_data}",
            sample_annotation="${sample_annotation}",
            yaml="${yaml}"
        }
        
      
    }
  }
  
  call make_pairs.make_pairs as norm_pairs {
    input:
      files = pome.normalized_data_table,
      suffix = "-normalized_table-output.gct"

  }

  Array[Pair[String?,File?]] all_pairs = flatten([norm_pairs.zipped,type_pairs.zipped])
  
  ### BLACKSHEEP:
  scatter (pair in all_pairs) {
    if ("${pair.right}" != "") {
      call blacksheep_wdl.panoply_blacksheep_workflow as outlier {
        input:
          input_gct = "${pair.right}",
          master_yaml = "${yaml}",
          output_prefix = "${pair.left}",
          groups_file = groupsFile
      }
    }
  }
  
  # Get individual ome files for nmf:
  scatter (f in all_pairs) {
    if ("${f.left}" == "proteome") { 
      File? nmf_proteome_gct = "${f.right}"
    }
    if ("${f.left}" == "phosphoproteome") {
      File? nmf_phospho_gct = "${f.right}"
    }
    if ("${f.left}" == "ubiquitylome") {
      File? nmf_ubiquityl_gct = "${f.right}"
    }
    if ("${f.left}" == "acetylome") {
      File? nmf_acetyl_gct = "${f.right}"
    }
  }
  
  ### NMF:
  call mo_nmf_wdl.panoply_mo_nmf_gct_workflow as nmf {
    input:
      gene_set_database = gene_set_database,
      yaml_file = yaml,
      label = job_id,
      prote_ome = nmf_proteome_gct,
      phospho_ome = nmf_phospho_gct,
      acetyl_ome = nmf_acetyl_gct,
      ubiquityl_ome = nmf_ubiquityl_gct,
      rna_ome = rna_data,
      cna_ome = cna_data
  }
  
  ### IMMUNE:
  call immune_wdl.panoply_immune_analysis as immune {
    input:
        inputData=rna_data,
        standalone="true",
        type="rna",
        yaml=yaml,
        analysisDir=job_id,
        groupsFile=groupsFile
  }
  
  ## assemble final output combining results from panoply_main, blacksheep immune_analysis and mo_nmf
  call assemble_wdl.panoply_unified_assemble_results {
    input:
      main_full = pome.panoply_full,
      main_summary = pome.summary_and_ssgsea,
      #cmap_output = pome.cmap_output,
      #cmap_ssgsea_output = pome.cmap_ssgsea_output,
      norm_report = pome.norm_report,
      rna_corr_report = pome.rna_corr_report,
      cna_corr_report = pome.cna_corr_report,
      sampleqc_report = pome.sample_qc_report,
      assoc_report = pome.association_report,
      blacksheep_tar = outlier.blacksheep_tar,
      blacksheep_report = outlier.blacksheep_report,
      mo_nmf_tar = nmf.nmf_clust,
      mo_nmf_ssgsea_tar = nmf.nmf_ssgsea,
      mo_nmf_ssgsea_report = nmf.nmf_ssgsea_report,
      immune_tar = immune.outputs

  }
  
  output {
  	File all_results = panoply_unified_assemble_results.all_results
    File all_reports = panoply_unified_assemble_results.all_reports
  }
 }