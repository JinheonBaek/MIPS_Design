library verilog;
use verilog.vl_types.all;
entity Hazard_Detection is
    port(
        memtoreg_ex     : in     vl_logic;
        rt_ex           : in     vl_logic_vector(4 downto 0);
        rs_id           : in     vl_logic_vector(4 downto 0);
        rt_id           : in     vl_logic_vector(4 downto 0);
        hazard          : out    vl_logic
    );
end Hazard_Detection;
