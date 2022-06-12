vcom -reportprogress 300 -work work /home/ms22.14/ms.14_dlx/GR14_DLX_pro/a.c-DP.core/test/a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work /home/ms22.14/ms.14_dlx/GR14_DLX_pro/a.c-DP.core/test/a.c.a.a-gen_reg.vhd 
vcom -reportprogress 300 -work work /home/ms22.14/ms.14_dlx/GR14_DLX_pro/a.c-DP.core/test/a.c.a.b-pc_add.vhd 
vcom -reportprogress 300 -work work /home/ms22.14/ms.14_dlx/GR14_DLX_pro/a.c-DP.core/test/a.c.a-IF.vhd
vcom -reportprogress 300 -work work /home/ms22.14/ms.14_dlx/GR14_DLX_pro/a.c-DP.core/test/TB_IF.vhd
vsim -t 10ps work.tb_if
add wave *
add wave -position insertpoint  \
sim:/tb_if/IR_MEM_VALS
add wave -position insertpoint sim:/tb_if/DUT/*
run 100 ns
