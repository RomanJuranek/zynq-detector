
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.data_types.all;		-- my data types

entity rank_func is
	port(
			CLK			: in std_logic;
			DATA_READY  : in std_logic;
			DATA_IN		: in array_3x3x8b;
			POS			: in std_logic_vector(3 downto 0);
			
			RANK_BIT		: out std_logic_vector(8 downto 0)
		);
end rank_func;

architecture Behavioral of rank_func is
	
signal val 	: std_logic_vector(7 downto 0);
signal rank	: std_logic_vector(8 downto 0);
	
begin

SYN_PROC: process (DATA_IN,POS,CLK)
begin
	if( CLK'event and CLK = '1') then
        if DATA_READY = '1' then
		  RANK_BIT <= rank;
        end if;
	end if;
end process;
	
	
WITH POS  SELECT	-- 6 z 1
    val <=	DATA_IN(0)(0) WHEN "0000",
            DATA_IN(0)(1) WHEN "0001",
            DATA_IN(0)(2) WHEN "0010",
            DATA_IN(1)(0) WHEN "0011",
            DATA_IN(1)(1) WHEN "0100",
            DATA_IN(1)(2) WHEN "0101",
            DATA_IN(2)(0) WHEN "0110",
            DATA_IN(2)(1) WHEN "0111",
            DATA_IN(2)(2) WHEN "1000",
            "00000000"      WHEN OTHERS;

rank(0) <= '1' when val > DATA_IN(0)(0) else '0';
rank(1) <= '1' when val > DATA_IN(0)(1) else '0';
rank(2) <= '1' when val > DATA_IN(0)(2) else '0';
rank(3) <= '1' when val > DATA_IN(1)(0) else '0';
rank(4) <= '1' when val > DATA_IN(1)(1) else '0';
rank(5) <= '1' when val > DATA_IN(1)(2) else '0';
rank(6) <= '1' when val > DATA_IN(2)(0) else '0';
rank(7) <= '1' when val > DATA_IN(2)(1) else '0';
rank(8) <= '1' when val > DATA_IN(2)(2) else '0';

end Behavioral;
