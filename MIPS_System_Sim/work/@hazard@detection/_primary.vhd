library verilog;
use verilog.vl_types.all;
entity HazardDetection is
    port(
        ID_rs           : in     vl_logic_vector(4 downto 0);
        ID_rt           : in     vl_logic_vector(4 downto 0);
        EX_rt           : in     vl_logic_vector(4 downto 0);
        EX_regwrite     : in     vl_logic;
        MEM_memtoreg    : in     vl_logic;
        EX_writereg     : in     vl_logic_vector(4 downto 0);
        MEM_writereg    : in     vl_logic_vector(4 downto 0);
        EX_memread      : in     vl_logic;
        MEM_memread     : in     vl_logic;
        ID_branch       : in     vl_logic_vector(1 downto 0);
        IF_stall        : out    vl_logic;
        ID_stall        : out    vl_logic;
        EX_flush        : out    vl_logic
    );
end HazardDetection;
