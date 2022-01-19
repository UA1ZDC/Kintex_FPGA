onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib fifo_xlnx_512x36_2clk_prog_full_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fifo_xlnx_512x36_2clk_prog_full.udo}

run -all

quit -force
