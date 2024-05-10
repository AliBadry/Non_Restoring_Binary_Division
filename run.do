vlog *.v
vsim -voptargs=+acc work.binary_division_tb
add wave -position insertpoint sim:/binary_division_tb/DUT/*

run -all