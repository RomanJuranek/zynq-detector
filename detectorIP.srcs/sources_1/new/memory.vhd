----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2015 09:48:12 AM
-- Design Name: 
-- Module Name: memory - Behavioral
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



library IEEE, STD;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;

use work.data_types.all;		-- my data types

entity memory is
    Generic(        
        MEM_TYPE            : integer   := 0;
        MAX_WIDTH           : integer   := 1024;
        MAX_HEIGTH          : integer   := 1024;
        DEBUG               : integer   := 0;
        SCALE_MODE          : integer   :=0         
    );
    Port ( 
        aclk : in STD_LOGIC;
        resetn : in STD_LOGIC;        
        
        scale_addr_data     : in std_logic_vector(15 downto 0);
        scale_addr_addr     : in std_logic_vector(4 downto 0);
        scale_addr_we       : in std_logic;
        
        scale_len_data      : in std_logic_vector(15 downto 0) := (others => '0');
        scale_len_addr      : in std_logic_vector(4 downto 0) := (others => '0');
        scale_len_we        : in std_logic := '0';
        
        scale_conf_data     : in std_logic_vector(31 downto 0);
        scale_conf_addr     : in std_logic_vector(9 downto 0);
        scale_conf_we       : in std_logic;
        
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
end memory;

architecture Behavioral of memory is
-------------------------------------------------------------------------------------------------
component memory4Kx32 is
    Port ( 
        aclk : in STD_LOGIC;
        resetn : in STD_LOGIC;
        
        input_line      : in std_logic_vector(127 downto 0);
        input_scale     : in array_5x32b;
        input_addr_x    : in std_logic_vector(12 downto 0);     -- po nasobku 16
        input_addr_y    : in std_logic_vector(12 downto 0);
        input_we_line   : in std_logic_vector(1 downto 0);
        
        addr0_x         : in std_logic_vector(12 downto 0);
        addr0_y         : in std_logic_vector(12 downto 0);   
        addr0_ready     : in std_logic;      
        data0           : out array_6x6x8b;
        
        addr1_x         : in std_logic_vector(12 downto 0);
        addr1_y         : in std_logic_vector(12 downto 0);  
        addr1_ready     : in std_logic;       
        data1           : out array_6x6x8b        
        
    );
end component;

component scale_np is
  Port ( 
        aclk            : in std_logic;
        resetn          : in std_logic;        
                
        scale_len_data  : in std_logic_vector(15 downto 0) := (others => '0');
        scale_len_addr  : in std_logic_vector(4 downto 0) := (others => '0');
        scale_len_we    : in std_logic := '0';
        
        scale_index     : in std_logic_vector(4 downto 0);
        scale_ena       : in std_logic;
        scale_end       : out std_logic;
                
        addr_x          : out std_logic_vector(12 downto 0);
        addr_y          : out std_logic_vector(12 downto 0);
        addr_scale      : out std_logic_vector(4 downto 0);
        addr_valid      : out std_logic;
        addr_we         : out std_logic;
        addr_ready      : in std_logic;
        
        data_in         : in array_6x6x8b;
        data_in_valid   : in std_logic;
        
        data_out        : out array_5x32b
  
  );
end component;

component scale_dp is
  Port ( 
        aclk            : in std_logic;
        resetn          : in std_logic;        
                
        scale_len_data  : in std_logic_vector(15 downto 0) := (others => '0');
        scale_len_addr  : in std_logic_vector(4 downto 0) := (others => '0');
        scale_len_we    : in std_logic := '0';
        
        scale_index     : in std_logic_vector(4 downto 0);
        scale_ena       : in std_logic;
        scale_end       : out std_logic;
                
        addr_x          : out std_logic_vector(12 downto 0);
        addr_y          : out std_logic_vector(12 downto 0);
        addr_scale      : out std_logic_vector(4 downto 0);
        addr_valid      : out std_logic;
        addr_we         : out std_logic;
        addr_ready      : in std_logic;
        
        data_in         : in array_6x6x8b;
        data_in_valid   : in std_logic;
        
        data_out        : out array_5x32b
  
  );
end component;

--COMPONENT scale_confg_ram
--  PORT (
--    clka : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--  );
--END COMPONENT;


type array_MAX_HEIGHTx32b is array (0 to MAX_HEIGTH-1) of std_logic_vector(31 downto 0);

impure function InitRomScaleFile (FileName : in string) return array_MAX_HEIGHTx32b is                            
    file RomFile : text;                                                        
    variable rdline : line;                                                                        
    variable rom : array_MAX_HEIGHTx32b := (others =>(others => '0'));                                                                    
begin      
    file_open(RomFile,"scale.mem",READ_MODE);                                                                                               
    for i in array_MAX_HEIGHTx32b'range loop                                                                        
        readline (RomFile, rdline);                                                                
        hread (rdline, rom(i));                                                                     
    end loop;                                                                                           
    return rom;                                                                                         
end function; 

signal scale_confg_ram  : array_MAX_HEIGHTx32b := InitRomScaleFile("scale.mem");


-------------------------------------------------------------------------------------------------


type t_state is (INIT, WAIT_LINE, WAIT_FRAME, LOAD_LINE, SCALE_TEST, SCALE, UPDATE, DETECT);
signal state    : t_state;

signal ready0   : std_logic;

signal scale_addr0  : array_16x16b := const_scale_addr;
signal scale_addr1  : array_16x16b := const_scale_addr;


signal scale_instr_addr : std_logic_vector(10 downto 0);
signal scale_instr_data : std_logic_vector(31 downto 0);
signal scale_conf       : std_logic_vector(31 downto 0);

signal input_lineA     : std_logic_vector(127 downto 0);
signal input_lineB     : std_logic_vector(127 downto 0);
signal input_addr_x    : std_logic_vector(12 downto 0);     -- po nasobku 16
signal input_addr_y    : std_logic_vector(12 downto 0);
signal input_we_line   : std_logic_vector(1 downto 0);
signal input_scale     : array_5x32b;

signal input_we_next   : std_logic_vector(1 downto 0);

signal mem_addr0_x     : std_logic_vector(12 downto 0);
signal mem_addr0_y     : std_logic_vector(12 downto 0);        
signal mem_data0       : array_6x6x8b;
signal mem_addr1_x     : std_logic_vector(12 downto 0);
signal mem_addr1_y     : std_logic_vector(12 downto 0);        
signal mem_data1       : array_6x6x8b; 

signal input_pos_y      : std_logic_vector(12 downto 0);
signal input_pos_x      : std_logic_vector(12 downto 0);
signal detect_pos_y     : std_logic_vector(12 downto 0) := (others => '0');
signal input_buff       : std_logic_vector(127 downto 0);
signal input_cnt        : std_logic_Vector(1 downto 0);

signal valid0_next      : std_logic_vector(5 downto 0);
signal valid1_next      : std_logic_vector(5 downto 0);
signal scale_valid_next : std_logic_vector(5 downto 0);

signal scaler_index     : std_logic_vector(4 downto 0);
signal scaler_ena       : std_logic;
signal scaler_end       : std_logic;
signal scale_addr_ready : std_logic;
signal scaler_addr_x    : std_logic_vector(12 downto 0);
signal scaler_addr_y    : std_logic_vector(12 downto 0);
signal scaler_addr_scale: std_logic_vector(4 downto 0);
signal scaler_addr_valid: std_logic;
signal scaler_addr_we   : std_logic;

signal scaler_data_in   : array_6x6x8b;
signal scaler_data_valid: std_logic;

signal scaler_data_out  : array_5x32b;
signal scaler_resetn    : std_logic;

begin

-------------------------------------------------------------------------
------------------- control -----------------------------------------
control_sync: process(aclk)
begin
    if aclk'event and aclk= '1' then
        
        if resetn = '0' then
            scaler_resetn <= '0';
            state <= INIT;
            input_buff <= (others => '0');
        else
            input_we_next(0) <= input_we_line(0);
            input_we_next(1) <= input_we_next(0);
            scaler_resetn <= '1';
            input_we_line <= "00";
            input_lineA <= (others => '0');
            input_lineB <= (others => '0');
            input_addr_x <= (others => '0');
            input_addr_y <= (others => '0');
            input_line <= input_pos_y;
            scale_instr_addr <= input_pos_y(10 downto 0);            
            
            case state is
                when INIT =>                
                    if s_axis_tuser = '1' and s_axis_tvalid = '1' then
                        state <= LOAD_LINE; 
                    end if;
                    
                    input_pos_y <= (others => '0');
                    input_pos_x <= (others => '0');
                    input_cnt  <= "01";
                    input_buff <= s_axis_tdata & input_buff(127 downto 32);  
                when WAIT_LINE =>                
                    if s_axis_tvalid = '1' then                        
                        state <= LOAD_LINE;                      
                        if s_axis_tuser = '1' then                            
                            state <= WAIT_FRAME;
                        end if;
                    end if;
                    input_pos_x <= (others => '0');
                    input_cnt  <= "01";   
                    input_buff <= s_axis_tdata & input_buff(127 downto 32);        
                when WAIT_FRAME =>
                    if new_image = '1' then                        
                        state <= LOAD_LINE; 
                        input_pos_y <= (others => '0');
                        scaler_resetn <= '0';
                    end if;                    
                when LOAD_LINE =>
                    if s_axis_tvalid = '1' then
                        if s_axis_tlast = '1'and not(input_cnt = "11" and addr0_valid = '1') then
                            state <= SCALE_TEST; 
                        end if;
                        
                        if input_cnt = "11" then
                            if addr0_valid = '0' then 
                                input_we_line <= "01";
                                input_lineA <= s_axis_tdata & input_buff(127 downto 32);
                                input_addr_x <= input_pos_x;
                                input_addr_y <= input_pos_y;
                                input_pos_x <= input_pos_x + "10000";
                                input_cnt <= "00";
                            end if;
                        else
                            input_cnt <= input_cnt + '1'; 
                            input_buff <= s_axis_tdata & input_buff(127 downto 32);
                        end if;   
                          
                        
                        
                    end if;
                    scale_conf <= scale_instr_data;
                    scaler_index <= (others => '0');
                                    
                when SCALE_TEST =>
                    if scale_conf(0) = '1' then
                        state <= SCALE;   
                    else
                        state <= UPDATE;  
                    end if;
                    scale_conf(30 downto 0) <= scale_conf(31 downto 1);                    
                when SCALE =>                   
                    if scaler_end = '1' then                    
                        state <= SCALE_TEST;
                        scaler_index <= scaler_index + '1';
                    end if; 
                    if scaler_addr_we = '1' then
                        input_scale <= scaler_data_out;
                        input_we_line <= "11";
                        input_addr_x <= scaler_addr_x + scale_addr0(conv_integer(scaler_index + '1'))(12 downto 0);
                        input_addr_y <= scaler_addr_y;  
                    end if;
                when UPDATE =>    
                    input_pos_y <= input_pos_y + '1'; 
                    state <= DETECT;
                when DETECT =>
                    if (detect_pos_y + 31) >= input_pos_y then
                        state <= WAIT_LINE;
                    end if; 
            end case;
        end if;
    end if;
end process;

control: process(state, resetn, input_cnt, addr0_valid)
begin

    s_axis_tready <= '0';
    new_image_ready <= '0';
    scaler_ena <= '0';
    work_request <= '0';
    scale_addr_ready <= not addr0_valid;
    
    case state is
        when INIT =>
            s_axis_tready <= resetn;            
        when WAIT_LINE =>
            s_axis_tready <= '1';
        when WAIT_FRAME =>
            new_image_ready <= '1';
        when LOAD_LINE =>
              
            work_request <= '1';
            if input_cnt = "11" and addr0_valid = '1' then    
                s_axis_tready <= '0';
            else
                s_axis_tready <= '1';
            end if;  
        when SCALE_TEST =>
        when SCALE =>
             scaler_ena <= '1';
             work_request <= '1';
        when UPDATE =>
        when DETECT =>
    end case;
end process;

detect_pos_y_proc: process(aclk)
begin
    if aclk'event and aclk = '1' then        
        if new_image = '1' or resetn = '0' then
            detect_pos_y <= (others => '0');
        elsif next_line = '1' then
            if detect_pos_y < input_pos_y then
                detect_pos_y <= detect_pos_y + '1';
            end if;
        end if;
    end if;
end process;

ready_proc: process (aclk, detect_pos_y, window_height, input_pos_y)
begin
    if aclk'event and aclk = '1' then 
        detect_ena <= '0';
        if (detect_pos_y + window_height) <= input_pos_y then
            detect_ena <= '1';
        end if;
    end if;
end process;

ready0 <= '1';
addr0_ready <= '1';
addr1_ready <= '1';

valid_proc: process (aclk)
begin
    if aclk'event and aclk = '1' then        
        valid0_next(0) <= addr0_valid;
        valid0_next(1) <= valid0_next(0);
        valid0_next(2) <= valid0_next(1);
        valid0_next(3) <= valid0_next(2);
        valid0_next(4) <= valid0_next(3);
        data0_valid <= valid0_next(4);    
    
        valid1_next(0) <= addr1_valid;
        valid1_next(1) <= valid1_next(0);
        valid1_next(2) <= valid1_next(1);
        valid1_next(3) <= valid1_next(2);
        valid1_next(4) <= valid1_next(3);
        data1_valid <= valid1_next(4);
        
        scale_valid_next(0) <= scaler_addr_valid and not scaler_addr_we;
        scale_valid_next(1) <= scale_valid_next(0);
        scale_valid_next(2) <= scale_valid_next(1);
        scale_valid_next(3) <= scale_valid_next(2);
        scale_valid_next(4) <= scale_valid_next(3);
        scaler_data_valid   <= scale_valid_next(4);
        
    end if;
end process;

--out_proc: process (mem_data0, mem_data1)
--begin
--    for y in 0 to 5 loop
--        for x in 0 to 5 loop
    scaler_data_in <= mem_data0;
    data0 <= mem_data0;
    data1 <= mem_data1;
--        end loop;
--    end loop;

--end process;
-------------------------------------------------------------------------
--------------- addr ----------------------------------------------------
addr_sync: process(aclk)

begin
    if aclk'event and aclk = '1' then  
        if scaler_addr_valid = '1' then
            mem_addr0_x <= scaler_addr_x + scale_addr0(conv_integer(scaler_addr_scale))(12 downto 0);
            mem_addr0_y <= scaler_addr_y;
        else              
            mem_addr0_x <= addr0_x + scale_addr0(conv_integer(addr0_scale))(12 downto 0);
            mem_addr0_y <= addr0_y; 
         end if;
                  
        mem_addr1_x <= addr1_x + scale_addr1(conv_integer(addr1_scale))(12 downto 0); 
        mem_addr1_y <= addr1_y;        
    end if;
end process;

--------------------------------------------------------------------------
--------------- config ----------------------------

scale_addr: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if scale_addr_we = '1' then
            scale_addr0(conv_integer(scale_addr_addr)) <= scale_addr_data;
            scale_addr1(conv_integer(scale_addr_addr)) <= scale_addr_data;
        end if;
    end if;
end process;

scale_config_bram_write: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if scale_conf_we = '1' then
            scale_confg_ram(conv_integer(scale_conf_addr)) <= scale_conf_data;               
        end if;
    end if;
end process;

scale_config_bram_read: process(aclk)
begin
    if aclk'event and aclk = '1' then
        scale_instr_data <= scale_confg_ram(conv_integer(scale_instr_addr));
    end if;
end process;


--scale_confg_ram_map: scale_confg_ram
--  PORT MAP (
--    clka => aclk,
--    wea(0) => scale_conf_we,
--    addra(10) => '0',
--    addra(9 downto 0) => scale_conf_addr,
--    dina => scale_conf_data,
--    clkb => aclk,
--    addrb => scale_instr_addr(10 downto 0),
--    doutb => scale_instr_data
--  );



memory4Kx32_map: memory4Kx32   Port map( 
        aclk    => aclk,
        resetn  => resetn,
        
        input_line     => input_lineA,
        input_scale     => input_scale,
        input_addr_x    => input_addr_x,
        input_addr_y    => input_addr_y,
        input_we_line   => input_we_line,
        
        addr0_x         => mem_addr0_x,
        addr0_y         => mem_addr0_y,  
        addr0_ready     => ready0,
        data0           => mem_data0,
        
        addr1_x         => mem_addr1_x,
        addr1_y         => mem_addr1_y, 
        addr1_ready     => data1_ready,
        data1           => mem_data1        
    );
    
scale_gen0: if SCALE_MODE = 0 generate    
    scale_np_map: scale_np
          Port map( 
                aclk            => aclk,
                resetn          => scaler_resetn,            
                        
                scale_len_data  => scale_len_data,
                scale_len_addr  => scale_len_addr,
                scale_len_we    => scale_len_we,
                
                scale_index     => scaler_index,
                scale_ena       => scaler_ena,
                scale_end       => scaler_end,
                        
                addr_x          => scaler_addr_x,
                addr_y          => scaler_addr_y,
                addr_scale      => scaler_addr_scale,
                addr_valid      => scaler_addr_valid,
                addr_we         => scaler_addr_we,
                addr_ready      => scale_addr_ready,
                
                data_in         => scaler_data_in,
                data_in_valid   => scaler_data_valid,
                
                data_out        => scaler_data_out
          
          );
end generate;

scale_gen1: if SCALE_MODE = 1 generate    
    scale_dp_map: scale_dp
          Port map( 
                aclk            => aclk,
                resetn          => scaler_resetn,            
                        
                scale_len_data  => scale_len_data,
                scale_len_addr  => scale_len_addr,
                scale_len_we    => scale_len_we,
                
                scale_index     => scaler_index,
                scale_ena       => scaler_ena,
                scale_end       => scaler_end,
                        
                addr_x          => scaler_addr_x,
                addr_y          => scaler_addr_y,
                addr_scale      => scaler_addr_scale,
                addr_valid      => scaler_addr_valid,
                addr_we         => scaler_addr_we,
                addr_ready      => scale_addr_ready,
                
                data_in         => scaler_data_in,
                data_in_valid   => scaler_data_valid,
                
                data_out        => scaler_data_out
          
          );
end generate;  

end Behavioral;
