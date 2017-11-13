transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/Altera_Mem_Dual_Port {C:/MIPS_Design/MIPS_System/Altera_Mem_Dual_Port/ram2port_inst_data.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System {C:/MIPS_Design/MIPS_System/MIPS_System.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/Timer {C:/MIPS_Design/MIPS_System/Timer/TimerCounter.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/MIPS_CPU {C:/MIPS_Design/MIPS_System/MIPS_CPU/mipsparts.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/GPIO {C:/MIPS_Design/MIPS_System/GPIO/GPIO.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/Decoder {C:/MIPS_Design/MIPS_System/Decoder/Addr_Decoder.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/Altera_PLL {C:/MIPS_Design/MIPS_System/Altera_PLL/ALTPLL_clkgen.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System_Syn/db {C:/MIPS_Design/MIPS_System_Syn/db/altpll_clkgen_altpll.v}
vlog -vlog01compat -work work +incdir+C:/MIPS_Design/MIPS_System/MIPS_CPU {C:/MIPS_Design/MIPS_System/MIPS_CPU/mips.v}

