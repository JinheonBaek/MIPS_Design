library verilog;
use verilog.vl_types.all;
entity EX_MEM_C is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        regwrite_ex     : in     vl_logic;
        memtoreg_ex     : in     vl_logic;
        memwrite_ex     : in     vl_logic;
        branch_ex       : in     vl_logic;
        bnezbit_ex      : in     vl_logic;
        jump_ex         : in     vl_logic;
        regwrite_mem    : out    vl_logic;
        memtoreg_mem    : out    vl_logic;
        memwrite_mem    : out    vl_logic;
        branch_mem      : out    vl_logic;
        bnezbit_mem     : out    vl_logic;
        jump_mem        : out    vl_logic
    );
end EX_MEM_C;
