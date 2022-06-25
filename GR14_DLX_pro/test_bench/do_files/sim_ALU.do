vcom -reportprogress 300 -work work /home/ms22.14/ALU/a.a-dlx_utils.vhd
vcom -reportprogress 300 -work work /home/ms22.14/ALU/a.c.c.e-alu.vhd
vcom -reportprogress 300 -work work /home/ms22.14/ALU/TB_alu.vhd
vsim work.tb_alu
add wave *
run 26 ns
