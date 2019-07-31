# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog mem.v
vlog proc.v
vlog Lab6_2.v
vlog D:/intelFPGA_lite/16.1/modelsim_ase/altera/verilog/src/altera_mf.v

#load simulation using mux as the top level simulation module
vsim Lab6_5

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {CLOCK_50} 1 0ns,0 5ns -repeat 10ns
force {addr} 16'b0
force {SW} 011001001
run 30ns

force {addr} 0011000000000000
run 30ns



