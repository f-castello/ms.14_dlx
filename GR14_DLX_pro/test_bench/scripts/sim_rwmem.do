vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../memories/rwmem/rwmem.vhd
vcom -reportprogress 300 -work work ../TB_rwmem.vhd
vsim -t 10ps work.tb_rwmem -voptargs=+acc
add wave -position insertpoint sim:/tb_rwmem/*
add wave -position insertpoint  \
sim:/tb_rwmem/DRAM/DRAM_mem
run 120 ns
