onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fractional_decimator_opt

do {wave.do}

view wave
view structure
view signals

do {fractional_decimator.udo}

run -all

quit -force
