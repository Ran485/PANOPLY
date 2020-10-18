#
# Copyright (c) 2020 The Broad Institute, Inc. All rights reserved.
#
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac:panoply_immune_analysis/versions/18/plain-WDL/descriptor" as immune_wdl
import "https://api.firecloud.org/ga4gh/v1/tools/broadcptac_MM:panoply_immune_analysis_report_MM/versions/2/plain-WDL/descriptor" as immune_report_wdl

workflow panoply_immune_analysis_workflow {
    File inputData
  	String type
  	String standalone
  	File yaml
  	String? analysisDir
  	File? groupsFile
  	String? subType
  	Float? fdr
  	Int? heatmapWidth
  	Int? heatmapHeight
    String label
        
    call immune_wdl.panoply_immune_analysis as immune {
    	input:
        	inputData = inputData,
            type = type,
            standalone = standalone,
            yaml = yaml,
            analysisDir = analysisDir,
            groupsFile = groupsFile,
            subType = subType,
            fdr = fdr,
            heatmapWidth = heatmapWidth,
            heatmapHeight = heatmapHeight
    }
     
	call immune_report_wdl.panoply_immune_analysis_report as immune_report {
    	input:
        	tar_file = immune.outputs,
            yaml_file = immune.yaml_file,
            label = label
    }
    
    output {
    	File outputs = immune.outputs
        File report = immune_report.report_out
    }
}