onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+fifo_xlnx_512x36_2clk_18to36 -L xpm -L fifo_generator_v13_2_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fifo_xlnx_512x36_2clk_18to36 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {fifo_xlnx_512x36_2clk_18to36.udo}

run -all

endsim

quit -force
