library verilog;
use verilog.vl_types.all;
entity ID_EX is
    generic(
        WIDTH           : integer := 8
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pcplus4_id      : in     vl_logic_vector;
        rd1_id          : in     vl_logic_vector;
        rd2_id          : in     vl_logic_vector;
        ext_id          : in     vl_logic_vector;
        pcplus4_ex      : out    vl_logic_vector;
        rd1_ex          : out    vl_logic_vector;
        rd2_ex          : out    vl_logic_vector;
        ext_ex          : out    vl_logic_vector;
        d_rs            : in     vl_logic_vector(4 downto 0);
        d_rt            : in     vl_logic_vector(4 downto 0);
        d_rd            : in     vl_logic_vector(4 downto 0);
        q_rs            : out    vl_logic_vector(4 downto 0);
        q_rt            : out    vl_logic_vector(4 downto 0);
        q_rd            : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end ID_EX;
