# Makefile for Xilinx Spartan-3A/AN ISE/Webpack toolkit
#
# This makefile simplifies a life of FPGA developer by reducing build
# configuration and simulation to the list of source files and top entities name. 
#
# Grigoriy A. Sitkarev, <sitkarev@unixkomi.ru>
#

project         = uart
sim_project	= 
top-entity	= uart
sim_top-entity	= 
platform	= xc3s700an-fgg484
sources		= uart.v uart_rx.v uart_tx.v fifo.v tick_gen.v

sim_sources	= 


#include-file	=  

# STOP EDITING HERE

project-file		= $(project).prj
sim_project-file	= $(sim_project).prj
constraint-file		= $(project).ucf


.PHONY: clean simulate

all: $(project).ngc

bitstream: $(project).bit

# This rule generates project file for synthesising from the list of sources.
$(project-file): $(sources)
	@echo "generating synthesising project file \`$(project-file)' from list of sources: $(sources)"
	@rm -rf $(project-file)
	@touch $(project-file)
	@for file in $(sources); do \
	  case `echo $${file} | sed -n -e 's|^.*\(\..*\)$$|\1|p'` in \
	  .vhd|.vhdl) \
	    type="vhdl" \
	    ;; \
	  .verilog|.v) \
	    type="verilog" \
	    ;; \
	  *) \
	    echo "warning: excluding unknown file type \`$${file}'"; \
	    type="" \
	    ;; \
	  esac; \
	  test -z $${type} || echo "$${type} work \"$${file}\"" >> $(project-file); \
	done

$(project).ngc: $(project-file)
	echo "run -ifn $(project-file) -top $(top-entity) -compileonly no \
	     -ofn $(project) -p $(platform) -opt_mode Speed -opt_level 1" | xst | tee xstout | egrep 'WARNING|ERROR' > xsterrs
	@cat xsterrs

$(project).ngd: $(project).ngc $(constraint-file)
	ngdbuild -dd _ngo -nt timestamp -uc $(constraint-file) -p $(platform) $< $@

$(project).ncd: $(project).ngd
	map -p $(platform) -detail -c 100 -ir off -pr off $<

$(project).pcf: $(project).ngd
	map -p $(platform) -detail -c 100 -ir off -pr off $<

$(project)-par.ncd: $(project).ncd
	par -w $< $@ $(project).pcf

$(project).bit: $(project)-par.ncd
	bitgen -w -g DebugBitstream:No -g Binary:no \
	  -g CRC:Enable -g Reset_on_err:No -g ConfigRate:25 \
	  -g ProgPin:PullUp -g DonePin:PullUp -g TckPin:PullUp \
	  -g TdiPin:PullUp -g TdoPin:PullUp -g TmsPin:PullUp \
	  -g UnusedPin:PullDown -g UserID:0xFFFFFFFF -g StartUpClk:CClk \
	  -g DONE_cycle:4 -g GTS_cycle:5 -g GWE_cycle:6 \
	  -g LCK_cycle:NoWait -g Security:None -g DonePipe:Yes \
	  -g DriveDone:No -g en_sw_gsr:No -g en_porb:Yes -g drive_awake:No \
	  -g sw_clk:Startupclk -g sw_gwe_cycle:5 -g sw_gts_cycle:4 \
	  $< $@ $(project).pcf
		
install-fpga: $(project).bit
	echo -n "setmode -bs\n"\
	"setcable -p auto\n"\
	"identify\n"\
	"assignfile -p 1 -file $(project).bit\n"\
	"program -p 1 -onlyFpga\n" | impact -batch

install-flash: $(project).bit
	echo -n "setmode -bs\n"\
	"setcable -p auto\n"\
	"identify\n"\
	"assignfile -p 1 -file $(project).bit\n"\
	"program -p 1 -e -v\n" | impact -batch

# This rule generates project file for simulating from the list of sources.
$(sim_project-file): $(sim_sources)
	@echo "generating simulating project file $@  from list of sources: $(sim_sources)"
	@rm -rf $@
	@touch $@
	@for file in $(sim_sources); do \
	  case `echo $${file} | sed -n -e 's|^.*\(\..*\)$$|\1|p'` in \
	  .vhd|.vhdl) \
	    type="vhdl" \
	    ;; \
	  .verilog|.v) \
	    type="verilog" \
	    ;; \
	  *) \
	    echo "warning: excluding unknown file type \`$${file}'"; \
	    type="" \
	    ;; \
	  esac; \
	  test -z $${type} || echo "$${type} work \"$${file}\"" >> $@; \
	done

$(sim_project).exe: $(sim_project-file)
	@if [ "$(inslude-file)"==" " ];\
	then \
		fuse -incremental -prj $^ -o $@ work.$(sim_top-entity); \
	else \
		fuse -incremental -prj $^ -i $(include-file) -o $@ work.$(sim_top-entity); \
	fi
#Simulate the design in ISim 
#Firstly executed ISim makes view-file and gives a WARRNING-message - that's OK - click "Ignore" to continue
simulate: $(sim_project).exe 
	./$^ -gui -view $(sim_project).wcfg -wdb $(sim_project).wdb

clean:
	 rm -rf $(project-file) $(sim_project-file) $(project).ngc $(project).ngd $(project).ncd $(project).pcf $(project)-par.ncd $(project).bit $(sim_project).exe
