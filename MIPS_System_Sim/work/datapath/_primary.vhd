library verilog;
use verilog.vl_types.all;
entity datapath is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        ID_signext      : in     vl_logic;
        ID_shiftl16     : in     vl_logic;
        WB_memtoreg     : in     vl_logic;
        MEM_pcsrc       : in     vl_logic;
        EX_alusrc       : in     vl_logic;
        EX_regdst       : in     vl_logic;
        EX_memread      : in     vl_logic;
        MEM_regwrite    : in     vl_logic;
        WB_regwrite     : in     vl_logic;
        MEM_jump        : in     vl_logic;
        EX_jal          : in     vl_logic;
        WB_jal          : in     vl_logic;
        MEM_jr          : in     vl_logic;
        EX_alucontrol   : in     vl_logic_vector(2 downto 0);
        ID_op           : out    vl_logic_vector(5 downto 0);
        ID_funct        : out    vl_logic_vector(5 downto 0);
        MEM_zero        : out    vl_logic;
        EX_flush        : out    vl_logic;
        IF_pc           : out    vl_logic_vector(31 downto 0);
        IF_instr        : in     vl_logic_vector(31 downto 0);
        MEM_aluout      : out    vl_logic_vector(31 downto 0);
        MEM_writedata   : out    vl_logic_vector(31 downto 0);
        MEM_readdata    : in     vl_logic_vector(31 downto 0)
    );
end datapath;
