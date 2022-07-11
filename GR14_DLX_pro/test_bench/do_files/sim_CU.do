quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.b-CU_HW.vhd
vcom -reportprogress 300 -work work ../TB_CU_HW.vhd
vsim -voptargs=+acc work.tb_cu_hw
add wave *
run 330 ns
