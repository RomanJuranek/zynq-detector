----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2015 04:42:48 PM
-- Design Name: 
-- Module Name: memory4Kx32 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use work.data_types.all;		-- my data types

entity memory4Kx32 is
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
end memory4Kx32;

architecture Behavioral of memory4Kx32 is




type array_1Kx4By is array (1023 downto 0) of std_logic_vector(31 downto 0);
type array_32x1Kx4By is array (31 downto 0) of array_1Kx4By;
type array_8x4b is array (7 downto 0) of std_logic_vector(3 downto 0);
type array_4x4b is array (3 downto 0) of std_logic_vector(3 downto 0);
type array_5x3b is array (4 downto 0) of std_logic_vector(2 downto 0);
type array_4x4By is array (3 downto 0) of std_logic_vector(31 downto 0);
type array_8x4x4By is array (7 downto 0) of array_4x4By;
type array_4x10b is array (3 downto 0) of std_logic_vector(9 downto 0);
type array_8x4x10b is array (7 downto 0) of array_4x10b;
type array_8x2b is array (7 downto 0) of std_logic_vector(1 downto 0);
type array_4x8b is array (3 downto 0) of std_logic_vector(7 downto 0);

type array_12x8b is array (11 downto 0) of std_logic_vector(7 downto 0);
type array_8x12x8b is array (7 downto 0) of array_12x8b;


signal ram          : array_32x1Kx4By;
signal ram_we       : array_8x4b ;
signal ram_in       : array_8x4x4By;
signal ram_addr_A   : array_8x4x10b :=(others =>(others=> (others => '0')));
signal ram_out_A    : array_8x4x4By;
signal ram_addr_B   : array_8x4x10b :=(others =>(others=> (others => '0')));
signal ram_out_B    : array_8x4x4By;
signal ram_addr_save: array_8x4x10b :=(others =>(others=> (others => '0')));
signal ram_out_save : array_8x4x4By;

signal ram_useA     : array_8x4x4By;

signal addr0_x_next : array_4x4b;
signal addr0_y_next : array_5x3b;
signal mux1_A       : array_8x12x8b;
signal mux2_A       : array_8x8x8b;

signal addr1_x_next : array_4x4b;
signal addr1_y_next : array_5x3b;
signal mux1_B       : array_8x12x8b;
signal mux2_B       : array_8x8x8b;
--
signal we_next      : std_logic_vector(1 downto 0);
signal test : std_logic:='0';


begin

----------------------------------------------------------------------------------------------
------------------------------- WRITE CONTROL ------------------------------------------------
write_data_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then        
          -- one line write
          
        for y in 0 to 7 loop
            ram_in(y)(0) <= input_line(31  downto 0);
            ram_in(y)(1) <= input_line(63  downto 32);
            ram_in(y)(2) <= input_line(95  downto 64);
            ram_in(y)(3) <= input_line(127 downto 96);
        end loop;
        
        if input_we_line(1) = '1' then    -- dual line write
           for y in 0 to 7 loop
                ram_in((y+conv_integer(input_addr_y(2 downto 0))) mod 8)(0) <= input_scale(y mod 5);
                ram_in((y+conv_integer(input_addr_y(2 downto 0))) mod 8)(1) <= input_scale(y mod 5);
                ram_in((y+conv_integer(input_addr_y(2 downto 0))) mod 8)(2) <= input_scale(y mod 5);
                ram_in((y+conv_integer(input_addr_y(2 downto 0))) mod 8)(3) <= input_scale(y mod 5);
            end loop;
        end if;
    end if;
end process;

write_we_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        we_next(0) <= input_we_line(0);
        we_next(1) <= we_next(0);
        ram_we <= (others => "0000");
        if input_we_line(0) = '1' then
            if input_we_line(1) = '0' then  -- one line write
                ram_we(conv_integer(input_addr_y(2 downto 0))) <= "1111";
            else    -- dual line write
                ram_we((conv_integer(input_addr_y(2 downto 0))))(conv_integer(input_addr_x(3 downto 2))) <= '1';
                ram_we((conv_integer(input_addr_y(2 downto 0))+1) mod 8)(conv_integer(input_addr_x(3 downto 2))) <= '1';
                ram_we((conv_integer(input_addr_y(2 downto 0))+2) mod 8)(conv_integer(input_addr_x(3 downto 2))) <= '1';
                ram_we((conv_integer(input_addr_y(2 downto 0))+3) mod 8)(conv_integer(input_addr_x(3 downto 2))) <= '1';
                ram_we((conv_integer(input_addr_y(2 downto 0))+4) mod 8)(conv_integer(input_addr_x(3 downto 2))) <= '1';
            end if;
        end if;
    end if;
end process;

----------------------------------------------------------------------------------------------
------------------------------- ADDRES CONTROL ------------------------------------------------
addrA_sync: process(aclk)
variable addr_y : array_8x2b;
variable addr_x : array_4x8b;
begin
    if aclk'event and aclk = '1' then
    
        addr0_x_next(0) <= addr0_x(3 downto 0);
        addr0_x_next(1) <= addr0_x_next(0);
        addr0_x_next(2) <= addr0_x_next(1);
        addr0_x_next(3) <= addr0_x_next(2);
        
        addr0_y_next(0) <= addr0_y(2 downto 0);
        addr0_y_next(1) <= addr0_y_next(0);
        addr0_y_next(2) <= addr0_y_next(1);
        addr0_y_next(3) <= addr0_y_next(2);
        addr0_y_next(4) <= addr0_y_next(3);
        
        if input_we_line(0) = '1' then
            for y in 0 to 7 loop
                if input_addr_y(2 downto 0) > y then
                    addr_y(y) := input_addr_y(4 downto 3) + '1';
                else
                    addr_y(y) := input_addr_y(4 downto 3);
                end if; 
                ram_addr_A(y) <= (others=>(addr_y(y) & input_addr_x(11 downto 4)));   -- po nasobku 16
            end loop; 
            
        else
            for y in 0 to 7 loop
                if addr0_y(2 downto 0) > y then
                    addr_y(y) := addr0_y(4 downto 3) + '1';
                else
                    addr_y(y) := addr0_y(4 downto 3);
                end if;
                
                for x in 0 to 3 loop
                    if addr0_x(3 downto 2) > x then
                        addr_x(x) := addr0_x(11 downto 4)+'1';
                    else
                        addr_x(x) := addr0_x(11 downto 4);
                    end if;                    
                    
                    
                    ram_addr_A(y)(x) <=  addr_y(y) & addr_x(x);
                    
                end loop; 
            end loop;
        end if;
    end if;
end process;

addrB_sync: process(aclk)
variable addr_y : array_8x2b;
variable addr_x : array_4x8b;
begin
    if aclk'event and aclk = '1' then  
    
        
        addr1_x_next(0) <= addr1_x(3 downto 0);
        addr1_x_next(1) <= addr1_x_next(0);
        addr1_x_next(2) <= addr1_x_next(1);
        addr1_x_next(3) <= addr1_x_next(2);
        
        addr1_y_next(0) <= addr1_y(2 downto 0);
        addr1_y_next(1) <= addr1_y_next(0);
        addr1_y_next(2) <= addr1_y_next(1);
        addr1_y_next(3) <= addr1_y_next(2);
        addr1_y_next(4) <= addr1_y_next(3);
        
          
        for y in 0 to 7 loop
            if addr1_y(2 downto 0) > y then
                addr_y(y) := addr1_y(4 downto 3) + '1';
            else
                addr_y(y) := addr1_y(4 downto 3);
            end if;
            
            for x in 0 to 3 loop
                if addr1_x(3 downto 2) > x then
                    addr_x(x) := addr1_x(11 downto 4)+'1';
                else
                    addr_x(x) := addr1_x(11 downto 4);
                end if;
                
                ram_addr_B(y)(x) <=  addr_y(y) & addr_x(x);   -- po nasobku 16
                
            end loop; 
            
        end loop;
    end if;
end process;


----------------------------------------------------------------------------------------------
------------------------------- OUT MUX ------------------------------------------------------
mux1_A_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if addr0_ready = '1' then 
            for y in 0 to 7 loop   
                case addr0_x_next(1)(3 downto 2) is
                    when "00" =>
                        for i in 0 to 2 loop 
                            mux1_A(y)(i*4+0) <= ram_out_A(y)(i)(7 downto 0);
                            mux1_A(y)(i*4+1) <= ram_out_A(y)(i)(15 downto 8);
                            mux1_A(y)(i*4+2) <= ram_out_A(y)(i)(23 downto 16);
                            mux1_A(y)(i*4+3) <= ram_out_A(y)(i)(31 downto 24);
                        end loop;
                    when "01" =>
                        for i in 0 to 2 loop 
                            mux1_A(y)(i*4+0) <= ram_out_A(y)((i+1) mod 4)(7 downto 0);
                            mux1_A(y)(i*4+1) <= ram_out_A(y)((i+1) mod 4)(15 downto 8);
                            mux1_A(y)(i*4+2) <= ram_out_A(y)((i+1) mod 4)(23 downto 16);
                            mux1_A(y)(i*4+3) <= ram_out_A(y)((i+1) mod 4)(31 downto 24);
                        end loop;
                    when "10" =>
                        for i in 0 to 2 loop 
                            mux1_A(y)(i*4+0) <= ram_out_A(y)((i+2) mod 4)(7 downto 0);
                            mux1_A(y)(i*4+1) <= ram_out_A(y)((i+2) mod 4)(15 downto 8);
                            mux1_A(y)(i*4+2) <= ram_out_A(y)((i+2) mod 4)(23 downto 16);
                            mux1_A(y)(i*4+3) <= ram_out_A(y)((i+2) mod 4)(31 downto 24);
                        end loop;
                    when "11" =>
                        for i in 0 to 2 loop 
                            mux1_A(y)(i*4+0) <= ram_out_A(y)((i+3) mod 4)(7 downto 0);
                            mux1_A(y)(i*4+1) <= ram_out_A(y)((i+3) mod 4)(15 downto 8);
                            mux1_A(y)(i*4+2) <= ram_out_A(y)((i+3) mod 4)(23 downto 16);
                            mux1_A(y)(i*4+3) <= ram_out_A(y)((i+3) mod 4)(31 downto 24);
                        end loop;
                    when others =>
                end case; 
            end loop; 
        --end if;       
    end if;
end process;

mux2_A_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if addr0_ready = '1' then 
            for y in 0 to 7 loop   
                case addr0_x_next(2)(1 downto 0) is
                    when "00" =>
                        for x in 0 to 7 loop
                            mux2_A(y)(x) <= mux1_A(y)(x);
                        end loop;
                    when "01" =>
                        for x in 0 to 7 loop
                            mux2_A(y)(x) <= mux1_A(y)(x+1);
                        end loop;
                    when "10" =>
                        for x in 0 to 7 loop
                            mux2_A(y)(x) <= mux1_A(y)(x+2);
                        end loop;                    
                    when "11" =>
                        for x in 0 to 7 loop
                            mux2_A(y)(x) <= mux1_A(y)(x+3);
                        end loop;                   
                    when others =>
                end case; 
            end loop;
        --end if;
    end if;
end process;

mux3_A_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if addr0_ready = '1' then 
            for x in 0 to 5 loop   
                case addr0_y_next(3)(2 downto 0) is
                    when "000" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A(y)(x);   
                        end loop;
                    when "001" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+1) mod 8)(x);   
                        end loop; 
                    when "010" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+2) mod 8)(x);   
                        end loop; 
                    when "011" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+3) mod 8)(x);   
                        end loop; 
                    when "100" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+4) mod 8)(x);   
                        end loop; 
                    when "101" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+5) mod 8)(x);   
                        end loop; 
                    when "110" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+6) mod 8)(x);   
                        end loop;
                    when "111" =>
                        for y in 0 to 5 loop
                            data0(y)(x) <=  mux2_A((y+7) mod 8)(x);   
                        end loop;                      
                    when others =>
                end case; 
            end loop;
        --end if;
    end if;
end process;
-----------------------------------------------------------------------------------------
mux1_B_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if addr1_ready = '1' then 
            for y in 0 to 7 loop   
                case addr1_x_next(1)(3 downto 2) is
                    when "00" =>
                        for i in 0 to 2 loop 
                            mux1_B(y)(i*4+0) <= ram_out_B(y)(i)(7 downto 0);
                            mux1_B(y)(i*4+1) <= ram_out_B(y)(i)(15 downto 8);
                            mux1_B(y)(i*4+2) <= ram_out_B(y)(i)(23 downto 16);
                            mux1_B(y)(i*4+3) <= ram_out_B(y)(i)(31 downto 24);
                        end loop;
                    when "01" =>
                        for i in 0 to 2 loop 
                            mux1_B(y)(i*4+0) <= ram_out_B(y)((i+1) mod 4)(7 downto 0);
                            mux1_B(y)(i*4+1) <= ram_out_B(y)((i+1) mod 4)(15 downto 8);
                            mux1_B(y)(i*4+2) <= ram_out_B(y)((i+1) mod 4)(23 downto 16);
                            mux1_B(y)(i*4+3) <= ram_out_B(y)((i+1) mod 4)(31 downto 24);
                        end loop;
                    when "10" =>
                        for i in 0 to 2 loop 
                            mux1_B(y)(i*4+0) <= ram_out_B(y)((i+2) mod 4)(7 downto 0);
                            mux1_B(y)(i*4+1) <= ram_out_B(y)((i+2) mod 4)(15 downto 8);
                            mux1_B(y)(i*4+2) <= ram_out_B(y)((i+2) mod 4)(23 downto 16);
                            mux1_B(y)(i*4+3) <= ram_out_B(y)((i+2) mod 4)(31 downto 24);
                        end loop;
                    when "11" =>
                        for i in 0 to 2 loop 
                            mux1_B(y)(i*4+0) <= ram_out_B(y)((i+3) mod 4)(7 downto 0);
                            mux1_B(y)(i*4+1) <= ram_out_B(y)((i+3) mod 4)(15 downto 8);
                            mux1_B(y)(i*4+2) <= ram_out_B(y)((i+3) mod 4)(23 downto 16);
                            mux1_B(y)(i*4+3) <= ram_out_B(y)((i+3) mod 4)(31 downto 24);
                        end loop;
                    when others =>
                end case; 
            end loop;
        --end if;
    end if;
end process;

mux2_B_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if addr1_ready = '1' then 
            for y in 0 to 7 loop   
                case addr1_x_next(2)(1 downto 0) is
                    when "00" =>
                        for x in 0 to 7 loop
                            mux2_B(y)(x) <= mux1_B(y)(x);
                        end loop;
                    when "01" =>
                        for x in 0 to 7 loop
                            mux2_B(y)(x) <= mux1_B(y)(x+1);
                        end loop;
                    when "10" =>
                        for x in 0 to 7 loop
                            mux2_B(y)(x) <= mux1_B(y)(x+2);
                        end loop;                    
                    when "11" =>
                        for x in 0 to 7 loop
                            mux2_B(y)(x) <= mux1_B(y)(x+3);
                        end loop;                   
                    when others =>
                end case; 
            end loop;
        --end if;
    end if;
end process;

mux3_B_sync: process(aclk)
begin
    if aclk'event and aclk = '1' then
        --if addr1_ready = '1' then 
            for x in 0 to 5 loop   
                case addr1_y_next(3)(2 downto 0) is
                    when "000" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B(y)(x);   
                        end loop;
                    when "001" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+1) mod 8)(x);   
                        end loop; 
                    when "010" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+2) mod 8)(x);   
                        end loop; 
                    when "011" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+3) mod 8)(x);   
                        end loop; 
                    when "100" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+4) mod 8)(x);   
                        end loop; 
                    when "101" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+5) mod 8)(x);   
                        end loop; 
                    when "110" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+6) mod 8)(x);   
                        end loop;
                    when "111" =>
                        for y in 0 to 5 loop
                            data1(y)(x) <=  mux2_B((y+7) mod 8)(x);   
                        end loop;                      
                    when others =>
                end case; 
            end loop;
        --end if;
    end if;
end process;

----------------------------------------------------------------------------------------------
------------------------------- BRAM ---------------------------------------------------------
--x_gen: for x in 0 to 3 generate
--    y_gen: for y in 0 to 7 generate
--        ---------------------------------------        
--        bram_A:process(aclk)
--        begin
--            if aclk'event and aclk = '1' then
--                if ram_we(y)(x) = '1' then
--                    ram(y*4 + x)(conv_integer(ram_addr_A(y)(x)))<= ram_in(y mod 2)(x);
--                end if;    
--                ram_out_A(y)(x) <= ram(y*4 + x)(conv_integer(ram_addr_A(y)(x)));
--            end if;
--        end process;
--        --------------------------------------
--        bram_B:process(aclk)        
--        begin
--            if aclk'event and aclk = '1' then            
--            ram_out_B(y)(x) <= ram(y*4 + x)(conv_integer(ram_addr_B(y)(x)));
--            end if;
--        end process;
--        -------------------------------------
--    end generate y_gen;
--end generate x_gen;

x_gen: for x in 0 to 3 generate
    y_gen: for y in 0 to 7 generate
        BRAM_TDP_MACRO_inst : BRAM_TDP_MACRO
           generic map (
              BRAM_SIZE => "36Kb",
              DEVICE => "7SERIES",
              READ_WIDTH_A => 32,
              READ_WIDTH_B => 32,
              WRITE_WIDTH_A => 32,
              WRITE_WIDTH_B => 32,
              SIM_COLLISION_CHECK => "NONE",
              DOA_REG => 0,
              DOB_REG => 0, 
              WRITE_MODE_A => "NO_CHANGE",
              WRITE_MODE_B => "NO_CHANGE"
              )
           port map (
              DOA => ram_out_A(y)(x),       -- Output port-A data, width defined by READ_WIDTH_A parameter
              DOB => ram_out_B(y)(x),       -- Output port-B data, width defined by READ_WIDTH_B parameter
              ADDRA => ram_addr_A(y)(x),   -- Input port-A address, width defined by Port A depth
              ADDRB => ram_addr_B(y)(x),   -- Input port-B address, width defined by Port B depth
              CLKA => aclk,     -- 1-bit input port-A clock
              CLKB => aclk,     -- 1-bit input port-B clock
              DIA => ram_in(y)(x),       -- Input port-A data, width defined by WRITE_WIDTH_A parameter
              DIB => (others => '0'),       -- Input port-B data, width defined by WRITE_WIDTH_B parameter
              ENA => '1',       -- 1-bit input port-A enable
              ENB => '1',       -- 1-bit input port-B enable
              REGCEA => '1', -- 1-bit input port-A output register enable
              REGCEB => '1', -- 1-bit input port-B output register enable
              RSTA => '0',     -- 1-bit input port-A reset
              RSTB => '0',     -- 1-bit input port-B reset
              WEA(0) => ram_we(y)(x),       -- Input port-A write enable, width defined by Port A depth
              WEA(1) => ram_we(y)(x),
              WEA(2) => ram_we(y)(x),
              WEA(3) => ram_we(y)(x),
              WEB => "0000"       -- Input port-B write enable, width defined by Port B depth
           );
    end generate y_gen;
end generate x_gen;


test_proc:process(ram_addr_A,ram_we)
begin
	test <= '0';
	if ram_addr_A(1)(3) = 8 and ram_we(1)(3) = '1' then
		test <= '1';
	end if;
end process;

end Behavioral;
