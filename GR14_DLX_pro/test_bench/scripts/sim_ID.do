quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.b-sign_ext.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.c-reg_file.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.vhd
vcom -reportprogress 300 -work work ../TB_ID.vhd
vsim -voptargs=+acc -t 10ps work.tb_id
add wave *
add wave -position insertpoint  \
sim:/tb_id/DUT/RF/ADD_WR
add wave -position insertpoint  \
sim:/tb_id/DUT/RF/REGISTERS
add wave -position insertpoint  \
sim:/tb_id/DUT/SIGN_EXTEND/data_in
add wave -position insertpoint  \
sim:/tb_id/DUT/SIGN_EXTEND/data_ext
run 160 ns
