library verilog;
use verilog.vl_types.all;
entity IF_ID is
    generic(
        WIDTH           : integer := 8
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        en              : in     vl_logic;
        pcplus4_if      : in     vl_logic_vector;
        instr_if        : in     vl_logic_vector;
        pcplus4_id      : out    vl_logic_vector;
        instr_id        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end IF_ID;
