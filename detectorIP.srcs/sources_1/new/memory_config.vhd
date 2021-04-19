----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2015 10:43:21 AM
-- Design Name: 
-- Module Name: memory_config - Behavioral
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

entity memory_config is
    Generic(
            S_AXI_DATA_WIDTH	: integer	:= 32;
            S_AXI_ADDR_WIDTH    : integer    := 18;
            
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
        
        run             : out std_logic := '0';
        
        scale_addr_data : out std_logic_vector(15 downto 0) := (others => '0');
        scale_addr_addr : out std_logic_vector(4 downto 0) := (others => '0');
        scale_addr_we   : out std_logic := '0';
        
        scale_len_data  : out std_logic_vector(15 downto 0) := (others => '0');
        scale_len_addr  : out std_logic_vector(4 downto 0) := (others => '0');
        scale_len_we    : out std_logic := '0';
        
        scale_conf_data : out std_logic_vector(31 downto 0) := (others => '0');
        scale_conf_addr : out std_logic_vector(9 downto 0) := (others => '0');
        scale_conf_we   : out std_logic := '0';
        
        scale_detect_data : out std_logic_vector(31 downto 0) := (others => '0');
        scale_detect_addr : out std_logic_vector(9 downto 0) := (others => '0');
        scale_detect_we   : out std_logic := '0';
        
        detect_len_data : out std_logic_vector(15 downto 0) := (others => '0');
        detect_len_addr : out std_logic_vector(4 downto 0) := (others => '0');
        detect_len_we   : out std_logic := '0';
        
        instr_data      : out std_logic_vector(31 downto 0) := (others => '0');
        instr_addr      : out std_logic_vector(9 downto 0) := (others => '0');
        instr_we        : out std_logic := '0';
        
        table_data      : out std_logic_vector(8 downto 0);
        table_addr      : out std_logic_vector(15 downto 0);
        table_we        : out std_logic;
        
        threshold_data  : out std_logic_vector(17 downto 0);
        threshold_addr  : out std_logic_vector(9 downto 0);
        threshold_we    : out std_logic;
        
        image_width     : out std_logic_vector(12 downto 0):= conv_std_logic_vector(DEF_IMAGE_WIDTH, 13);
        image_height    : out std_logic_vector(12 downto 0):= conv_std_logic_vector(DEF_IMAGE_HEIGHT, 13);        
        window_height   : out std_logic_vector(12 downto 0) := conv_std_logic_vector(DEF_WINDOW_HEIGHT, 13);
        feature_count   : out std_logic_vector(9 downto 0) := conv_std_logic_Vector(DEF_FEATURE_CNT,10);
        final_threshold : out std_logic_vector(17 downto 0):= DEF_THRESHOLD(17 downto 0);
        
        instance        : out std_logic_vector(7 downto 0) := conv_std_logic_vector(DEF_INSTANCE,8);
        sum_null        : out std_logic_vector(17 downto 0):= DEF_SUM_NULL(17 downto 0)
    );
end memory_config;

architecture Behavioral of memory_config is

type t_state is (IDLE, READ_DATA, READ_RESP, WRITE_DATA, WRITE_RESP);
signal state, next_state      : t_state := IDLE;
signal address			: std_logic_vector(17 downto 0);
signal next_address		: std_logic_vector(17 downto 0);
signal next_data        : std_logic_vector(15 downto 0);


signal reg_run             : std_logic := '0';
        
signal reg_scale_addr_data : std_logic_vector(15 downto 0) := (others => '0');
signal reg_scale_addr_addr : std_logic_vector(4 downto 0) := (others => '0');
signal reg_scale_addr_we   : std_logic := '0';
signal reg_scale_len_data  : std_logic_vector(15 downto 0) := (others => '0');
signal reg_scale_len_addr  : std_logic_vector(4 downto 0) := (others => '0');
signal reg_scale_len_we    : std_logic := '0';

signal reg_scale_conf_data : std_logic_vector(31 downto 0) := (others => '0');
signal reg_scale_conf_addr : std_logic_vector(9 downto 0) := (others => '0');
signal reg_scale_conf_we   : std_logic := '0';

signal reg_scale_detect_data : std_logic_vector(31 downto 0) := (others => '0');
signal reg_scale_detect_addr : std_logic_vector(9 downto 0) := (others => '0');
signal reg_scale_detect_we   : std_logic := '0';

signal reg_detect_len_data : std_logic_vector(15 downto 0) := (others => '0');
signal reg_detect_len_addr : std_logic_vector(4 downto 0) := (others => '0');
signal reg_detect_len_we   : std_logic := '0';

signal reg_instr_data      : std_logic_vector(31 downto 0) := (others => '0');
signal reg_instr_addr      : std_logic_vector(9 downto 0) := (others => '0');
signal reg_instr_we        : std_logic := '0';

signal reg_table_data      : std_logic_vector(8 downto 0);
signal reg_table_addr      : std_logic_vector(15 downto 0);
signal reg_table_we        : std_logic;

signal reg_threshold_data  : std_logic_vector(17 downto 0);
signal reg_threshold_addr  : std_logic_vector(9 downto 0);
signal reg_threshold_we    : std_logic;

signal reg_image_width     : std_logic_vector(12 downto 0):= conv_std_logic_vector(DEF_IMAGE_WIDTH, 13);
signal reg_image_height    : std_logic_vector(12 downto 0):= conv_std_logic_vector(DEF_IMAGE_HEIGHT, 13);        
signal reg_window_height   : std_logic_vector(12 downto 0) := conv_std_logic_vector(DEF_WINDOW_HEIGHT, 13);
signal reg_feature_count   : std_logic_vector(9 downto 0) := conv_std_logic_Vector(DEF_FEATURE_CNT,10);
signal reg_final_threshold : std_logic_vector(17 downto 0):= DEF_THRESHOLD(17 downto 0);

signal reg_instance        : std_logic_vector(7 downto 0):= conv_std_logic_vector(DEF_INSTANCE,8);
signal reg_sum_null        : std_logic_vector(17 downto 0):= DEF_SUM_NULL(17 downto 0);


begin

sync_proc: process(aclk)
begin
    if aclk'event and aclk = '1' then
        run             <= reg_run;     
        scale_addr_data <= reg_scale_addr_data; 
        scale_addr_addr <= reg_scale_addr_addr; 
        scale_addr_we   <= reg_scale_addr_we;         
        scale_len_data  <= reg_scale_len_data; 
        scale_len_addr  <= reg_scale_len_addr; 
        scale_len_we    <= reg_scale_len_we;         
        scale_conf_data <= reg_scale_conf_data;
        scale_conf_addr <= reg_scale_conf_addr;
        scale_conf_we   <= reg_scale_conf_we;  
        scale_detect_data <= reg_scale_detect_data;
        scale_detect_addr <= reg_scale_detect_addr;
        scale_detect_we   <= reg_scale_detect_we;       
        detect_len_data <= reg_detect_len_data;
        detect_len_addr <= reg_detect_len_addr;
        detect_len_we   <= reg_detect_len_we;        
        instr_data      <= reg_instr_data;
        instr_addr      <= reg_instr_addr;
        instr_we        <= reg_instr_we;        
        table_data      <= reg_table_data;
        table_addr      <= reg_table_addr;
        table_we        <= reg_table_we;        
        threshold_data  <= reg_threshold_data;
        threshold_addr  <= reg_threshold_addr;
        threshold_we    <= reg_threshold_we;        
        image_width     <= reg_image_width;
        image_height    <= reg_image_height;       
        window_height   <= reg_window_height;
        feature_count   <= reg_feature_count;
        final_threshold <= reg_final_threshold;
        instance        <= reg_instance;
        sum_null        <= reg_sum_null;
    end if;
end process;

AXI_L_sync_proc: process(aresetn, aclk)
begin
	if aresetn = '0' then
        state <= IDLE;
        address <= (others => '0');     

    elsif aclk'event and aclk = '1' then
        state <= next_state;
        
        if state = IDLE then
            address <= next_address;
        end if;
        
        reg_table_data <= (others => '0');
        reg_table_addr <= (others => '0');        
        reg_table_we   <= '0';

        reg_threshold_data  <= (others => '0');
        reg_threshold_addr  <= (others => '0');
        reg_threshold_we    <= '0';
        
        reg_instr_data      <= (others => '0');
        reg_instr_addr      <= (others => '0');
        reg_instr_we        <= '0';
        
        reg_scale_conf_data      <= (others => '0');
        reg_scale_conf_addr      <= (others => '0');
        reg_scale_conf_we        <= '0';
        
        reg_scale_detect_data   <= (others => '0');
        reg_scale_detect_addr   <= (others => '0');
        reg_scale_detect_we     <= '0';
        
        reg_scale_addr_data      <= (others => '0');
        reg_scale_addr_addr      <= (others => '0');
        reg_scale_addr_we        <= '0';

        reg_scale_len_data      <= (others => '0');
        reg_scale_len_addr      <= (others => '0');
        reg_scale_len_we        <= '0';

        reg_detect_len_data      <= (others => '0');
        reg_detect_len_addr      <= (others => '0');
        reg_detect_len_we        <= '0';
        
        
        
        
        if state = WRITE_DATA and s_axi_wvalid = '1' then
            if address = "00"&X"0008" then
                reg_instance <= s_axi_wdata(7 downto 0);
            end if;
            if address = "00"&X"000c" then
                reg_sum_null <= s_axi_wdata(17 downto 0);
            end if;
            if address = "00"&X"0010" then
                reg_run <= s_axi_wdata(0);
            end if;
            if address = "00"&X"0014" then
                reg_image_width <= s_axi_wdata(12 downto 0);
            end if;
            if address = "00"&X"0018" then
                reg_image_height <= s_axi_wdata(12 downto 0);
            end if;
            if address = "00"&X"001C" then
                reg_window_height <= s_axi_wdata(12 downto 0);
            end if;
            if address = "00"&X"0020" then
                reg_feature_count <= s_axi_wdata(9 downto 0);
            end if;
            if address = "00"&X"0024" then
                reg_final_threshold <= s_axi_wdata(17 downto 0);
            end if;
            if address(17) = '1' then
                next_data <= s_axi_wdata(31 downto 16);
                reg_table_data<= s_axi_wdata(8 downto 0);
                reg_table_addr<= address(16 downto 2)&'0';
                reg_table_we  <= '1';
            end if;
            if address(17 downto 12) = "000001" then
                reg_threshold_data  <= s_axi_wdata(17 downto 0);
                reg_threshold_addr  <= address(11 downto 2);
                reg_threshold_we    <= '1';
            end if;
            if address(17 downto 12) = "000010" then
                reg_instr_data      <= s_axi_wdata;
                reg_instr_addr      <= address(11 downto 2);
                reg_instr_we        <= '1';
            end if;
            
            if address(17 downto 12) = "000011" then
                reg_scale_conf_data      <= s_axi_wdata;
                reg_scale_conf_addr      <= address(11 downto 2);
                reg_scale_conf_we        <= '1';
            end if;
            
            if address(17 downto 12) = "000100" then
                reg_scale_detect_data      <= s_axi_wdata;
                reg_scale_detect_addr      <= address(11 downto 2);
                reg_scale_detect_we        <= '1';
            end if;  
            
            if address(17 downto 7) = "00000000001" then
                reg_scale_addr_data      <= s_axi_wdata(15 downto 0);
                reg_scale_addr_addr      <= address(6 downto 2);
                reg_scale_addr_we        <= '1';
            end if; 
            
            if address(17 downto 7) = "00000000010" then
                reg_scale_len_data      <= s_axi_wdata(15 downto 0);
                reg_scale_len_addr      <= address(6 downto 2);
                reg_scale_len_we        <= '1';
            end if; 
            
            if address(17 downto 7) = "00000000011" then
                reg_detect_len_data      <= s_axi_wdata(15 downto 0);
                reg_detect_len_addr      <= address(6 downto 2);
                reg_detect_len_we        <= '1';
            end if;            
            
       end if;
       
       if state = WRITE_RESP and s_axi_bready = '1' then
           if address(17) = '1' then
               reg_table_data<= next_data(8 downto 0);
               reg_table_addr<= address(16 downto 2)& '1';
               reg_table_we  <= '1';
           end if;
      end if;
    end if;
end process;

AXI_L_state_proc: process(state, s_axi_arvalid, s_axi_awvalid, s_axi_rready, s_axi_wvalid, s_axi_bready)
begin
    next_state <= state;
    
    case (state) is
        when IDLE =>
            -- READ
            if s_axi_arvalid = '1' then -- without address test					
                next_state <= READ_DATA;
          end if;
          -- WRITE - vyssi priorita
          if s_axi_awvalid = '1' then -- without address test									 
                next_state <= WRITE_DATA;
          end if;
          
        when READ_DATA   =>				  
            next_state <= READ_RESP;
            
        when READ_RESP =>								
            if s_axi_rready = '1' then
                next_state <= IDLE;
            end if;
                                    
        when WRITE_DATA =>					
            if s_axi_wvalid = '1' then						
                next_state <= WRITE_RESP;
            end if;
           
        when WRITE_RESP =>			
            if s_axi_bready = '1' then
                next_state <= IDLE;
            end if;
          
        when others =>
            next_state <= IDLE;
    end case; 
end process;

AXI_L_state: process(state, address, s_axi_arvalid, s_axi_awvalid, s_axi_wvalid, s_axi_wdata, s_axi_araddr, s_axi_awaddr,  s_axi_rready)
begin

    next_address  <= address;    
    s_axi_arready <= '0';
    s_axi_awready <= '0';
    s_axi_rvalid  <= '0';
    s_axi_bvalid  <= '0';
    s_axi_wready  <= '0';    
    s_axi_rdata   <= (others => '0');    
    s_axi_bresp   <= "00";
    s_axi_rresp   <= "00"; 
    
    case (state) is
        when IDLE =>
            -- READ
            if s_axi_arvalid = '1' then -- without address test
                 next_address <= s_axi_araddr(S_AXI_ADDR_WIDTH-1 downto 0);
                 s_axi_arready <= '1';
            end if;
          -- WRITE - vyssi priorita
            if s_axi_awvalid = '1' then -- without address test
                 next_address <= s_axi_awaddr(S_AXI_ADDR_WIDTH-1 downto 0);
                 s_axi_awready <= '1';	
            end if;
          
        when READ_DATA   =>  
            s_axi_arready <= '1';         
        when READ_RESP =>             
            s_axi_rdata <= (others => '0');            				
            s_axi_rvalid  <= '1';
                                    
        when WRITE_DATA =>
            s_axi_wready  <= '1';	
            s_axi_awready <= '1';	        
        when WRITE_RESP =>
            s_axi_bvalid <= '1';
          
        when others =>
    end case; 

end process;

end Behavioral;
