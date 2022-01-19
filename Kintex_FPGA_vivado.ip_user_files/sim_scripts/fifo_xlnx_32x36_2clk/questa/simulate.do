onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib fifo_xlnx_32x36_2clk_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fifo_xlnx_32x36_2clk.udo}

run -all

quit -force
