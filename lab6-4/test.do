# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog mem.v
vlog proc.v
vlog Lab6_2.v
vlog D:/intelFPGA_lite/16.1/modelsim_ase/altera/verilog/src/altera_mf.v

#load simulation using mux as the top level simulation module
vsim Lab6_4

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {CLOCK_50} 1 0ns,0 5ns -repeat 10ns
force {addr} 16'b0
run 30ns

force {addr} 0010000000000111
force {data} 0000000000110000
force {W} 1
run 30ns

force {addr} 0010000000000110
force {data} 0000000000110001
force {W} 1
run 30ns

force {addr} 0010000000000101
force {data} 0000000000110000
force {W} 1
run 30ns

force {addr} 0010000000000100
force {data} 0000000000000110
force {W} 1
run 30ns

force {addr} 0010000000000011
force {data} 0000000001001100
force {W} 1
run 30ns

force {addr} 0010000000000010
force {data} 0000000000010010
force {W} 1
run 30ns

force {addr} 0001000000000010
force {data} 0001110000010010
force {W} 1
run 50ns