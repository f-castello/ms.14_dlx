quit -sim
vcom -reportprogress 300 -work work ../../a.a-dlx_utils.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.core/a.c.a.a-gen_reg.vhd 
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.core/a.c.a.b-pc_add.vhd 
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.a-IF.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.b-sign_ext.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.core/a.c.b.c-reg_file.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.b-ID.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.c-zero_check.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.d-cond_branch.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.e-alu.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.c-EXE.core/a.c.c.f-cpsr.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.b-gen_mux21.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.core/a.c.d.c-sign_ext.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.d-MEM.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.a-gen_reg.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.core/a.c.e.b-gen_mux41.vhd
vcom -reportprogress 300 -work work ../../a.c-DP.core/a.c.e-WB.vhd

vcom -reportprogress 300 -work work ../../a.c-DP.vhd
