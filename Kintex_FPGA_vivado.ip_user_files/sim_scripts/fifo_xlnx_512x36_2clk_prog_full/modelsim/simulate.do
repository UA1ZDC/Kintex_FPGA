onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L xpm -L fifo_generator_v13_2_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.fifo_xlnx_512x36_2clk_prog_full xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fifo_xlnx_512x36_2clk_prog_full.udo}

run -all

quit -force
