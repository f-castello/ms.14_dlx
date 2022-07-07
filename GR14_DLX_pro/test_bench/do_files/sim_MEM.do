quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.c-sign_ext.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.vhd
vcom -reportprogress 300 -work work ../TB_MEM.vhd
vsim -t 10ps work.cfg_test_mem
add wave -position insertpoint sim:/tb_mem/*
add wave -position insertpoint  \
sim:/tb_mem/DUT/SIGN_EXT_BLOCK/data_ext
add wave -position insertpoint  \
sim:/tb_mem/DUT/SIGN_EXT_BLOCK/data_in
run 120 ns
