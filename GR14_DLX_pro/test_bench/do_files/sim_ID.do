vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/a.c-DP.core/a.c.b-ID.core/a.c.b.a-gen_reg.vhd
vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/a.c-DP.core/a.c.b-ID.core/a.c.b.b-sign_ext.vhd
vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/a.c-DP.core/a.c.b-ID.core/a.c.c.b-gen_mux21.vhd
vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/a.c-DP.core/a.c.b-ID.core/a.c.b.c-reg_file.vhd
vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/a.c-DP.core/a.c.b-ID.vhd
vcom -reportprogress 300 -work work /home/ms22.14/GR14_DLX_pro/test_bench/TB_ID.vhd
vsim -t 10ps work.cfg_test_id
add wave *
add wave -position insertpoint  \
sim:/tb_id/DUT/RF/ADD_WR
add wave -position insertpoint  \
sim:/tb_id/DUT/RF/REGISTERS
add wave -position insertpoint  \
sim:/tb_id/DUT/SING_EXT/data_in
add wave -position insertpoint  \
sim:/tb_id/DUT/SING_EXT/data_ext
run 160 ns
