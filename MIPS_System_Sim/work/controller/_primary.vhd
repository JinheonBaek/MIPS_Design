library verilog;
use verilog.vl_types.all;
entity controller is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        ID_op           : in     vl_logic_vector(5 downto 0);
        ID_funct        : in     vl_logic_vector(5 downto 0);
        EX_flush        : in     vl_logic;
        ID_equal        : in     vl_logic;
        ID_signext      : out    vl_logic;
        ID_shiftl16     : out    vl_logic;
        WB_memtoreg     : out    vl_logic;
        MEM_memtoreg    : out    vl_logic;
        MEM_memwrite    : out    vl_logic;
        EX_memread      : out    vl_logic;
        MEM_memread     : out    vl_logic;
        ID_pcsrc        : out    vl_logic;
        EX_alusrc       : out    vl_logic;
        EX_regdst       : out    vl_logic;
        EX_regwrite     : out    vl_logic;
        MEM_regwrite    : out    vl_logic;
        WB_regwrite     : out    vl_logic;
        ID_jump         : out    vl_logic;
        EX_jal          : out    vl_logic;
        WB_jal          : out    vl_logic;
        ID_jr           : out    vl_logic;
        ID_branch       : out    vl_logic_vector(1 downto 0);
        EX_alucontrol   : out    vl_logic_vector(2 downto 0)
    );
end controller;
