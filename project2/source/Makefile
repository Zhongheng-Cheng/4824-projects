##########################
# ---- Introduction ---- #
##########################

# Welcome to the EECS 470 standard makefile! (plus hierarchical synthesis!)

# NOTE: you should only need to modify the "Executable Compilation" section
# namely the TESTBENCH, SOURCES, and SYNTH_FILES variables
# look for the 'P2 TODO' or 'P2 NOTE' markers below

# reference table of all make targets:

# P2 NOTE: We've added new targets for compiling your testbench with buggy ISR modules
# make buggy<n>_sim   <- runs a buggy ISR module on your testbench
# make buggy<n>_simv  <- compiles your ISR testbench with a buggy ISR module
# make buggy<n>_verdi <- run the buggy executable in verdi

# make           <- runs the default target, set explicitly below as 'make sim'
.DEFAULT_GOAL = sim
# ^ this overrides using the first listed target as the default

# make sim       <- execute the simulation testbench (simv)
# make simv      <- compiles simv from the testbench and SOURCES

# make syn       <- execute the synthesized module testbench (syn_simv)
# make syn_simv  <- compiles syn_simv from the testbench and *.vg SYNTH_FILES
# make *.vg      <- synthesize the top level module in SOURCES for use in syn_simv
# make slack     <- a phony command to print the slack of any synthesized modules

# make verdi     <- runs the Verdi GUI debugger for simulation
# make syn_verdi <- runs the Verdi GUI debugger for synthesis

# make clean     <- remove files created during compilations (but not synthesis)
# make nuke      <- remove all files created during compilation and synthesis
# make clean_run_files <- remove per-run output files
# make clean_exe       <- remove compiled executable files
# make clean_synth     <- remove generated synthesis files

######################################################
# ---- Compilation Commands and Other Variables ---- #
######################################################

# P2 TODO: edit this variable, re-synthesize, and run 'make slack' to see generated slack
# this is a global clock period variable used in the tcl script and referenced in testbenches
export CLOCK_PERIOD = 10.0

# the Verilog Compiler command and arguments
VCS = SW_VCS=2019.06-SP2-1 vcs -sverilog +vc -Mupdate -line -full64 -kdb -lca -nc \
      -debug_access+all+reverse $(VCS_BAD_WARNINGS) +define+CLOCK_PERIOD=$(CLOCK_PERIOD)
# a SYNTH define is added when compiling for synthesis that can be used in testbenches

# remove certain warnings that generate MB of text but can be safely ignored
VCS_BAD_WARNINGS = +warn=noTFIPC +warn=noDEBUG_DEP +warn=noENUMASSIGN

# a reference library of standard structural cells that we link against when synthesizing
LIB = lec25dscc25.v

# the EECS 470 synthesis script
TCL_SCRIPT = 470synth.tcl

# Set the shell's pipefail option: causes return values through pipes to match the last non-zero value
# (useful for, i.e. piping to `tee`)
SHELL := $(SHELL) -o pipefail

#########################################
# ---- Project 2 buggy ISR testing ---- #
#########################################

# P2 NOTE: This section defines commands to compile and run the 3 buggy modules
#          that your ISR testbench must catch. Each of them is an incorrect
#          implementation of the ISR module -- synthesized to obfuscate their
#          source code.

# 'make buggy1_simv' will compile ISR_buggy1.vg on your ISR_test.sv as buggy1_simv
# 'make buggy1_sim' will run buggy1_simv
# 'make buggy1_verdi' can open it in verdi for debugging.

ISR_TB = ISR_test.sv
BUGGY_ISRS = buggy1 buggy2 buggy3

$(BUGGY_ISRS:%=ISR_%.vg): ;  # avoid matching the %.vg pattern rule below

# NOTE: This target uses Make's pattern substitution syntax
# This reads as: $(var:pattern=replacement)
# A percent sign '%' in pattern is a wildcard, and can be reused in the replacement.
# If you don't include the percent it automatically attempts to replace just the suffix of the input
# see: https://www.gnu.org/software/make/manual/html_node/Text-Functions.html#Text-Functions
# NOTE: This also uses a 'static pattern rule' to match a list of known targets to a pattern
# and: https://www.gnu.org/software/make/manual/html_node/Static-Usage.html

$(BUGGY_ISRS:=_simv): %_simv: $(ISR_TB) ISR_%.vg
	@$(call PRINT_COLOR, 5, compiling the simulation executable $@)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	$(VCS) $^ $(LIB) -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)

$(BUGGY_ISRS:=_sim): %_sim: %_simv
	@$(call PRINT_COLOR, 5, running $<)
	./$< | tee $*.out
	@$(call PRINT_COLOR, 2, output saved to $*.out)
.PHONY: $(BUGGY_ISRS:=_sim)

$(BUGGY_ISRS:=_verdi): %_verdi: %_simv novas.rc verdi_dir
	./$< -gui=verdi

####################################
# ---- Executable Compilation ---- #
####################################

# You should only need to modify the following variables in this section:
# TESTBENCH   = mult_test.sv
# SOURCES     = mult.sv
# SYNTH_FILES = mult.vg
TESTBENCH = ISR_test.sv
SOURCES = ISR_1.sv
SYNTH_FILES = ISR.vg
# P2 TODO: after testing the mult module clock period, prep the ISR module:
#          set STAGES to 8 in mult_defs.svh
#          replace 'mult_test.sv' with 'ISR_test.sv'
#          add 'ISR.sv' to SOURCES
#          repalce 'mult.vg' with 'ISR.vg'

HEADERS = mult_defs.svh

# the .vg rule is automatically generated below when the name of the file matches its top level module

# P2 NOTE: should be no need to modify these hierarchical synthesis variables:
CHILD_MODULES = mult_stage
CHILD_SOURCES = mult_stage.sv
DDC_FILES     = mult_stage.ddc
# see the updated %.vg and %.ddc pattern rules below

# the normal simulation executable will run your testbench on the original modules
simv: $(TESTBENCH) $(CHILD_SOURCES) $(SOURCES) $(HEADERS)
	@$(call PRINT_COLOR, 5, compiling the simulation executable $@)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	$(VCS) $(TESTBENCH) $(CHILD_SOURCES) $(SOURCES) -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)
# NOTE: we reference variables with $(VARIABLE), and can make use of the automatic variables: ^, @, <, etc
# see: https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html for explanations

# a make pattern rule to generate the .vg synthesis files
# pattern rules use the % as a wildcard to match multiple possible targets
# NOTE: includes CHILD_MODULES and DDC_FILES for hierarchical synthesis
%.vg: $(SOURCES) $(TCL_SCRIPT) $(DDC_FILES) $(HEADERS)
	@$(call PRINT_COLOR, 5, synthesizing the $* module)
	@$(call PRINT_COLOR, 3, this might take a while...)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	# pipefail causes the command to exit on failure even though it's piping to tee
	set -o pipefail; MODULE=$* SOURCES="$(SOURCES)" CHILD_MODULES=$(CHILD_MODULES) DDC_FILES=$(DDC_FILES) dc_shell-t -f $(TCL_SCRIPT) | tee $*_synth.out
	@$(call PRINT_COLOR, 6, finished synthesizing $@)
# this also generates many other files, see the tcl script's introduction for info on each of them

# this rule is similar to the %.vg rule above, but doesn't include CHILD_MODULES or DDC_FILES
$(DDC_FILES): %.ddc: $(CHILD_SOURCES) $(TCL_SCRIPT) $(HEADERS)
	@$(call PRINT_COLOR, 5, synthesizing the $* module)
	@$(call PRINT_COLOR, 3, this might take a while...)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	# pipefail causes the command to exit on failure even though it's piping to tee
	set -o pipefail; MODULE=$* SOURCES="$(CHILD_SOURCES)" dc_shell-t -f $(TCL_SCRIPT) | tee $*_synth.out
	@$(call PRINT_COLOR, 6, finished synthesizing $@)
.SECONDARY: $(DDC_FILES) # this avoids deleting this file when used as an intermediate

# the synthesis executable runs your testbench on the synthesized versions of your modules
syn_simv: $(TESTBENCH) $(SYNTH_FILES)
	@$(call PRINT_COLOR, 5, compiling the synthesis executable $@)
	$(VCS) +define+SYNTH $^ $(LIB) -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)
# we need to link the synthesized modules against LIB, so this differs slightly from simv above
# but we still compile with the same non-synthesizable testbench

# a phony target to view the slack in the *.rep synthesis report file
slack:
	grep --color=auto "slack" *.rep
.PHONY: slack

#####################################
# ---- Running the Executables ---- #
#####################################

# these targets run the compiled executable and save the output to a .out file
# their respective files are program.out or program.syn.out

sim: simv
	@$(call PRINT_COLOR, 5, running $<)
	./$< | tee program.out
	@$(call PRINT_COLOR, 2, output saved to program.out)

syn: syn_simv
	@$(call PRINT_COLOR, 5, running $<)
	./$< | tee program.syn.out
	@$(call PRINT_COLOR, 2, output saved to program.syn.out)

# NOTE: phony targets don't create files matching their name, and make will always run their commands
# make doesn't know how files get created, so we tell it about these explicitly:
.PHONY: sim syn

###################
# ---- Verdi ---- #
###################

# verdi is the synopsys debug system, and an essential tool in EECS 470

# these targets run the executables using verdi
verdi: simv novas.rc verdi_dir
	./simv -gui=verdi

syn_verdi: syn_simv novas.rc verdi_dir
	./syn_simv -gui=verdi

.PHONY: verdi syn_verdi

# this creates a directory verdi will use if it doesn't exist yet
verdi_dir:
	mkdir -p /tmp/$${USER}470
.PHONY: verdi_dir

novas.rc: initialnovas.rc
	sed s/UNIQNAME/$$USER/ initialnovas.rc > novas.rc

#####################
# ---- Cleanup ---- #
#####################

# You should only clean your directory if you think something has built incorrectly
# or you want to prepare a clean directory for e.g. git (first check your .gitignore).
# Please avoid cleaning before every build. The point of a makefile is to
# automatically determine which targets have dependencies that are modified,
# and to re-build only those as needed; avoiding re-building everything everytime.

# 'make clean' removes build/output files, 'make nuke' removes all generated files
# clean_* commands clean certain groups of files

clean: clean_exe clean_run_files
	@$(call PRINT_COLOR, 6, note: clean is split into multiple commands that you can call separately: clean_exe and clean_run_files)

# use cautiously, this can cause hours of recompiling in later projects
nuke: clean clean_synth
	@$(call PRINT_COLOR, 6, note: nuke is split into multiple commands that you can call separately: clean_synth)

clean_exe:
	@$(call PRINT_COLOR, 3, removing compiled executable files)
	rm -rf *simv *.daidir csrc *.key vcdplus.vpd vc_hdrs.h
	rm -rf verdi* novas* *fsdb*

clean_run_files:
	@$(call PRINT_COLOR, 3, removing per-run outputs)
	rm -rf *.out *.dump

clean_synth:
	@$(call PRINT_COLOR, 1, removing synthesis files)
	rm -rf *_svsim.sv *.res *.rep *.ddc *.chk *.syn *_synth.out *.mr *.pvl command.log
	# P2 NOTE: Don't delete the ISR_buggy*.vg files
	find . -type f -name '*.vg' -not -name 'ISR_buggy*.vg' -delete

.PHONY: clean nuke clean_%

######################
# ---- Printing ---- #
######################

# this is a GNU Make function with two arguments: PRINT_COLOR(color: number, msg: string)
# it does all the color printing throughout the makefile
PRINT_COLOR = if [ -t 0 ]; then tput setaf $(1) ; fi; echo $(2); if [ -t 0 ]; then tput sgr0; fi
# colors: 0:black, 1:red, 2:green, 3:yellow, 4:blue, 5:magenta, 6:cyan, 7:white
# other numbers are valid, but aren't specified in the tput man page

# Make functions are called like this:
# $(call PRINT_COLOR,3,Hello World!)
# NOTE: adding '@' to the start of a line avoids printing the command itself, only the output
