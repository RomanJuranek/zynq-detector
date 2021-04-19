----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2015 03:13:19 PM
-- Design Name: 
-- Module Name: dsp - Behavioral
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

use work.data_types.all;		-- my data types

entity dsp is  
    Port ( 
        aclk            : in std_logic;
        
        dsp_mode        : in std_logic_vector(1 downto 0);
        
        data_in         : in array_6x6x8b;
        data_in_valid   : in std_logic;
        data_in_ready   : out std_logic;
        data_out        : out array_3x3x8b;
        data_out_valid  : out std_logic;
        data_out_ready  : in std_logic       
    );
end dsp;

architecture Behavioral of dsp is

type array_3x10b is array (2 downto 0) of std_logic_vector(9 downto 0);
type array_3x3x10b is array (2 downto 0) of array_3x10b;

signal dsp_1x1  : array_3x3x10b;
signal dsp_1x2  : array_3x3x10b;
signal dsp_2x1  : array_3x3x10b;
signal dsp_2x2  : array_3x3x10b;
begin


data_in_ready <= data_out_ready;

sync_proc: process(aclk)
begin
    if aclk'event and aclk = '1' then    
        if data_out_ready = '1' then
            data_out_valid <= data_in_valid;
            
            for y in 0 to 2 loop
                for x in 0 to 2 loop
                    case dsp_mode is
                        when "00" =>   
                            data_out(y)(x) <= dsp_1x1(y)(x)(7 downto 0);         
                        when "01" =>
                            data_out(y)(x) <= dsp_1x2(y)(x)(8 downto 1);
                        when "10" =>
                            data_out(y)(x) <= dsp_2x1(y)(x)(8 downto 1);
                        when "11" =>
                            data_out(y)(x) <= dsp_2x2(y)(x)(9 downto 2);
                        when others =>
                    end case;
                end loop;
            end loop;
        end if;
    end if;
end process;


gen0: for y in 0 to 2 generate
    gen1: for x in 0 to 2 generate
        dsp_1x1(y)(x) <= "00"& data_in(y)(x);
        dsp_1x2(y)(x) <= "00"&data_in(y)(2*x)+ data_in(y)(2*x+1);
        dsp_2x1(y)(x) <= "00"&data_in(2*y)(x) + data_in(2*y+1)(x);
        dsp_2x2(y)(x) <= "00"&data_in(2*y)(2*x) + data_in(2*y)(2*x+1)+
                           data_in(2*y+1)(2*x) + data_in(2*y+1)(2*x+1);
    end generate;
end generate;

end Behavioral;
