quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.a-gen_mux41.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.vhd
vcom -reportprogress 300 -work work ../TB_WB.vhd
vsim -voptargs=+acc work.tb_wb
add wave *
run 18 ns
