----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2015 04:16:45 PM
-- Design Name: 
-- Module Name: instruct_image - Behavioral
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

entity instruct_image is
    Generic(
        INSTRUCT_LIMIT  : integer := 1024
    );
	Port(
        aclk        : in std_logic;
        
        in0_addr    : in std_logic_vector(9 downto 0);
        in0_valid   : in std_logic;
        in0_ready   : out std_logic := '0';
        out0_data   : out std_logic_vector(31 downto 0) := (others => '0');
        out0_valid  : out std_logic := '0';
        out0_ready  : in std_logic;
        
        in1_addr    : in std_logic_vector(9 downto 0);
        in1_valid   : in std_logic;
        in1_ready   : out std_logic := '0';
        out1_data   : out std_logic_vector(31 downto 0) := (others => '0');
        out1_valid  : out std_logic := '0';
        out1_ready  : in std_logic;        
        
        instr_data  : in std_logic_vector(31 downto 0);    -- plnění
        instr_addr  : in std_logic_vector(9 downto 0);
        instr_ena   : in std_logic
    );
end instruct_image;

architecture Behavioral of instruct_image is

type array_INSTRUCT_LIMITx32b is array (0 to INSTRUCT_LIMIT-1) of std_logic_vector(31 downto 0);


impure function InitInstructFile (RomFileName : in string) return array_INSTRUCT_LIMITx32b is                            
    file RomFile : text open read_mode is RomFileName;                                                              
    variable rdline : line;                                                                        
    variable rom : array_INSTRUCT_LIMITx32b;                                                                            
                                                                                                        
begin                                                                                                   
    for i in array_INSTRUCT_LIMITx32b'range loop                                                                        
        readline (RomFile, rdline);                                                                
        hread (rdline, rom(i));                                                                     
    end loop;                                                                                           
    return rom;                                                                                         
end function;  

signal bram     : array_INSTRUCT_LIMITx32b := InitInstructFile("instruct.mem");
signal addr_a   : std_logic_vector(9 downto 0);

begin

addr_a <= instr_addr when instr_ena='1' else in0_addr;

sync0_proc: process(aclk)
begin
    if aclk'event and aclk = '1' then
        out0_valid <= in0_valid;       
    end if;
end process;


sync1_proc: process(aclk)
begin
    if aclk'event and aclk = '1' then
        out1_valid <= in1_valid;
    end if;
end process;


bram_A: process(aclk)
begin
    if aclk'event and aclk = '1' then
        if instr_ena = '1' then
            bram(conv_integer(addr_a)) <= instr_data;         
        else  
            out0_data <= bram(conv_integer(addr_a)); 
        end if;
    end if;
end process;

bram_B: process(aclk)
begin
    if aclk'event and aclk = '1' then
        out1_data <= bram(conv_integer(in1_addr));
    end if;
end process;



end Behavioral;
