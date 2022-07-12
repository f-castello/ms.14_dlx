vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../romem/romem.vhd
vcom -reportprogress 300 -work work ../tb_romem.vhd
vsim -t 10ps work.tb_romem -voptargs=+acc
add wave -position insertpoint sim:/tb_romem/*
add wave -position insertpoint  \
sim:/tb_romem/DRAM/Memory
run 120 ns
