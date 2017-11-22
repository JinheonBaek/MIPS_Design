library verilog;
use verilog.vl_types.all;
entity MEM_WB is
    generic(
        WIDTH           : integer := 8
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        d0              : in     vl_logic_vector;
        d1              : in     vl_logic_vector;
        q0              : out    vl_logic_vector;
        q1              : out    vl_logic_vector;
        dst_mem         : in     vl_logic_vector(4 downto 0);
        dst_wb          : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end MEM_WB;
