library verilog;
use verilog.vl_types.all;
entity controller is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        opD             : in     vl_logic_vector(5 downto 0);
        functD          : in     vl_logic_vector(5 downto 0);
        flushE          : in     vl_logic;
        equalD          : in     vl_logic;
        memtoregE       : out    vl_logic;
        memtoregM       : out    vl_logic;
        memtoregW       : out    vl_logic;
        memwrite        : out    vl_logic;
        pcsrcD          : out    vl_logic;
        branchD         : out    vl_logic;
        alusrcE         : out    vl_logic;
        regdstE         : out    vl_logic;
        regwriteE       : out    vl_logic;
        regwriteM       : out    vl_logic;
        regwriteW       : out    vl_logic;
        jumpD           : out    vl_logic;
        alucontrolE     : out    vl_logic_vector(2 downto 0)
    );
end controller;
