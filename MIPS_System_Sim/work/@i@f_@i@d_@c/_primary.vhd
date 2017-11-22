library verilog;
use verilog.vl_types.all;
entity IF_ID_C is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        en              : in     vl_logic;
        opcode          : in     vl_logic_vector(5 downto 0);
        funct           : in     vl_logic_vector(5 downto 0);
        opcode_id       : out    vl_logic_vector(5 downto 0);
        funct_id        : out    vl_logic_vector(5 downto 0)
    );
end IF_ID_C;
