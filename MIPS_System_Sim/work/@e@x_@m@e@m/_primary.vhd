library verilog;
use verilog.vl_types.all;
entity EX_MEM is
    generic(
        WIDTH           : integer := 8
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pcadd2_ex       : in     vl_logic_vector;
        aluout_ex       : in     vl_logic_vector;
        rd2_ex          : in     vl_logic_vector;
        pcadd2_mem      : out    vl_logic_vector;
        aluout_mem      : out    vl_logic_vector;
        rd2_mem         : out    vl_logic_vector;
        d_z             : in     vl_logic;
        q_z             : out    vl_logic;
        dst_ex          : in     vl_logic_vector(4 downto 0);
        dst_mem         : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end EX_MEM;
