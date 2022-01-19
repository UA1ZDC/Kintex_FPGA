onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib fractional_decimator_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fractional_decimator.udo}

run -all

quit -force
