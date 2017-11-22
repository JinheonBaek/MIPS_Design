library verilog;
use verilog.vl_types.all;
entity ID_EX_C is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        regwrite_id     : in     vl_logic;
        memtoreg_id     : in     vl_logic;
        memwrite_id     : in     vl_logic;
        branch_id       : in     vl_logic;
        bnezbit_id      : in     vl_logic;
        regdst_id       : in     vl_logic;
        alusrc_id       : in     vl_logic;
        shiftleft16_id  : in     vl_logic;
        jump_id         : in     vl_logic;
        regwrite_ex     : out    vl_logic;
        memtoreg_ex     : out    vl_logic;
        memwrite_ex     : out    vl_logic;
        branch_ex       : out    vl_logic;
        bnezbit_ex      : out    vl_logic;
        regdst_ex       : out    vl_logic;
        alusrc_ex       : out    vl_logic;
        shiftleft16_ex  : out    vl_logic;
        jump_ex         : out    vl_logic;
        aluop_id        : in     vl_logic_vector(1 downto 0);
        aluop_ex        : out    vl_logic_vector(1 downto 0);
        funct_id        : in     vl_logic_vector(5 downto 0);
        funct_ex        : out    vl_logic_vector(5 downto 0)
    );
end ID_EX_C;
