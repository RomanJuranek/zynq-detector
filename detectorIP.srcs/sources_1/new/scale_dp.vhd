----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2015 02:41:44 PM
-- Design Name: 
-- Module Name: scale_dp - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


use work.data_types.all;		-- my data types

entity scale_dp is
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
end scale_dp;

architecture Behavioral of scale_dp is

type array_32x13b is array (31 downto 0) of std_logic_vector(12 downto 0);
type array_32x16b is array (31 downto 0) of std_logic_vector(15 downto 0);
type array_4x8b is array (3 downto 0) of std_logic_vector(7 downto 0);
type array_5x4x8b is array (4 downto 0) of array_4x8b;

type array_5x8b is array (4 downto 0) of std_logic_vector(7 downto 0);
type array_5x5x8b is array (4 downto 0) of array_5x8b;

type array_5x13b is array (4 downto 0) of std_logic_vector(12 downto 0);
type array_5x5x13b is array (4 downto 0) of array_5x13b;

type t_write_state is (INIT, START, READ, WRITE, ONLY_WRITE, SCALE0, SCALE1, SCALE2, SCALE3, SCALE4, END_SCALE);
signal write_state      : t_write_state := INIT;
signal state_mem        : t_write_state := INIT;


signal source_line_ram  : array_32x13b := (others => (others => '0'));
signal dest_line_ram    : array_32x13b := (others => (others => '0'));
signal scale_len_ram    : array_16x16b := const_scale_len;

signal act_scale_len    : std_logic_vector(15 downto 0);
signal scale_pos_src    : std_logic_vector(12 downto 0);
signal scale_pos_dst    : std_logic_vector(12 downto 0);
signal scale_line_src   : std_logic_vector(12 downto 0);
signal scale_line_dst   : std_logic_vector(12 downto 0);

signal scale_read_ena   : std_logic:= '0';
signal scale_block      : array_5x5x8b;
signal scale_block_valid: std_logic := '0';
signal scale_mem        : array_5x4x8b;
signal init_cnt         : std_logic_vector(4 downto 0);

signal temp         : array_5x5x13b;
signal temp_valid   : std_logic;

begin

sync_write_proc: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if resetn = '0' then
            write_state <= INIT;
            state_mem <= INIT;
            init_cnt <= (others => '0');
        else
            case write_state is
                when INIT =>
                    if init_cnt = "11111" then
                        write_state <= START;
                    end if;
                    init_cnt <= init_cnt + '1';
                    source_line_ram(conv_integer(init_cnt)) <= (others => '0');
                    dest_line_ram(conv_integer(init_cnt))   <= (others => '0');
                when START =>
                    if scale_ena = '1' then
                        write_state <= READ;
                        state_mem <= SCALE0;
                    end if;
                    scale_pos_src <= (others => '0');
                    scale_pos_dst <= (others => '0');
                    scale_line_src <= source_line_ram(conv_integer(scale_index));
                    scale_line_dst <= dest_line_ram(conv_integer(scale_index));
                when READ =>
                    if scale_pos_src >= act_scale_len then
                        write_state <= END_SCALE;
                    elsif addr_ready = '1' then
                        write_state <= state_mem;
                        scale_pos_src <= scale_pos_src + "110";
                    end if;
                when WRITE => 
                    if addr_ready = '1' then
                        write_state <= READ;
                        scale_pos_dst <= scale_pos_dst + "100";
                    end if;
                    
                when ONLY_WRITE => 
                    if addr_ready = '1' then
                        write_state <= state_mem;
                        scale_pos_dst <= scale_pos_dst + "100";
                    end if;
                when SCALE0 =>
                    if scale_block_valid = '1' then
                        write_state <= WRITE;
                        state_mem <= SCALE1;
                    
                        for i in 0 to 4 loop
                            data_out(i) <= scale_block(i)(3) & scale_block(i)(2) & scale_block(i)(1) & scale_block(i)(0);
                            scale_mem(i)(0) <= scale_block(i)(4);
                        end loop;
                    end if;
                when SCALE1 =>
                    if scale_block_valid = '1' then
                        write_state <= WRITE;
                        state_mem <= SCALE2;
                        
                        for i in 0 to 4 loop
                            data_out(i) <= scale_block(i)(2) & scale_block(i)(1) & scale_block(i)(0) & scale_mem(i)(0);
                            scale_mem(i)(0) <= scale_block(i)(3);
                            scale_mem(i)(1) <= scale_block(i)(4);
                        end loop; 
                    end if;
                when SCALE2 =>
                    if scale_block_valid = '1' then
                        write_state <= WRITE;
                        state_mem <= SCALE3;
                        
                        for i in 0 to 4 loop
                            data_out(i) <= scale_block(i)(1) & scale_block(i)(0) & scale_mem(i)(1) & scale_mem(i)(0);
                            scale_mem(i)(0) <= scale_block(i)(2);
                            scale_mem(i)(1) <= scale_block(i)(3);
                            scale_mem(i)(2) <= scale_block(i)(4);
                        end loop; 
                    end if;
                when SCALE3 =>
                    if scale_block_valid = '1' then
                        write_state <= ONLY_WRITE;
                        state_mem <= SCALE4;
                    
                        for i in 0 to 4 loop
                            data_out(i) <= scale_block(i)(0) & scale_mem(i)(2) & scale_mem(i)(1) & scale_mem(i)(0);
                            scale_mem(i)(0) <= scale_block(i)(1);
                            scale_mem(i)(1) <= scale_block(i)(2);
                            scale_mem(i)(2) <= scale_block(i)(3);
                            scale_mem(i)(3) <= scale_block(i)(4);
                        end loop;
                    end if;
                when SCALE4 =>                
                    write_state <= WRITE;
                    state_mem <= SCALE0;
                    for i in 0 to 4 loop
                        data_out(i) <= scale_mem(i)(3) & scale_mem(i)(2) & scale_mem(i)(1) & scale_mem(i)(0);
                    end loop;
                when END_SCALE =>
                    write_state <= START;
                    source_line_ram(conv_integer(scale_index)) <= scale_line_src + "110";
                    dest_line_ram(conv_integer(scale_index)) <= scale_line_dst + "101";
            end case;
        end if;
    end if;
end process;

out_write_proc: process(write_state, scale_pos_src, scale_line_src, scale_index, scale_pos_dst, scale_line_dst, act_scale_len, addr_ready)
begin    
    addr_valid <= '0';
    addr_x <= (others => '0');
    addr_y <= (others => '0');
    addr_scale <= (others => '0');
    addr_we <= '0';
    
    scale_end <= '0';
    case write_state is
        when INIT =>
        when START =>
        when READ =>
            if addr_ready = '1' then    -- not (scale_pos_src >= act_scale_len) and 
                addr_valid <= '1';
                addr_x <= scale_pos_src;
                addr_y <= scale_line_src;
                addr_scale <= scale_index;
            end if;
        when WRITE =>
            if addr_ready = '1' then
                addr_valid <= '1';
                addr_x <= scale_pos_dst;
                addr_y <= scale_line_dst;
                addr_scale <= scale_index+ '1';
                addr_we <= '1';
            end if;
        when ONLY_WRITE => 
            if addr_ready = '1' then
                addr_valid <= '1';
                addr_x <= scale_pos_dst;
                addr_y <= scale_line_dst;
                addr_scale <= scale_index+ '1';
                addr_we <= '1';
            end if;
        when SCALE0 =>            
        when SCALE1 =>        
        when SCALE2 =>        
        when SCALE3 =>        
        when SCALE4 =>
        when END_SCALE =>
            scale_end <= '1';
    end case;
end process;


---------------------------------------------------------------------------------------------
scaler_proc: process(aclk)

begin
    if aclk'event and aclk = '1' then
            
            temp_valid <= data_in_valid;    -- TODO
            scale_block_valid <=temp_valid;
            
            for y in 0 to 4 loop
                for x in 0 to 4 loop
                    if temp(y)(x)(12) = '1' then
                        scale_block(y)(x) <= X"FF";
                    else
                        scale_block(y)(x) <= temp(y)(x)(11 downto 4);
                    end if;
                end loop;
            end loop;
            
               --y  x
            temp(0)(0)  <=  '0'&data_in(0)(0)&"0000";                                              --( 16 )/16
            temp(0)(1)  <=  ("000"&data_in(0)(1)&"00") + (data_in(0)(1)&"000") + ('0'&data_in(0)(2)&"00");    --( 12 + 4 )/16
            temp(0)(2)  <=  ("00"&data_in(0)(2)&"000") +  (data_in(0)(3)&"000");                        --( 8 + 8 )/16
            temp(0)(3)  <=  ("00"&data_in(0)(3)&"000") +  (data_in(0)(4)&"000");                        --( 8 + 8 )/16
            temp(0)(4)  <=  ("000"&data_in(0)(4)&"00") + (data_in(0)(5)&"00") + (data_in(0)(5)&"000");   --( 4 + 12 )/16
            
            temp(1)(0)  <= ("00"&data_in(1)(0)&"000") + ("000"&data_in(1)(0)&"00") + ("000"&data_in(2)(0)&"00");                           --( 12 + 4 )/16
            temp(1)(1)  <=  ("00000"&data_in(1)(1)) + ("00"&data_in(1)(1)&"000") + ("00000"&data_in(1)(2)) + ("0000"&data_in(1)(2)&'0') +
                            ("00000"&data_in(2)(1)) + ("0000"&data_in(2)(1)&'0') + ("00000"&data_in(2)(2));                 -- ( 9 + 3 + 3 + 1 )/16
            temp(1)(2)  <= ("000"&data_in(1)(2)&"00") + ("0000"&data_in(1)(2)&'0') + ("000"&data_in(1)(3)&"00") + ("0000"&data_in(1)(3)&'0') +
                            ("0000"&data_in(2)(2)&'0') + ("0000"&data_in(2)(3)&'0');                                        --( 6 + 6 + 2 + 2 )/16
            temp(1)(3)  <= ("000"&data_in(1)(3)&"00") + ("0000"&data_in(1)(3)&'0') + ("000"&data_in(1)(4)&"00") + ("0000"&data_in(1)(4)&'0') +
                            ("0000"&data_in(2)(3)&'0') + ("0000"&data_in(2)(4)&'0');                                        --( 6 + 6 + 2 + 2 )/16
            temp(1)(4)  <= ("0000"&data_in(1)(4)&'0') + ("00000"&data_in(1)(4)) + ("00000"&data_in(1)(5)) + ("00"&data_in(1)(5)&"000") +
                            ("00000"&data_in(2)(4)) + ("00000"&data_in(2)(5)) + ("0000"&data_in(2)(5)&'0');                 --( 3 + 9 + 1 + 3 )/16
            
            temp(2)(0)  <= ("00"&data_in(2)(0)&"000") + ("00"&data_in(3)(0)&"000");                                         -- ( 8 + 8 )/16
            temp(2)(1)  <= ("000"&data_in(2)(1)&"00") + ("0000"&data_in(2)(1)&"0") + ("0000"&data_in(2)(2)&"0") + 
                            ("000"&data_in(3)(1)&"00") + ("0000"&data_in(3)(1)&"0") + ("0000"&data_in(3)(2)&"0");           -- ( 6 + 2 + 2 + 6 )/16  
            temp(2)(2)  <= ("000"&data_in(2)(2)&"00") + ("000"&data_in(2)(3)&"00") + 
                            ("000"&data_in(3)(2)&"00") + ("000"&data_in(3)(3)&"00");                                        -- ( 4 + 4 + 4 + 4 )/16
            temp(2)(3)  <= ("000"&data_in(2)(3)&"00") + ("000"&data_in(2)(4)&"00") + 
                            ("000"&data_in(3)(3)&"00") + ("000"&data_in(3)(4)&"00");
            temp(2)(4)  <= ("0000"&data_in(2)(4)&"0") + ("000"&data_in(2)(5)&"00") + ("0000"&data_in(2)(5)&"0") + 
                            ("0000"&data_in(3)(4)&"0") + ("000"&data_in(3)(5)&"00") + ("0000"&data_in(3)(5)&"0");           -- ( 2 + 6 + 2 + 6 )/16
                        
            temp(3)(0)  <= ("00"&data_in(3)(0)&"000") + ("00"&data_in(4)(0)&"000");                                         -- ( 8 + 8 )/16
            temp(3)(1)  <= ("000"&data_in(3)(1)&"00") + ("0000"&data_in(3)(1)&"0") + ("0000"&data_in(3)(2)&"0") + 
                            ("000"&data_in(4)(1)&"00") + ("0000"&data_in(4)(1)&"0") + ("0000"&data_in(4)(2)&"0");           -- ( 6 + 2 + 2 + 6 )/16  
            temp(3)(2)  <= ("000"&data_in(3)(2)&"00") + ("000"&data_in(3)(3)&"00") + 
                            ("000"&data_in(4)(2)&"00") + ("000"&data_in(4)(3)&"00");                                        -- ( 4 + 4 + 4 + 4 )/16
            temp(3)(3)  <= ("000"&data_in(3)(3)&"00") + ("000"&data_in(3)(4)&"00") + 
                            ("000"&data_in(4)(3)&"00") + ("000"&data_in(4)(4)&"00");
            temp(3)(4)  <= ("0000"&data_in(3)(4)&"0") + ("000"&data_in(3)(5)&"00") + ("0000"&data_in(3)(5)&"0") + 
                            ("0000"&data_in(4)(4)&"0") + ("000"&data_in(4)(5)&"00") + ("0000"&data_in(4)(5)&"0");           -- ( 2 + 6 + 2 + 6 )/16
            
            
            temp(4)(0)  <= ("00"&data_in(5)(0)&"000") + ("000"&data_in(5)(0)&"00") + ("000"&data_in(4)(0)&"00");                           --( 12 + 4 )/16
            temp(4)(1)  <=  ("00000"&data_in(5)(1)) + ("00"&data_in(5)(1)&"000") + ("00000"&data_in(5)(2)) + ("0000"&data_in(5)(2)&'0') +
                            ("00000"&data_in(4)(1)) + ("0000"&data_in(4)(1)&'0') + ("00000"&data_in(4)(2));                 -- ( 9 + 3 + 3 + 1 )/16
            temp(4)(2)  <= ("000"&data_in(5)(2)&"00") + ("0000"&data_in(5)(2)&'0') + ("000"&data_in(5)(3)&"00") + ("0000"&data_in(5)(3)&'0') +
                            ("0000"&data_in(4)(2)&'0') + ("0000"&data_in(4)(3)&'0');                                        --( 6 + 6 + 2 + 2 )/16
            temp(4)(3)  <= ("000"&data_in(5)(3)&"00") + ("0000"&data_in(5)(3)&'0') + ("000"&data_in(5)(4)&"00") + ("0000"&data_in(5)(4)&'0') +
                            ("0000"&data_in(4)(3)&'0') + ("0000"&data_in(4)(4)&'0');                                        --( 6 + 6 + 2 + 2 )/16
            temp(4)(4)  <= ("0000"&data_in(5)(4)&'0') + ("00000"&data_in(5)(4)) + ("00000"&data_in(5)(5)) + ("00"&data_in(5)(5)&"000") +
                            ("00000"&data_in(4)(4)) + ("00000"&data_in(4)(5)) + ("0000"&data_in(4)(5)&'0');                 --( 3 + 9 + 1 + 3 )/16  
    end if;
end process;

--------------------------------------------------------------------------------
scale_len_bram_write: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if scale_len_we = '1' then
            scale_len_ram(conv_integer(scale_len_addr)) <= scale_len_data;               
        end if;
    end if;
end process;

scale_len_bram_read: process(aclk)
begin
    if aclk'event and aclk = '1' then
        act_scale_len <= scale_len_ram(conv_integer(scale_index));
    end if;
end process;

end Behavioral;
