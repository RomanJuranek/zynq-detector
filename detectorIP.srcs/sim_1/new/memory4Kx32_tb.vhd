----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2015 08:13:03 PM
-- Design Name: 
-- Module Name: memory4Kx32_tb - Behavioral
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

use work.data_types.all;		-- my data types

entity tb_memory4Kx32 is
end tb_memory4Kx32;

architecture tb of tb_memory4Kx32 is

    component memory4Kx32
        port (aclk          : in std_logic;
              resetn        : in std_logic;
              input_lineA   : in std_logic_vector (127 downto 0);
              input_lineB   : in std_logic_vector (127 downto 0);
              input_addr_x  : in std_logic_vector (12 downto 0);    -- po nasobku 16
              input_addr_y  : in std_logic_vector (12 downto 0);
              input_we_line : in std_logic_vector (1 downto 0);
              addr0_x       : in std_logic_vector (12 downto 0);
              addr0_y       : in std_logic_vector (12 downto 0);
              data0         : out array_8x8x8b;
              addr1_x       : in std_logic_vector (12 downto 0);
              addr1_y       : in std_logic_vector (12 downto 0);
              data1         : out array_8x8x8b);
    end component;

    signal aclk          : std_logic :='0';
    signal resetn        : std_logic :='1';
    signal input_lineA   : std_logic_vector (127 downto 0) := (others => '0');
    signal input_lineB   : std_logic_vector (127 downto 0) := (others => '0');
    signal input_addr_x  : std_logic_vector (12 downto 0) := (others => '0');
    signal input_addr_y  : std_logic_vector (12 downto 0):= (others => '0');
    signal input_we_line : std_logic_vector (1 downto 0):= (others => '0');
    signal addr0_x       : std_logic_vector (12 downto 0):= (others => '0');
    signal addr0_y       : std_logic_vector (12 downto 0):= (others => '0');
    signal data0         : array_8x8x8b;
    signal addr1_x       : std_logic_vector (12 downto 0):= (others => '0');
    signal addr1_y       : std_logic_vector (12 downto 0):= (others => '0');
    signal data1         : array_8x8x8b;

    constant TbPeriod : time := 5 ns; -- EDIT put right period here

begin

    dut : memory4Kx32
    port map (aclk          => aclk,
              resetn        => resetn,
              input_lineA   => input_lineA,
              input_lineB   => input_lineB,
              input_addr_x  => input_addr_x,
              input_addr_y  => input_addr_y,
              input_we_line => input_we_line,
              addr0_x       => addr0_x,
              addr0_y       => addr0_y,
              data0         => data0,
              addr1_x       => addr1_x,
              addr1_y       => addr1_y,
              data1         => data1);

    aclk <= not aclk after TbPeriod/2;

    stimuli : process
    begin
        wait for TbPeriod*5;
        for y in 0 to 15 loop
            for x in 0 to 44 loop
                input_addr_x <= conv_std_logic_vector(16*x,13);
                input_addr_y <= conv_std_logic_vector(y,13);
                input_lineA <= 
                    conv_std_logic_vector(y+16*x+15,8) & conv_std_logic_vector(y+16*x+14,8) & conv_std_logic_vector(y+16*x+13,8) & conv_std_logic_vector(y+16*x+12,8) &
                    conv_std_logic_vector(y+16*x+11,8) & conv_std_logic_vector(y+16*x+10,8) & conv_std_logic_vector(y+16*x+9,8) & conv_std_logic_vector(y+16*x+8,8) &
                    conv_std_logic_vector(y+16*x+7,8) & conv_std_logic_vector(y+16*x+6,8) & conv_std_logic_vector(y+16*x+5,8) & conv_std_logic_vector(y+16*x+4,8) &
                    conv_std_logic_vector(y+16*x+3,8) & conv_std_logic_vector(y+16*x+2,8) & conv_std_logic_vector(y+16*x+1,8) & conv_std_logic_vector(y+16*x+0,8);
                input_we_line <= "01";
                wait for TbPeriod;
--                input_addr_x <= conv_std_logic_vector(0,13);
--                input_addr_y <= conv_std_logic_vector(0,13);
--                input_lineA <= (others => '0');
--                input_we_line <= "00";
--                wait for TbPeriod*3;        
            end loop;
        end loop;
        input_addr_x <= conv_std_logic_vector(0,13);
        input_addr_y <= conv_std_logic_vector(0,13);
        input_lineA <= (others => '0');
        input_we_line <= "00";
        
        wait for TbPeriod*50; 
        for y in 0 to 7 loop
            for x in 0 to 63 loop
                addr0_x <= conv_std_logic_vector(x,13);
                addr0_y <= conv_std_logic_vector(y,13);
                wait for TbPeriod;
            end loop;
        end loop;
        -- EDIT
        wait;
    end process;

end tb;
