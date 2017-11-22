library verilog;
use verilog.vl_types.all;
entity Forwaring_Control is
    port(
        rs_ex           : in     vl_logic_vector(4 downto 0);
        rt_ex           : in     vl_logic_vector(4 downto 0);
        dst_mem         : in     vl_logic_vector(4 downto 0);
        dst_wb          : in     vl_logic_vector(4 downto 0);
        ra1             : in     vl_logic_vector(4 downto 0);
        ra2             : in     vl_logic_vector(4 downto 0);
        wa              : in     vl_logic_vector(4 downto 0);
        a_valc          : out    vl_logic_vector(1 downto 0);
        b_valc          : out    vl_logic_vector(1 downto 0);
        regwrite_mem    : in     vl_logic;
        regwrite_wb     : in     vl_logic;
        regwrite        : in     vl_logic;
        rd1_c           : out    vl_logic;
        rd2_c           : out    vl_logic
    );
end Forwaring_Control;
