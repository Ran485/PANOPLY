task pgdac_mo_nmf {
	#Inputs defined here
	File tar_file
	
	Int kmin
	Int kmax
	Int nrun
	Int nrun_bs
	
	String seed
	String class_variable
	String other_variable
	String class_colors
	String output_prefix
	String genes_of_interest

	Boolean no_plot

	Int memory
	Int disk_space
	Int num_threads
	Int num_preemtions
	
	command {
		set -euo pipefail
		#Command goes here
		Rscript /home/pgdac/src/mo-nmf.r -t ${tar_file} -l ${kmin} -m ${kmax} -n ${nrun} -s ${seed} -c ${class_variable} -o ${other_variable} -d ${class_colors} -r ${no_plot} -b ${nrun_bs} -g ${genes_of_interest}
		find * -type d -name "[0-9]*" -print0 | tar -czvf ${output_prefix}.tar --null -T -
	
		}

	output {
		#Outputs defined here
		File results="${output_prefix}.tar"
		}

	runtime {
		docker : "broadcptac/pgdac_mo_nmf:4"
		memory : select_first ([memory, 7]) + "GB"
		disks : "local-disk " + select_first ([disk_space, 10]) + " SSD"
		cpu : select_first ([num_threads, 12]) + ""
		preemptible : select_first ([num_preemtions, 0])
	}

	meta {
		author : "Karsten Krug"
		email : "karsten@broadinstitute.org"
	}

}

workflow pgdac_mo_nmf_workflow {
	call pgdac_mo_nmf
}