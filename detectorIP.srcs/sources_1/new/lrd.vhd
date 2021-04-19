----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2015 07:44:05 PM
-- Design Name: 
-- Module Name: lrd - Behavioral
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
use IEEE.std_logic_unsigned.all;
use work.data_types.all;		-- my data types

entity lrd is
	port(
		CLK 		: in std_logic;
		RANK_POS_A	: in std_logic_vector(3 downto 0); -- pozice RankA (0-8)
		RANK_POS_B	: in std_logic_vector(3 downto 0);
		
		DATA_READY  : in std_logic;
		DATA_IN	    : in array_3x3x8b;
		DATA_IN_VALID : in std_logic;
		
		DATA_OUT	: out std_logic_vector(4 downto 0);
		DATA_OUT_VALID : out std_logic
	);
end lrd;

architecture Behavioral of lrd is

	component rank_func is
		port(
			CLK			: in std_logic;
            DATA_READY  : in std_logic;
			DATA_IN		: in array_3x3x8b;
			POS			: in std_logic_vector(3 downto 0);
			
			RANK_BIT		: out std_logic_vector(8 downto 0)
		);
	end component;
	
	signal RANK_A_BIT : std_logic_vector(8 downto 0);
	signal RANK_B_BIT : std_logic_vector(8 downto 0);
	signal next_valid : std_logic; 

begin
	-- vypočet RANK_A_BIT
	compute_RANK_A : rank_func
		port map(
			CLK => CLK,
			DATA_READY => DATA_READY,
			DATA_IN => DATA_IN,
			POS => RANK_POS_A,
			RANK_BIT => RANK_A_BIT
		);
	-- vypočet RANK_B_BIT	
	compute_RANK_B : rank_func
		port map(
			CLK => CLK,
			DATA_READY => DATA_READY,
			DATA_IN => DATA_IN,
			POS => RANK_POS_B,
			RANK_BIT => RANK_B_BIT
		);
		
	-- vypočteme hodnotu příznaku
	extract: process(CLK, RANK_A_BIT, RANK_B_BIT)
		variable temp1 : std_logic_vector(1 downto 0);
		variable temp2 : std_logic_vector(1 downto 0);
		variable temp3 : std_logic_vector(1 downto 0);
		variable temp4 : std_logic_vector(1 downto 0);
		variable temp5 : std_logic_vector(1 downto 0);
		variable temp6 : std_logic_vector(1 downto 0);
		variable RANK_A : std_logic_vector(3 downto 0);
		variable RANK_B : std_logic_vector(3 downto 0);
		
	begin
		if( CLK'event and CLK = '1') then
		  if DATA_READY = '1' then
                next_valid <= DATA_IN_VALID;
                DATA_OUT_VALID <= next_valid;
		  
                -- musel jsem to vyjmout z funkce por počítaní ranku, aby stíhala pipeline
                temp1 := '0'&RANK_A_BIT(0 downto 0) + RANK_A_BIT(1 downto 1)+ RANK_A_BIT(2 downto 2); -- 2 bit adder
                temp2 := '0'&RANK_A_BIT(3 downto 3) + RANK_A_BIT(4 downto 4) + RANK_A_BIT(5 downto 5);-- 2 bit adder
                temp3 := '0'&RANK_A_BIT(6 downto 6) + RANK_A_BIT(7 downto 7) + RANK_A_BIT(8 downto 8);-- 2 bit adder
                RANK_A := "00"&temp1(1 downto 0) + temp2(1 downto 0) + temp3(1 downto 0); -- 4 bit adder
    
                temp4 := '0'&RANK_B_BIT(0 downto 0) + RANK_B_BIT(1 downto 1) + RANK_B_BIT(2 downto 2); -- 2 bit adder
                temp5 := '0'&RANK_B_BIT(3 downto 3) + RANK_B_BIT(4 downto 4) + RANK_B_BIT(5 downto 5);-- 2 bit adder
                temp6 := '0'&RANK_B_BIT(6 downto 6) + RANK_B_BIT(7 downto 7) + RANK_B_BIT(8 downto 8);-- 2 bit adder
                RANK_B := "00"&temp4(1 downto 0) + temp5(1 downto 0) + temp6(1 downto 0); -- 4 bit adder	
            
                DATA_OUT(4 downto 0) <= "01000" + RANK_A - RANK_B; -- 8 + RANK_A - RANK_B
		  end if;														-- normalizace na (0-16)																
		end if;
	end process;
	


end Behavioral;

