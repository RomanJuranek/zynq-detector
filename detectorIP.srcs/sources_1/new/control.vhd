----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2015 05:28:25 PM
-- Design Name: 
-- Module Name: control - Behavioral
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


entity control is
    Generic(        
        MAX_HEIGTH          : integer   := 1024;
        DEBUG               : integer   := 0;        
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
        in0_ready   : out std_logic := '0';
        in0_find    : in std_logic;
        in0         : in Tcontrol;
                
        out0_valid  : out std_logic := '0';
        out0_ready  : in std_logic;
        out0        : out Tcontrol; 
        
        in1_valid   : in std_logic;
        in1_ready   : out std_logic := '0';
        in1_find    : in std_logic;
        in1         : in Tcontrol;
        
        out1_valid  : out std_logic := '0';
        out1_ready  : in std_logic;
        out1        : out Tcontrol;
        
        m_axis_tdata    : out std_logic_vector(63 downto 0);
        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in std_logic;
        m_axis_tlast    : out std_logic   
    
    );
end control;

architecture Behavioral of control is

COMPONENT fifo_pos_detect
  PORT (
    clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT fifo_res_detect
  PORT (
    clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

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
---------------------------------------------------------------------------------------------------------
signal next_run     : std_logic := '0';
signal inner_resetn : std_logic := '0';

type array_32x13b is array (31 downto 0) of std_logic_vector(12 downto 0);
type array_HEIGHTx32b is array (0 to MAX_HEIGTH-1) of std_logic_vector(31 downto 0);

impure function InitScaleFile (RomFileName : in string) return array_HEIGHTx32b is                            
    file RomFile : text;                                                             
    variable rdline : line;                                                                        
    variable rom : array_HEIGHTx32b := (others => (others => '0'));                                                                            
                                                                                                        
begin    
    file_open(RomFile,RomFileName,READ_MODE);  
                                                                                               
    for i in array_HEIGHTx32b'range loop                                                                        
        readline (RomFile, rdline);                                                                
        hread (rdline, rom(i));                                                                     
    end loop;                                                                                           
    return rom;                                                                                         
end function;  
-------------------------------------------------------------------------------------------------

type Tpos_state is (INIT, LOAD, GEN_LINE, LINE_END, SCALE_TEST, SCALE_WAIT, SCALE_LOAD, IMAGE_WAIT);

signal pos_state    : Tpos_state := INIT;

signal detect_len_ram : array_16x16b:= const_detect_width;
signal pos_y_ram      : array_32x13b:= (others => (others => '0'));

signal pos_x            : std_logic_vector(12 downto 0) := (others => '0');
signal pos_y            : std_logic_vector(12 downto 0) := (others => '0');
signal line_y           : std_logic_vector(12 downto 0) := (others => '0');
signal pos_s            : std_logic_vector(4 downto 0) := (others => '0');
signal line_len         : std_logic_vector(12 downto 0) := (others => '0');
signal scale_index      : std_logic_vector(4 downto 0) := (others => '0');
signal scale_instr_data : std_logic_vector(31 downto 0) := (others => '0');
signal scale_conf       : std_logic_vector(31 downto 0) := (others => '0');

signal scale_confg_ram  : array_HEIGHTx32b := InitScaleFile("detect.mem");

signal test1_x       : std_logic_vector(12 downto 0) := (others => '0');
signal test1_y       : std_logic_vector(12 downto 0) := (others => '0');
signal test1_s       : std_logic_vector(4 downto 0) := (others => '0');

signal result0_fifo_in  : std_logic_vector(63 downto 0);
signal result0_fifo_we  : std_logic;
signal result0_fifo_out : std_logic_vector(63 downto 0);
signal result0_fifo_rd  : std_logic;
signal result0_fifo_em  : std_logic;

signal result1_fifo_in  : std_logic_vector(63 downto 0);
signal result1_fifo_we  : std_logic;
signal result1_fifo_out : std_logic_vector(63 downto 0);
signal result1_fifo_rd  : std_logic;
signal result1_fifo_em  : std_logic;
signal resuld_end       : std_logic :='0';
signal frame_cnt        : std_logic_vector(55 downto 0);

signal act_detect_y     : std_logic_vector(12 downto 0);
signal act_det_valid    : std_logic;
signal pipe_cnt         : std_logic_vector(3 downto 0);
signal pipe_valid       : std_logic;
signal pipe_idle        : std_logic;

signal pos0_fifo_out    : std_logic_vector(35 downto 0);
signal pos0_fifo_empty  : std_logic;
signal pos0_fifo_full   : std_logic;
signal pos0_fifo_in     : std_logic_vector(35 downto 0);
signal pos0_fifo_we     : std_logic;
signal pos0_fifo_rd     : std_logic;

signal pos1_fifo_out    : std_logic_vector(35 downto 0);
signal pos1_fifo_empty  : std_logic;
signal pos1_fifo_full   : std_logic;
signal pos1_fifo_in     : std_logic_vector(35 downto 0);
signal pos1_fifo_we     : std_logic;
signal pos1_fifo_rd     : std_logic;

signal valid_switcher   : std_logic_vector(1 downto 0) := "00";

signal debug_out        : Tcontrol;
signal debug_valid      : std_logic;

signal detect_ena_inner : std_logic;

begin

subsystem_resetn <= inner_resetn;


reset_proc: process (aclk)
begin
    if aclk'event and aclk = '1' then
        next_run <= run;        
        if (run = '1' and next_run = '0') or resetn = '0' then
            inner_resetn <= '0';
        else
            inner_resetn <= run;
        end if;
    end if;
end process;


detect_pos_proc: process (aclk)
begin
    if aclk'event and aclk = '1' then
        if inner_resetn = '0' then
            act_detect_y <= (others => '0');
            pipe_cnt <= X"0";
            pipe_idle <= '1';
        else
            if pos_state = INIT then
                act_detect_y <= (others => '0');
                pipe_cnt <= X"0";
                pipe_idle <= '1';
            else
            
                next_line <= '0';
                if pos_state = IMAGE_WAIT then
                    next_line <= '1';
                end if;
                --if detect_ena = '1' then
                    if pipe_cnt = X"F" then
                        pipe_cnt <= X"0";
                        pipe_valid <= '0';
                        pipe_idle <= not pipe_valid;
                        act_det_valid <= '0';
                        if pipe_valid = '1' and pipe_idle = '0' and act_det_valid = '0' then
                            act_detect_y <= act_detect_y + '1';
                            next_line <= '1';
                        end if;
                        if act_detect_y < line_y and pipe_idle = '1' then
                            act_detect_y <= act_detect_y + '1';
                            next_line <= '1';
                        end if;
                    else
                        pipe_cnt <= pipe_cnt + '1';
                        
                        if (in0_valid = '1')  then
                            pipe_valid <= '1';
                            if in0.pos =  act_detect_y(4 downto 0) then
                                act_det_valid <= '1';
                            end if;
                        end if;
                        
                        if (in1_valid = '1')  then
                            pipe_valid <= '1';
                            if in1.pos =  act_detect_y(4 downto 0) then
                                act_det_valid <= '1';
                            end if;
                        end if;
                    end if;
               -- else
                
                
               -- end if;
            end if;
        end if;
    end if;
end process;

--------------------------------------------------------
pos_generater_sync: process (aclk)
begin
    if aclk'event and aclk = '1' then
        if inner_resetn = '0' then
            pos_state <= INIT;
            frame_cnt <= (others => '0');
        else
            new_image <= '0';  
            resuld_end <= '0';
            case pos_state is
                when INIT =>   
                    if  input_line = 0 then
                        pos_state <= LOAD;
                    end if;
                    pos_x <= (others => '0');
                    pos_y <= (others => '0');
                    line_y <= (others => '0');
                    pos_s <= (others => '0');
                    pos_y_ram <= (others => (others => '0'));                  
                when LOAD => 
                    if (input_line - line_y) > window_height then
                        pos_state <= GEN_LINE;
                        pos_y <= pos_y_ram(0);
                        scale_conf <= scale_instr_data;
                    end if;
                    if (line_y + window_height) >= (image_height) then
                        pos_state <= IMAGE_WAIT;
                    end if;
                when GEN_LINE =>                    
                    if pos_x >= line_len then
                        pos_state <= SCALE_TEST;
                    end if;
                    if pos_x = (line_len-1) then
                        pos_state <= LINE_END;                     
                    end if;
                    
                    if pos0_fifo_full='0' and pos1_fifo_full = '0' then
                        pos_x <= pos_x + DETECT_STEP_X+DETECT_STEP_X;
                    end if;
                    if pos0_fifo_full='0' and pos1_fifo_full = '1' then
                        pos_x <= pos_x + DETECT_STEP_X;
                    end if;
                    if pos0_fifo_full='1' and pos1_fifo_full = '0' then
                        pos_x <= pos_x + DETECT_STEP_X;
                    end if;                                        

                when LINE_END =>
                     if pos0_fifo_full='0' or pos1_fifo_full = '0' then
                        pos_state <= SCALE_TEST;   
                     end if;
                     
                when SCALE_TEST =>
                    pos_y_ram(conv_integer(pos_s)) <= pos_y + DETECT_STEP_Y;
                    if scale_conf(1) = '1' then
                        pos_state <= SCALE_WAIT;                        
                        pos_s <= pos_s + '1';
                        pos_y <= pos_y_ram(conv_integer(pos_s) + DETECT_STEP_Y);                           
                    else
                        pos_state <= SCALE_LOAD;
                        line_y <= line_y + DETECT_STEP_Y;
                        pos_s <= (others => '0');    
                    end if;
                    pos_x <= (others => '0'); 
                    scale_conf(30 downto 0) <= scale_conf(31 downto 1);   
                 when SCALE_LOAD =>
                    pos_state <= LOAD;
                 when SCALE_WAIT =>
                    
                    pos_state <= GEN_LINE;  
                when IMAGE_WAIT =>
                    --if (pipe_idle = '1' or detect_ena = '0') and new_image_ready = '1' and m_axis_tready = '1' then                        
                    if (pipe_idle = '1') and new_image_ready = '1' and m_axis_tready = '1' then                        
                        pos_state <= INIT;
                        new_image <= '1';
                        resuld_end <= '1';
                        frame_cnt <= frame_cnt + '1';  
                    end if;
            end case;
        end if;
    end if;
end process;

pos_generater_proc: process (pos_state, pos0_fifo_full, pos1_fifo_full, pos_s, pos_y, pos_x, line_y, detect_ena)
begin 
        pos0_fifo_we <= '0';
        pos1_fifo_we <= '0';
        pos0_fifo_in <= (others => '0');
        pos1_fifo_in <= (others => '0');
        
        detect_ena_inner <= detect_ena;
        
        if pos_state = GEN_LINE then  
            if pos0_fifo_full='0' and pos1_fifo_full = '0' then
                pos0_fifo_in(35 downto 13) <= line_y(4 downto 0) & pos_s&pos_y;
                pos0_fifo_in(12 downto 0)  <= pos_x;
                pos1_fifo_in(35 downto 13) <= line_y(4 downto 0) &pos_s&pos_y;
                pos1_fifo_in(12 downto 0)  <= pos_x + DETECT_STEP_X;
                pos0_fifo_we <= '1';
                pos1_fifo_we <= '1';
            end if;
            if pos0_fifo_full='0' and pos1_fifo_full = '1' then
                pos0_fifo_in(35 downto 0) <= line_y(4 downto 0) & pos_s&pos_y&pos_x;
                pos0_fifo_we <= '1';
            end if;
            if pos0_fifo_full='1' and pos1_fifo_full = '0' then
                pos1_fifo_in(35 downto 0) <= line_y(4 downto 0) & pos_s&pos_y&pos_x;
                pos1_fifo_we <= '1';
            end if;                                        
        end if;
        if pos_state = LINE_END then           
             if pos0_fifo_full='0' then
                pos0_fifo_in(35 downto 0) <= line_y(4 downto 0) & pos_s&pos_y&pos_x;
                pos0_fifo_we <= '1';                    
             elsif pos1_fifo_full = '0' then
                pos1_fifo_in(35 downto 0) <= line_y(4 downto 0) & pos_s&pos_y&pos_x;
                pos1_fifo_we <= '1';
             end if;
        end if;
        if pos_state = IMAGE_WAIT then
            detect_ena_inner <= '1';
        end if;
        
end process;


pos0_fifo: fifo_pos_detect
    Port map( 
        clk => aclk,
        din => pos0_fifo_in,
        wr_en => pos0_fifo_we,
        rd_en => pos0_fifo_rd,
        dout => pos0_fifo_out,
        full => pos0_fifo_full,
        empty => pos0_fifo_empty
    );
    
pos1_fifo: fifo_pos_detect
    Port map( 
        clk => aclk,
        din => pos1_fifo_in,
        wr_en => pos1_fifo_we,
        rd_en => pos1_fifo_rd,
        dout => pos1_fifo_out,
        full => pos1_fifo_full,
        empty => pos1_fifo_empty
    );

-----------------------------------------------------------
--pos0_fifo_rd <= '0' when (in0_valid = '1' and in0_find = '1' and in0.index < feature_count) or pos0_fifo_empty = '1' or detect_ena = '0' else '1';
pos1_fifo_rd <= '0' when (in1_valid = '1' and in1_find = '1' and in1.index < feature_count) or pos1_fifo_empty = '1' or detect_ena_inner = '0' else '1';

test_proc0: process (in0_valid, in0_find, in0.index, feature_count, pos0_fifo_empty, detect_ena_inner, work_request, valid_switcher)
begin
    pos0_fifo_rd <= '0';
    
    if detect_ena_inner = '1' and pos0_fifo_empty = '0' then
        if in0_valid = '1' then
            if in0_find = '1' then
                if in0.index < feature_count then
                    pos0_fifo_rd <= '0';
                else
                    pos0_fifo_rd <= '1';
                end if;
            else
                if work_request = '0' or not(valid_switcher = "11") then
                    pos0_fifo_rd <= '1';
                end if;                
            end if;
        else                        
            pos0_fifo_rd <= '1';            
        end if;
    end if;
end process;

test_sync_proc0: process (aclk)
begin
    if aclk'event and aclk = '1' then  
        result0_fifo_in <= (others => '0');
        result0_fifo_we <= '0';     
         
         
            
        if in0_valid = '1' and in0_find = '1' and in0.index < feature_count then   
            out0_valid <= '1';     
            out0.x <= in0.x;
            out0.y <= in0.y;
            out0.scale <= in0.scale;
            out0.index <= in0.index + '1';
            out0.pos   <= in0.pos;
            out0.suma <= in0.suma;
            
            debug_valid <= '1';     
            debug_out.x <= in0.x;
            debug_out.y <= in0.y;
            debug_out.scale <= in0.scale;
            debug_out.index <= in0.index + '1';
            debug_out.pos   <= in0.pos;
            debug_out.suma <= in0.suma;
            
        else
            if in0_valid = '1' and in0_find = '1' and in0.index = feature_count and in0.suma >= final_threshold then
                result0_fifo_in(31 downto 0) <= in0.scale&"0"&in0.y&in0.x;
                result0_fifo_in(63 downto 32)<= instance&"000000"&in0.suma;
                result0_fifo_we <= '1';
            end if;
        
            if detect_ena_inner = '1' then
                valid_switcher <= valid_switcher+'1';
                if in0_valid = '1' and in0_find = '0' and work_request = '1' and valid_switcher="11" then
                    out0_valid <= '0';
                    debug_valid <= '0';
                else                    
                    out0.x <= pos0_fifo_out(12 downto 0);      
                    out0.y <= pos0_fifo_out(25 downto 13);      
                    out0.scale <= pos0_fifo_out(30 downto 26);                
                    out0.pos   <= pos0_fifo_out(35 downto 31); 
                    out0_valid <= not pos0_fifo_empty;
                    
                    out0.index <= "0000000000";
                    out0.suma <= sum_null; 
                    
                    
                    debug_out.x <= pos0_fifo_out(12 downto 0);      
                    debug_out.y <= pos0_fifo_out(25 downto 13);      
                    debug_out.scale <= pos0_fifo_out(30 downto 26);                
                    debug_out.pos   <= pos0_fifo_out(35 downto 31); 
                    debug_valid <= not pos0_fifo_empty;
                    
                    debug_out.index <= "0000000000";
                    debug_out.suma <= sum_null; 
                end if;                
            else
                out0_valid <= '0';
                debug_valid <= '0';
            end if;
        end if;
    end if;
end process;


test_sync_proc1: process (aclk)
begin
    if aclk'event and aclk = '1' then   
        result1_fifo_in <= (others => '0');
        result1_fifo_we <= '0'; 
            
         
            
        if in1_valid = '1' and in1_find = '1' and in1.index < feature_count then
            out1_valid <= '1';
            out1.x <= in1.x;
            out1.y <= in1.y;
            out1.scale <= in1.scale;
            out1.index <= in1.index + '1';
            out1.pos   <= in1.pos;
            out1.suma <= in1.suma;
        else
            if in1_valid = '1' and in1_find = '1' and in1.index = feature_count and in1.suma >= final_threshold then
                result1_fifo_in(31 downto 0) <= in1.scale&"0"&in1.y&in1.x;
                result1_fifo_in(63 downto 32)<= instance&"000000"&in1.suma;
                result1_fifo_we <= '1';                
            end if;
            if detect_ena_inner = '1' then            
                out1.x <= pos1_fifo_out(12 downto 0); 
                out1.y <= pos1_fifo_out(25 downto 13);      
                out1.scale <= pos1_fifo_out(30 downto 26);   
                out1.pos   <= pos1_fifo_out(35 downto 31); 
                out1_valid <= not pos1_fifo_empty;
                
                out1.index <= "0000000000";
                out1.suma <= sum_null; 
            else
                out1_valid <= '0';                   
            end if;
        end if;
    end if;
end process;

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
out_proc: process (m_axis_tready,result0_fifo_em,result0_fifo_out,result1_fifo_em,result1_fifo_out, resuld_end, frame_cnt, instance)
begin
    m_axis_tdata    <= (others => '0');
    m_axis_tvalid   <= '0';    
    m_axis_tlast    <= '0';
    
    result0_fifo_rd <= '0';
    result1_fifo_rd <= '0';
    
    if m_axis_tready = '1' then
        if result0_fifo_em = '0' then        
            m_axis_tdata <= result0_fifo_out;
            m_axis_tvalid <= '1';
            result0_fifo_rd <= '1';
        elsif result1_fifo_em = '0' then
            m_axis_tdata <= result1_fifo_out;
            m_axis_tvalid <= '1';
            result1_fifo_rd <= '1';
        elsif resuld_end = '1' then
            m_axis_tdata  <= instance&frame_cnt;                            
            m_axis_tvalid <= '1';
            m_axis_tlast <= '1';
        end if;
    end if;
end process;

res0_fifo: fifo_res_detect
    Port map( 
        clk => aclk,
        din => result0_fifo_in,
        wr_en => result0_fifo_we,
        rd_en => result0_fifo_rd,
        dout => result0_fifo_out,
        full => open,
        empty => result0_fifo_em
    );

res1_fifo: fifo_res_detect
    Port map( 
        clk => aclk,
        din => result1_fifo_in,
        wr_en => result1_fifo_we,
        rd_en => result1_fifo_rd,
        dout => result1_fifo_out,
        full => open,
        empty => result1_fifo_em
    );
----------------------------------------------------------------------------------------------
detect_len_bram_write: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if detect_len_we = '1' then
            detect_len_ram(conv_integer(detect_len_addr)) <= detect_len_data(15 downto 0);               
        end if;
    end if;
end process;

detect_len_bram_read: process(aclk)
begin
    if aclk'event and aclk = '1' then
        line_len <= detect_len_ram(conv_integer(pos_s))(12 downto 0);
    end if;
end process;


--scale_confg_ram_map: scale_confg_ram
--  PORT MAP (
--    clka => aclk,
--    wea(0) => scale_detect_we,
--    addra(10) => '0',
--    addra(9 downto 0) => scale_detect_addr,
--    dina => scale_detect_data,
--    clkb => aclk,
--    addrb => line_y(10 downto 0),
--    doutb => scale_instr_data
--  );
  
  

scale_config_bram_write: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if scale_detect_we = '1' then
            scale_confg_ram(conv_integer(scale_detect_addr)) <= scale_detect_data;               
        end if;
    end if;
end process;

scale_config_bram_read: process(aclk)
begin
    if aclk'event and aclk = '1' then
        scale_instr_data <= scale_confg_ram(conv_integer(line_y));
    end if;
end process;



end Behavioral;
