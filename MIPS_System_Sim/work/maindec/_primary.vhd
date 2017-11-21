library verilog;
use verilog.vl_types.all;
entity maindec is
    port(
        op              : in     vl_logic_vector(5 downto 0);
        funct           : in     vl_logic_vector(5 downto 0);
        signext         : out    vl_logic;
        shiftl16        : out    vl_logic;
        memtoreg        : out    vl_logic;
        memwrite        : out    vl_logic;
        memread         : out    vl_logic;
        branch          : out    vl_logic_vector(1 downto 0);
        alusrc          : out    vl_logic;
        regdst          : out    vl_logic;
        regwrite        : out    vl_logic;
        jump            : out    vl_logic;
        jal             : out    vl_logic;
        jr              : out    vl_logic;
        aluop           : out    vl_logic_vector(1 downto 0)
    );
end maindec;
