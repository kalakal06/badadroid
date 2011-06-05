; this sample script mounts oneNAND and internal SDHC in TFS4 filesystem and prints listdir of selected directory

; mounting external SD card doesn't seem to be so easy

include 'inc/S8530JPKA1.inc'	  ;here include the right BL function pointers, depends on model and BL you've got
include 'inc/macros_S8530.inc'	  ;model dependend FOTA header and footer

include 'inc/vars.inc'		  ;this one provides default strings and variables, which are being used by functions
include 'inc/functions.inc'	  ;this one provides default functions


START	;don't touch this macro, it contains correct FOTA magic numbers and does auto CALL-KEY check and jumps here if its pressed
	;MMUCache is required for TFS4 system operations, enabling cache enables the whole MMU too
	MOV		r1, #1
	LDR		r0, [pagetable]
	BL		MemMMUCacheEnable
	bl		enable_fota_output
	MOV		R0, 1234
	BL		int_debugprint	    ;prints "debug: 1234" to the FOTA or UART
	BL		__PfsNandInit	    ;oneNAND FS
	BL		__PfsMassInit	    ;SDHC on interface MMC0 init (internal 2gb sd card)
	LDR		R0, [s_dir_path_a]  ;load the address of directory we want to list
	BL		listdir 	    ;jump into list function
	BL		dloadmode	    ;enter download mode and inform about that after all, that makes our life easier

FUNCTIONS ;macro from functions.inc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; variables below
DEFAULT_VARIABLES	;macro from vars.inc
    pagetable 		 dw gMMUL1PageTable

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; strings at the end
DEFAULT_STRINGS_ADDR	;macro from vars.inc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; add custom strings addresses below (for using by LDR op)
    s_dir_path_a     dw s_dir_path

DEFAULT_STRINGS 	;macro from vars.inc
;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;add custom strings below
    s_dir_path	     du '/g/galaxyboot/',0 ;tfs4 path must be wchar string
    ;/g/ is the User Media storage space in internal SDHC

    
END	;don't touch this macro, it contains correct FOTA magic numbers and Multiloader header