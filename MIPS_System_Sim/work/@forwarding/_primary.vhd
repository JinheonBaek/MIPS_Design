library verilog;
use verilog.vl_types.all;
entity Forwarding is
    port(
        ID_rs           : in     vl_logic_vector(4 downto 0);
        ID_rt           : in     vl_logic_vector(4 downto 0);
        EX_rs           : in     vl_logic_vector(4 downto 0);
        EX_rt           : in     vl_logic_vector(4 downto 0);
        EX_rd           : in     vl_logic_vector(4 downto 0);
        MEM_rt          : in     vl_logic_vector(4 downto 0);
        MEM_rd          : in     vl_logic_vector(4 downto 0);
        WB_rt           : in     vl_logic_vector(4 downto 0);
        WB_rd           : in     vl_logic_vector(4 downto 0);
        EX_regwrite     : in     vl_logic;
        MEM_regwrite    : in     vl_logic;
        WB_regwrite     : in     vl_logic;
        ID_forwarda     : out    vl_logic_vector(1 downto 0);
        ID_forwardb     : out    vl_logic_vector(1 downto 0);
        EX_forwarda     : out    vl_logic_vector(1 downto 0);
        EX_forwardb     : out    vl_logic_vector(1 downto 0);
        MEM_forward     : out    vl_logic
    );
end Forwarding;
