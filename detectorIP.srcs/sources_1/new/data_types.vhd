----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2015 05:12:46 PM
-- Design Name: 
-- Module Name: data_types - Behavioral
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

package data_types is

type array_8x8b is array (7 downto 0) of std_logic_vector(7 downto 0);
type array_8x8x8b is array (7 downto 0) of array_8x8b;

type array_3x8b is array (2 downto 0) of std_logic_vector(7 downto 0);
type array_3x3x8b is array (2 downto 0) of array_3x8b;

type array_6x8b is array (5 downto 0) of std_logic_vector(7 downto 0);
type array_6x6x8b is array (5 downto 0) of array_6x8b;

type array_5x32b is array (4 downto 0) of std_logic_vector(31 downto 0);
type array_16x16b is array (0 to 15) of std_logic_vector(15 downto 0);

type Tcontrol is
   record
      x     : std_logic_vector(12 downto 0);
      y     : std_logic_vector(12 downto 0);
      scale : std_logic_vector(4 downto 0);
      index : std_logic_vector(9 downto 0);
      pos   : std_logic_vector(4 downto 0);
      suma  : std_logic_vector(17 downto 0);
   end record;

function clogb2 (depth: in natural) return integer;

constant const_scale_addr : array_16x16b := (  
                                    conv_std_logic_vector(0,16),    conv_std_logic_vector(640,16),
                                    conv_std_logic_vector(1184,16), conv_std_logic_vector(1632,16),
                                    conv_std_logic_vector(2000,16), conv_std_logic_vector(2304,16),
                                    conv_std_logic_vector(2560,16), conv_std_logic_vector(2768,16),
                                    conv_std_logic_vector(2944,16), conv_std_logic_vector(3088,16),
                                    conv_std_logic_vector(3216,16), conv_std_logic_vector(3312,16),
                                    conv_std_logic_vector(3392,16), conv_std_logic_vector(3456,16),
                                    conv_std_logic_vector(3520,16), conv_std_logic_vector(3568,16)
                                ); 
                                
constant const_detect_width : array_16x16b :=( 
                                    conv_std_logic_vector(619,16), conv_std_logic_vector(509,16),
                                    conv_std_logic_vector(419,16), conv_std_logic_vector(344,16),
                                    conv_std_logic_vector(279,16), conv_std_logic_vector(229,16),
                                    conv_std_logic_vector(184,16), conv_std_logic_vector(149,16),
                                    conv_std_logic_vector(119,16), conv_std_logic_vector(94,16),
                                    conv_std_logic_vector(74,16),  conv_std_logic_vector(54,16),
                                    conv_std_logic_vector(39,16),  conv_std_logic_vector(29,16),
                                    conv_std_logic_vector(19,16),  conv_std_logic_vector(0,16)
                                ); 
                                                                    
constant const_scale_len : array_16x16b :=(    
                                    conv_std_logic_vector(636,16),  conv_std_logic_vector(528,16),
                                    conv_std_logic_vector(438,16),  conv_std_logic_vector(360,16),
                                    conv_std_logic_vector(300,16),  conv_std_logic_vector(246,16),
                                    conv_std_logic_vector(204,16),  conv_std_logic_vector(168,16),
                                    conv_std_logic_vector(138,16),  conv_std_logic_vector(114,16),
                                    conv_std_logic_vector(90,16),   conv_std_logic_vector(72,16),
                                    conv_std_logic_vector(60,16),   conv_std_logic_vector(48,16),
                                    conv_std_logic_vector(36,16),   conv_std_logic_vector(0,16)
                                );  

end data_types;

package body data_types is 

-------------------------------------------------------------
function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0; 
begin					
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;     
    end loop;
  	
    return ret_val;
end function;
-------------------------------------------------------------------

end data_types;