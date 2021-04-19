----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2015 04:17:01 PM
-- Design Name: 
-- Module Name: detector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.data_types.all;

entity detector is
    Generic (        
        S_AXI_DATA_WIDTH    : integer    := 32;
        S_AXI_ADDR_WIDTH    : integer    := 18;
        
        MAX_WIDTH     : integer  := 1024;
        MAX_HEIGTH    : integer  := 1536;
        FEATURE_LIMIT : integer  := 1024;
        DEBUG         : integer  := 0;
        SCALE_MODE    : integer  := 1;
        DETECT_STEP_X : integer  := 1;
        DETECT_STEP_Y : integer  := 1;
        USE_AXIL      : integer  := 0;
        
        DEF_IMAGE_WIDTH    : integer := 640;
        DEF_IMAGE_HEIGHT   : integer := 479;
        DEF_WINDOW_HEIGHT  : integer := 24;
        DEF_FEATURE_CNT    : integer := 1023;
        DEF_THRESHOLD      : std_logic_vector(31 downto 0) := X"0001fc00";
        DEF_INSTANCE       : integer := 0;
        DEF_SUM_NULL       : std_logic_vector(31 downto 0) := X"00020000"    
    );
    Port ( 
        aclk        : in STD_LOGIC;
        resetn      : in STD_LOGIC; 
        subsystem_resetn : out STD_LOGIC;
        
                -- configuration port
        s_axi_awaddr    : in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_awprot    : in std_logic_vector(2 downto 0);
        s_axi_awvalid   : in std_logic;
        s_axi_awready   : out std_logic := '1';
        
        s_axi_wdata     : in std_logic_vector(S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_wstrb     : in std_logic_vector((S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_wvalid    : in std_logic;
        s_axi_wready    : out std_logic := '1';
        
        s_axi_bresp     : out std_logic_vector(1 downto 0);
        s_axi_bvalid    : out std_logic;
        s_axi_bready    : in std_logic;
        
        s_axi_araddr    : in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_arprot    : in std_logic_vector(2 downto 0);
        s_axi_arvalid   : in std_logic;
        s_axi_arready   : out std_logic := '1';
        
        s_axi_rdata     : out std_logic_vector(S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_rresp     : out std_logic_vector(1 downto 0);
        s_axi_rvalid    : out std_logic;
        s_axi_rready    : in std_logic;
        
        -- input port
        s_axis_tdata    : in std_logic_vector(31 downto 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tuser    : in std_logic;
        s_axis_tlast    : in std_logic;
        -- output port
        m_axis_tdata    : out std_logic_vector(63 downto 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in std_logic;
        m_axis_tlast    : out std_logic     
        
    );
end detector;

architecture Behavioral of detector is

component control is
    Generic(        
        MAX_HEIGTH          : integer   := 1024;
        DEBUG               : integer  := 0;
        DETECT_STEP_X       : integer  := 1;
        DETECT_STEP_Y       : integer  := 1                
    );
    Port (
        aclk        : in std_logic;
        resetn      : in std_logic;
        
        run         : in std_logic;
        subsystem_resetn : out std_logic;
        
        detect_len_data  : in std_logic_vector(15 downto 0);
        detect_len_addr  : in std_logic_vector(4 downto 0);
        detect_len_we    : in std_logic;
        
        scale_detect_data : in std_logic_vector(31 downto 0);
        scale_detect_addr : in std_logic_vector(9 downto 0);
        scale_detect_we   : in std_logic;
        
        feature_count   : in std_logic_vector(9 downto 0);
        image_height    : in std_logic_vector(12 downto 0);        
        window_height   : in std_logic_vector(12 downto 0);        
        final_threshold : in std_logic_vector(17 downto 0);
        
        work_request    : in std_logic;   
        detect_ena      : in std_logic; 
        next_line       : out std_logic; 
        new_image       : out std_logic;
        new_image_ready : in std_logic;
        input_line      : in std_logic_vector(12 downto 0);
        instance        : in std_logic_vector(7 downto 0);
        sum_null        : in std_logic_vector(17 downto 0);
        
        in0_valid   : in std_logic;
        in0_ready   : out std_logic;
        in0_find    : in std_logic;
        in0         : in Tcontrol;        
        out0_valid  : out std_logic;
        out0_ready  : in std_logic;
        out0        : out Tcontrol;        
        
        in1_valid   : in std_logic;
        in1_ready   : out std_logic;
        in1_find    : in std_logic;
        in1         : in Tcontrol;
        out1_valid  : out std_logic;
        out1_ready  : in std_logic;
        out1        : out Tcontrol;
        
        m_axis_tdata    : out std_logic_vector(63 downto 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in std_logic;
        m_axis_tlast    : out std_logic    
    
    );
end component;

component instruct_image is
    Generic(
        INSTRUCT_LIMIT  : integer := 1024
    );
	Port(
        aclk        : in std_logic;
        
        in0_addr    : in std_logic_vector(9 downto 0);
        in0_valid   : in std_logic;
        in0_ready   : out std_logic;
        out0_data   : out std_logic_vector(31 downto 0);
        out0_valid  : out std_logic;
        out0_ready  : in std_logic;
        
        in1_addr    : in std_logic_vector(9 downto 0);
        in1_valid   : in std_logic;
        in1_ready   : out std_logic;
        out1_data   : out std_logic_vector(31 downto 0);
        out1_valid  : out std_logic;
        out1_ready  : in std_logic;        
        
        instr_data  : in std_logic_vector(31 downto 0);    
        instr_addr  : in std_logic_vector(9 downto 0);
        instr_ena   : in std_logic
    );
end component;

component memory_config is
    Generic(
            S_AXI_DATA_WIDTH	: integer	:= 32;
            S_AXI_ADDR_WIDTH    : integer    := 16;
            
            DEF_IMAGE_WIDTH    : integer := 640;
            DEF_IMAGE_HEIGHT   : integer := 479;
            DEF_WINDOW_HEIGHT  : integer := 24;
            DEF_FEATURE_CNT    : integer := 1023;
            DEF_THRESHOLD      : std_logic_vector(31 downto 0) := X"0001fc00";
            DEF_INSTANCE       : integer := 0;
            DEF_SUM_NULL       : std_logic_vector(31 downto 0) := X"00020000" 
    );
    Port ( 
        ACLK 			: in STD_LOGIC;
        ARESETN 		: in STD_LOGIC;
        
        -- konfiguracni port
        
        s_axi_awaddr	: in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_awprot    : in std_logic_vector(2 downto 0);
        s_axi_awvalid   : in std_logic;
        s_axi_awready   : out std_logic;
        
        s_axi_wdata     : in std_logic_vector(S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_wstrb     : in std_logic_vector((S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_wvalid    : in std_logic;
        s_axi_wready    : out std_logic;
        
        s_axi_bresp     : out std_logic_vector(1 downto 0);                   --
        s_axi_bvalid    : out std_logic;
        s_axi_bready    : in std_logic;
        
        s_axi_araddr    : in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_arprot    : in std_logic_vector(2 downto 0);
        s_axi_arvalid   : in std_logic;
        s_axi_arready   : out std_logic;
        
        s_axi_rdata     : out std_logic_vector(S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_rresp     : out std_logic_vector(1 downto 0);                   --
        s_axi_rvalid    : out std_logic;
        s_axi_rready    : in std_logic;
        
        run             : out std_logic;
        
        scale_addr_data : out std_logic_vector(15 downto 0);
        scale_addr_addr : out std_logic_vector(4 downto 0);
        scale_addr_we   : out std_logic;
        
        scale_len_data  : out std_logic_vector(15 downto 0);
        scale_len_addr  : out std_logic_vector(4 downto 0);
        scale_len_we    : out std_logic;
        
        scale_conf_data : out std_logic_vector(31 downto 0);
        scale_conf_addr : out std_logic_vector(9 downto 0);
        scale_conf_we   : out std_logic;
        
        scale_detect_data : out std_logic_vector(31 downto 0);
        scale_detect_addr : out std_logic_vector(9 downto 0);
        scale_detect_we   : out std_logic;
        
        detect_len_data : out std_logic_vector(15 downto 0);
        detect_len_addr : out std_logic_vector(4 downto 0);
        detect_len_we   : out std_logic;
        
        instr_data      : out std_logic_vector(31 downto 0);
        instr_addr      : out std_logic_vector(9 downto 0);
        instr_we        : out std_logic;
        
        table_data      : out std_logic_vector(8 downto 0);
        table_addr      : out std_logic_vector(15 downto 0);
        table_we        : out std_logic;
        
        threshold_data  : out std_logic_vector(17 downto 0);
        threshold_addr  : out std_logic_vector(9 downto 0);
        threshold_we    : out std_logic;
        
        image_width     : out std_logic_vector(12 downto 0);
        image_height    : out std_logic_vector(12 downto 0);
        window_height   : out std_logic_vector(12 downto 0);
        feature_count   : out std_logic_vector(9 downto 0);
        final_threshold : out std_logic_vector(17 downto 0);        
        instance        : out std_logic_vector(7 downto 0);
        sum_null        : out std_logic_vector(17 downto 0)
    );
end component;

component memory is
    Generic(        
        MEM_TYPE            : integer   := 0;
        MAX_WIDTH           : integer   := 1024;
        MAX_HEIGTH          : integer   := 1024;
        DEBUG               : integer  := 0;
        SCALE_MODE          : integer   := 0               
    );
    Port ( 
        aclk : in STD_LOGIC;
        resetn : in STD_LOGIC;
        
        scale_addr_data     : in std_logic_vector(15 downto 0);
        scale_addr_addr     : in std_logic_vector(4 downto 0);
        scale_addr_we       : in std_logic;
        
        scale_len_data      : in std_logic_vector(15 downto 0);
        scale_len_addr      : in std_logic_vector(4 downto 0);
        scale_len_we        : in std_logic;
        
        scale_conf_data  : in std_logic_vector(31 downto 0);
        scale_conf_addr  : in std_logic_vector(9 downto 0);
        scale_conf_we    : in std_logic;        
        
        image_width         : in std_logic_vector(12 downto 0);
        image_height        : in std_logic_vector(12 downto 0);
        window_height       : in std_logic_vector(12 downto 0);
        
                -- input port
        s_axis_tdata    : in std_logic_vector(31 downto 0);
        s_axis_tvalid   : in std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tuser    : in std_logic;
        s_axis_tlast    : in std_logic;
        
        
        -- 
        work_request    : out std_logic;
        work_ena        : in std_logic;
        detect_ena      : out std_logic;
        
        next_line       : in std_logic; 
        new_image       : in std_logic;
        new_image_ready : out std_logic;
        input_line      : out std_logic_vector(12 downto 0);
        
        -- data0 port
        addr0_x         : in std_logic_vector(12 downto 0);
        addr0_y         : in std_logic_vector(12 downto 0);    
        addr0_scale     : in std_logic_vector(4 downto 0);
        addr0_valid     : in std_logic;
        addr0_ready     : out std_logic;    
        data0           : out array_6x6x8b;
        data0_valid     : out std_logic;
        data0_ready     : in std_logic;
        
        -- data 1 port
        addr1_x         : in std_logic_vector(12 downto 0);
        addr1_y         : in std_logic_vector(12 downto 0);
        addr1_scale     : in std_logic_vector(4 downto 0);      
        addr1_valid     : in std_logic;
        addr1_ready     : out std_logic;  
        data1           : out array_6x6x8b;
        data1_valid     : out std_logic;
        data1_ready     : in std_logic               
        
    );
end component;

component extractor is
    Generic(
        FEATURE_TYPE    : integer := 0;
        FEATURE_LIMIT   : integer := 1024
    );
    Port ( 
        aclk            : in std_logic;
        
        table_data      : in std_logic_vector(8 downto 0);
        table_addr      : in std_logic_vector(15 downto 0);
        table_we        : in std_logic;
        
        threshold_data  : in std_logic_vector(17 downto 0);
        threshold_addr  : in std_logic_vector(9 downto 0);
        threshold_we    : in std_logic;        
        
        dsp_mode0       : in std_logic_vector(1 downto 0);
        rank0           : in std_logic_vector(7 downto 0);
        index0          : in std_logic_vector(9 downto 0);
        suma0_in        : in std_logic_vector(17 downto 0);
        data0_in        : in array_6x6x8b;
        data0_in_valid  : in std_logic;
        data0_in_ready  : out std_logic;        
        
        out0_status     : out std_logic;
        out0_valid      : out std_logic;
        out0_ready      : in std_logic;
        out0_suma       : out std_logic_vector(17 downto 0);        
        
        dsp_mode1       : in std_logic_vector(1 downto 0);
        rank1           : in std_logic_vector(7 downto 0);
        index1          : in std_logic_vector(9 downto 0);
        suma1_in        : in std_logic_vector(17 downto 0);
        data1_in        : in array_6x6x8b;
        data1_in_valid  : in std_logic;
        data1_in_ready  : out std_logic;
        
        out1_status     : out std_logic;
        out1_valid      : out std_logic;
        out1_ready      : in std_logic;
        out1_suma       : out std_logic_vector(17 downto 0)  
  );
end component;

ATTRIBUTE MARK_DEBUG : string;
ATTRIBUTE KEEP : string;

constant PIPELINE_LEN   : integer := 13;
type array_PIPELINE_LENxTcontrol is array (PIPELINE_LEN downto 1) of Tcontrol;
type array_dsp_pipe is array (8 downto 2) of std_logic_vector(1 downto 0);
type array_rank_pipe is array (8 downto 2) of std_logic_vector(7 downto 0);



signal scale_addr_data     : std_logic_vector(15 downto 0);
signal scale_addr_addr     : std_logic_vector(4 downto 0);
signal scale_addr_we       : std_logic := '0';

signal scale_len_data      : std_logic_vector(15 downto 0) := (others => '0');
signal scale_len_addr      : std_logic_vector(4 downto 0) := (others => '0');
signal scale_len_we        : std_logic := '0';

signal scale_conf_data      : std_logic_vector(31 downto 0);
signal scale_conf_addr      : std_logic_vector(9 downto 0);
signal scale_conf_we        : std_logic := '0';

signal scale_detect_data    : std_logic_vector(31 downto 0);
signal scale_detect_addr    : std_logic_vector(9 downto 0);
signal scale_detect_we      : std_logic := '0';

signal detect_len_data     : std_logic_vector(15 downto 0);
signal detect_len_addr     : std_logic_vector(4 downto 0);
signal detect_len_we       : std_logic := '0';

signal table_data          : std_logic_vector(8 downto 0);
signal table_addr          : std_logic_vector(15 downto 0);
signal table_we            : std_logic := '0';

signal threshold_data      : std_logic_vector(17 downto 0);
signal threshold_addr      : std_logic_vector(9 downto 0);
signal threshold_we        : std_logic := '0';

signal instance         : std_logic_vector(7 downto 0);
signal sum_null         : std_logic_vector(17 downto 0);
signal image_width      : std_logic_vector(12 downto 0);
signal image_height     : std_logic_vector(12 downto 0);
signal window_height    : std_logic_vector(12 downto 0);
signal feature_count    : std_logic_vector(9 downto 0);
signal final_threshold  : std_logic_vector(17 downto 0);
signal run              : std_logic := '0';

signal instr_data       : std_logic_vector(31 downto 0);
signal instr_addr       : std_logic_vector(9 downto 0);
signal instr_we         : std_logic;

signal cont_next_line   : std_logic; 
signal cont_new_image   : std_logic;
signal cont_image_ready : std_logic;
signal cont_input_line  : std_logic_vector(12 downto 0);


signal control0_valid   : std_logic;
signal control1_valid   : std_logic;
signal control0_ready   : std_logic;
signal control1_ready   : std_logic;
signal control0_data    : Tcontrol;
signal control1_data    : Tcontrol;

signal control0         : array_PIPELINE_LENxTcontrol;
signal control1         : array_PIPELINE_LENxTcontrol;
signal dsp_pipe0        : array_dsp_pipe;
signal dsp_pipe1        : array_dsp_pipe;
signal rank_pipe0       : array_rank_pipe;
signal rank_pipe1       : array_rank_pipe;

signal instruct0_data   : std_logic_vector(31 downto 0);
signal instruct1_data   : std_logic_vector(31 downto 0);
signal instruct0_valid  : std_logic;
signal instruct1_valid  : std_logic;
signal instruct0_ready  : std_logic;
signal instruct1_ready  : std_logic;

signal memory_resetn    : std_logic := '1';
signal mem0_x           : std_logic_vector(12 downto 0);
signal mem0_y           : std_logic_vector(12 downto 0);
signal mem1_x           : std_logic_vector(12 downto 0);
signal mem1_y           : std_logic_vector(12 downto 0);
signal mem0_data        : array_6x6x8b;
signal mem1_data        : array_6x6x8b;
signal mem0_valid       : std_logic;
signal mem1_valid       : std_logic;
signal mem0_ready       : std_logic;
signal mem1_ready       : std_logic;

signal dsp0_data        : array_3x3x8b;
signal dsp1_data        : array_3x3x8b;
signal dsp0_valid       : std_logic;
signal dsp1_valid       : std_logic;
signal dsp0_ready       : std_logic := '1';
signal dsp1_ready       : std_logic := '1';

signal feature0_valid   : std_logic;
signal feature1_valid   : std_logic;
signal feature0_ready   : std_logic;
signal feature1_ready   : std_logic;
signal feature0_find    : std_logic;
signal feature1_find    : std_logic;
signal feature0_suma    : std_logic_vector(17 downto 0);
signal feature1_suma    : std_logic_vector(17 downto 0);
signal feature0_data    : Tcontrol;
signal feature1_data    : Tcontrol;

signal work_request     : std_logic := '0';
signal work_ena         : std_logic_vector(1 downto 0) := "00";
signal detect_ena       : std_logic := '0';

ATTRIBUTE MARK_DEBUG of instruct0_data: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of control0_data: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of control0: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of feature0_suma: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of rank_pipe0: SIGNAL IS "TRUE";


ATTRIBUTE KEEP of instruct0_data: SIGNAL IS "TRUE";
ATTRIBUTE KEEP of control0_data: SIGNAL IS "TRUE";
ATTRIBUTE KEEP of control0: SIGNAL IS "TRUE";
ATTRIBUTE KEEP of feature0_suma: SIGNAL IS "TRUE";
ATTRIBUTE KEEP of rank_pipe0: SIGNAL IS "TRUE";

begin

subsystem_resetn <= memory_resetn;

sync0_control: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if control0_ready = '1' then
            control0(1) <= control0_data;    
            dsp_pipe0(2) <= instruct0_data(9 downto 8);
            rank_pipe0(2)<= instruct0_data(7 downto 0);   
            for i in 2 to PIPELINE_LEN loop
                control0(i) <= control0(i-1);
            end loop;
            
            for i in 3 to 8 loop
                dsp_pipe0(i) <= dsp_pipe0(i-1);
                rank_pipe0(i)<= rank_pipe0(i-1);
            end loop;
        --end if;
    end if;
end process;

sync1_control: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if control1_ready = '1' then
            control1(1) <= control1_data;    
            dsp_pipe1(2) <= instruct1_data(9 downto 8);
            rank_pipe1(2)<= instruct1_data(7 downto 0);   
            for i in 2 to PIPELINE_LEN loop
                control1(i) <= control1(i-1);
            end loop;
            
            for i in 3 to 8 loop
                dsp_pipe1(i) <= dsp_pipe1(i-1);
                rank_pipe1(i)<= rank_pipe1(i-1);
            end loop;
        --end if;
    end if;
end process;


--------------------------------------------------------------------------
gen_axil: if USE_AXIL = 1 generate
memory_config_map: memory_config
    Generic map(
            S_AXI_DATA_WIDTH	=> S_AXI_DATA_WIDTH,
            S_AXI_ADDR_WIDTH    => S_AXI_ADDR_WIDTH,
            
            DEF_IMAGE_WIDTH    => DEF_IMAGE_WIDTH,
            DEF_IMAGE_HEIGHT   => DEF_IMAGE_HEIGHT,
            DEF_WINDOW_HEIGHT  => DEF_WINDOW_HEIGHT,
            DEF_FEATURE_CNT    => DEF_FEATURE_CNT,
            DEF_THRESHOLD      => DEF_THRESHOLD,
            DEF_INSTANCE       => DEF_INSTANCE,
            DEF_SUM_NULL       => DEF_SUM_NULL
    )
    Port map( 
        ACLK 			=> ACLK,
        ARESETN 		=> RESETN,
        
        -- konfiguracni port
        
        s_axi_awaddr	=> s_axi_awaddr,
        s_axi_awprot    => s_axi_awprot,
        s_axi_awvalid   => s_axi_awvalid,
        s_axi_awready   => s_axi_awready,
        
        s_axi_wdata     => s_axi_wdata,
        s_axi_wstrb     => s_axi_wstrb,
        s_axi_wvalid    => s_axi_wvalid,
        s_axi_wready    => s_axi_wready,
        
        s_axi_bresp     => s_axi_bresp,
        s_axi_bvalid    => s_axi_bvalid,
        s_axi_bready    => s_axi_bready,
        
        s_axi_araddr    => s_axi_araddr,
        s_axi_arprot    => s_axi_arprot,
        s_axi_arvalid   => s_axi_arvalid,
        s_axi_arready   => s_axi_arready,
        
        s_axi_rdata     => s_axi_rdata,
        s_axi_rresp     => s_axi_rresp,
        s_axi_rvalid    => s_axi_rvalid,
        s_axi_rready    => s_axi_rready,
        
        run             => run,
        
        scale_addr_data => scale_addr_data,
        scale_addr_addr => scale_addr_addr,
        scale_addr_we   => scale_addr_we,
        
        scale_len_data  => scale_len_data,
        scale_len_addr  => scale_len_addr,
        scale_len_we    => scale_len_we,
        
        scale_conf_data => scale_conf_data,
        scale_conf_addr => scale_conf_addr,
        scale_conf_we   => scale_conf_we,
        
        scale_detect_data => scale_detect_data,
        scale_detect_addr => scale_detect_addr,
        scale_detect_we   => scale_detect_we,
        
        detect_len_data  => detect_len_data,
        detect_len_addr  => detect_len_addr,
        detect_len_we    => detect_len_we,
        
        instr_data      => instr_data,
        instr_addr      => instr_addr,
        instr_we        => instr_we,
        
        table_data      => table_data,
        table_addr      => table_addr,
        table_we        => table_we,
        
        threshold_data  => threshold_data,
        threshold_addr  => threshold_addr,
        threshold_we    => threshold_we,
        
        image_width     => image_width,
        image_height    => image_height,
        window_height   => window_height,
        feature_count   => feature_count,
        final_threshold => final_threshold,
        instance        => instance,
        sum_null        => sum_null
    );
end generate;

gen_noAxil: if USE_AXIL = 0 generate
signal startUp_cnt  : std_logic_vector(3 downto 0);
begin
    image_width     <= conv_std_logic_vector(DEF_IMAGE_WIDTH,13);
    image_height    <= conv_std_logic_vector(DEF_IMAGE_HEIGHT,13);
    window_height   <= conv_std_logic_vector(DEF_WINDOW_HEIGHT,13);
    feature_count   <= conv_std_logic_vector(DEF_FEATURE_CNT,10);
    final_threshold <= DEF_THRESHOLD(17 downto 0);
    instance        <= conv_std_logic_vector(DEF_INSTANCE,8);
    sum_null        <= DEF_SUM_NULL(17 downto 0);
    
    startUp_proc: process (aclk)
    begin
        if aclk'event and aclk = '1' then
            if resetn = '0' then
                run <= '0';
                startUp_cnt <= X"0";
            else
                if startUp_cnt = X"F" then
                    run <= '1';
                else
                    startUp_cnt <= startUp_cnt + '1';
                end if;
            end if;
        end if;
    end process;
    
end generate;
--------------------------------------------------------------------------------

feature0_data.x <= control0(13).x;
feature0_data.y <= control0(13).y;
feature0_data.scale <= control0(13).scale;
feature0_data.index <= control0(13).index;
feature0_data.pos <= control0(13).pos;
feature0_data.suma <= feature0_suma;

feature1_data.x <= control1(13).x;
feature1_data.y <= control1(13).y;
feature1_data.scale <= control1(13).scale;
feature1_data.index <= control1(13).index;
feature1_data.pos <= control1(13).pos;
feature1_data.suma <= feature1_suma;

control_map: control
    Generic map(
        MAX_HEIGTH  => MAX_HEIGTH,
        DEBUG       => DEBUG,
        DETECT_STEP_X => DETECT_STEP_X,
        DETECT_STEP_Y => DETECT_STEP_Y  
    )
    Port map(
        aclk        => aclk,
        resetn      => resetn,        
        run         => run,
        subsystem_resetn => memory_resetn,        
        
        detect_len_data  => detect_len_data,
        detect_len_addr  => detect_len_addr,
        detect_len_we    => detect_len_we,
        
        scale_detect_data => scale_detect_data,
        scale_detect_addr => scale_detect_addr,
        scale_detect_we   => scale_detect_we,
        
        feature_count   => feature_count,
        image_height    => image_height,      
        window_height   => window_height,
        final_threshold => final_threshold,
        work_request    => work_request,
        detect_ena      => detect_ena,
        next_line       => cont_next_line,
        new_image       => cont_new_image,
        new_image_ready => cont_image_ready,
        input_line      => cont_input_line,
        instance        => instance,
        sum_null        => sum_null,
        
        in0_valid   => feature0_valid,
        in0_ready   => feature0_ready,
        in0_find    => feature0_find,
        in0         => feature0_data,      
        out0_valid  => control0_valid,
        out0_ready  => control0_ready,
        out0        => control0_data,   
        
        in1_valid   => feature1_valid,
        in1_ready   => feature1_ready,
        in1_find    => feature1_find,
        in1         => feature1_data, 
        out1_valid  => control1_valid,
        out1_ready  => control1_ready,
        out1        => control1_data,
        
        m_axis_tdata    => m_axis_tdata,
        m_axis_tvalid   => m_axis_tvalid,
        m_axis_tready   => m_axis_tready,
        m_axis_tlast    => m_axis_tlast
    
    );

instruct_image_map: instruct_image 
    Generic map(
        INSTRUCT_LIMIT  => FEATURE_LIMIT
    )
	Port map(
        aclk        => aclk,
        
        in0_addr    => control0_data.index, 
        in0_valid   => control0_valid, 
        in0_ready   => control0_ready,
        out0_data   => instruct0_data,
        out0_valid  => instruct0_valid,
        out0_ready  => instruct0_ready,
        
        in1_addr    => control1_data.index,
        in1_valid   => control1_valid, 
        in1_ready   => control1_ready,
        out1_data   => instruct1_data,
        out1_valid  => instruct1_valid,
        out1_ready  => instruct1_ready,
        
        instr_data  => instr_data,
        instr_addr  => instr_addr,
        instr_ena   => instr_we
    );
    
mem0_x <= control0(1).x + instruct0_data(23 downto 17);
mem1_x <= control1(1).x + instruct1_data(23 downto 17);

mem0_y <= control0(1).y + instruct0_data(16 downto 10);
mem1_y <= control1(1).y + instruct1_data(16 downto 10);

memory_map: memory
    Generic map(
        MEM_TYPE            => 0,
        MAX_WIDTH           => MAX_WIDTH,
        MAX_HEIGTH          => MAX_HEIGTH,
        DEBUG               => DEBUG,
        SCALE_MODE          => SCALE_MODE            
    )
    Port map( 
        aclk    => aclk,
        resetn  => memory_resetn,
        
        scale_addr_data     => scale_addr_data,
        scale_addr_addr     => scale_addr_addr,
        scale_addr_we       => scale_addr_we,
        
        scale_len_data      => scale_len_data,
        scale_len_addr      => scale_len_addr,
        scale_len_we        => scale_len_we,
        
        scale_conf_data     => scale_conf_data,
        scale_conf_addr     => scale_conf_addr,
        scale_conf_we       => scale_conf_we,
        
        image_width         => image_width,
        image_height        => image_height,
        window_height       => window_height,
        
                -- input port
        s_axis_tdata    => s_axis_tdata,
        s_axis_tvalid   => s_axis_tvalid,
        s_axis_tready   => s_axis_tready,
        s_axis_tuser    => s_axis_tuser,
        s_axis_tlast    => s_axis_tlast,
        
        
        -- 
        work_request    => work_request,
        work_ena        => work_ena(1),
        detect_ena      => detect_ena,
        next_line       => cont_next_line, 
        new_image       => cont_new_image, 
        new_image_ready => cont_image_ready,
        input_line      => cont_input_line,
        -- data0 port
        addr0_x         => mem0_x, 
        addr0_y         => mem0_y, 
        addr0_scale     => control0(1).scale, 
        addr0_valid     => instruct0_valid,
        addr0_ready     => instruct0_ready,
        data0           => mem0_data,
        data0_valid     => mem0_valid,
        data0_ready     => mem0_ready, -- '1',
        -- data 1 port
        addr1_x         => mem1_x, 
        addr1_y         => mem1_y, 
        addr1_scale     => control1(1).scale, 
        addr1_valid     => instruct1_valid,
        addr1_ready     => instruct1_ready,
        data1           => mem1_data,
        data1_valid     => mem1_valid,
        data1_ready     => mem1_ready   --'1'    
        
    );
    
extractor_map: extractor
    Generic map(
        feature_type    => 0,
        FEATURE_LIMIT   => FEATURE_LIMIT
    )
    Port map( 
        aclk            => aclk,
        
        table_data      => table_data,
        table_addr      => table_addr,
        table_we        => table_we,
        
        threshold_data  => threshold_data,
        threshold_addr  => threshold_addr,
        threshold_we    => threshold_we,   
        
        dsp_mode0       => dsp_pipe0(7),
        rank0           => rank_pipe0(7),
        index0          => control0(7).index,
        suma0_in        => control0(7).suma,
        data0_in        => mem0_data,
        data0_in_valid  => mem0_valid,
        data0_in_ready  => mem0_ready,  
        
        out0_status     => feature0_find,
        out0_valid      => feature0_valid,
        out0_ready      => feature0_ready,
        out0_suma       => feature0_suma,
        
        dsp_mode1       => dsp_pipe1(7),
        rank1           => rank_pipe1(7),
        index1          => control1(7).index,
        suma1_in        => control1(7).suma,
        data1_in        => mem1_data,
        data1_in_valid  => mem1_valid,
        data1_in_ready  => mem1_ready,  
        
        out1_status     => feature1_find,
        out1_valid      => feature1_valid,
        out1_ready      => feature1_ready,
        out1_suma       => feature1_suma
  );

end Behavioral;
