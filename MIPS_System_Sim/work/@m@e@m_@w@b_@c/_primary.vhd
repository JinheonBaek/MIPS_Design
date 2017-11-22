library verilog;
use verilog.vl_types.all;
entity MEM_WB_C is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        regwrite_mem    : in     vl_logic;
        memtoreg_mem    : in     vl_logic;
        regwrite_wb     : out    vl_logic;
        memtoreg_wb     : out    vl_logic
    );
end MEM_WB_C;
