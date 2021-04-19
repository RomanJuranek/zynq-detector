----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2015 06:49:13 PM
-- Design Name: 
-- Module Name: extractor - Behavioral
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

Library UNISIM;
use UNISIM.vcomponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use work.data_types.all;		-- my data types

entity extractor is
    Generic(
        FEATURE_TYPE    : integer := 0;
        FEATURE_LIMIT   : integer := 1024
    );
    Port (
        aclk            : in std_logic;        
        
        table_data      : in std_logic_vector(8 downto 0);
        table_addr      : in std_logic_vector(15 downto 0);
        table_we        : in std_logic;
        
        threshold_data  : in std_logic_vector(17 downto 0);
        threshold_addr  : in std_logic_vector(9 downto 0);
        threshold_we    : in std_logic;
        
        dsp_mode0       : in std_logic_vector(1 downto 0);
        rank0           : in std_logic_vector(7 downto 0);
        index0          : in std_logic_vector(9 downto 0);        
        suma0_in        : in std_logic_vector(17 downto 0);
        data0_in        : in array_6x6x8b;
        data0_in_valid  : in std_logic;
        data0_in_ready  : out std_logic := '0';             
        out0_status     : out std_logic := '0';
        out0_valid      : out std_logic := '0';
        out0_ready      : in std_logic;
        out0_suma       : out std_logic_vector(17 downto 0) := (others => '0');
        
        
        dsp_mode1       : in std_logic_vector(1 downto 0);
        rank1           : in std_logic_vector(7 downto 0);
        index1          : in std_logic_vector(9 downto 0);
        suma1_in        : in std_logic_vector(17 downto 0);
        data1_in        : in array_6x6x8b;
        data1_in_valid  : in std_logic;
        data1_in_ready  : out std_logic := '0';        
        out1_status     : out std_logic := '0';
        out1_valid      : out std_logic := '0';
        out1_ready      : in std_logic;
        out1_suma       : out std_logic_vector(17 downto 0)  := (others => '0')
  
  );
end extractor;

architecture Behavioral of extractor is

component dsp is  
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
end component;

component lrd is
	port(
		CLK 		: in std_logic;
        RANK_POS_A    : in std_logic_vector(3 downto 0); -- pozice RankA (0-8)
        RANK_POS_B    : in std_logic_vector(3 downto 0);
        
        DATA_READY  : in std_logic;
        DATA_IN        : in array_3x3x8b;
        DATA_IN_VALID : in std_logic;
        
        DATA_OUT    : out std_logic_vector(4 downto 0);
        DATA_OUT_VALID : out std_logic
	);
end component;

COMPONENT lrd1024_bram
  PORT (
    clka : IN STD_LOGIC;
    regcea : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    regceb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
  );
END COMPONENT;
------------------------------------------------------------------------------------------------------------------
type TlrdTable  is array (0 to FEATURE_LIMIT*17 - 1) of std_logic_vector(8 downto 0);
type TthresholdTable is array(0 to FEATURE_LIMIT - 1) of std_logic_vector(17 downto 0);
type array_4x10b is array (3 downto 0) of std_logic_vector(9 downto 0);
type array_5x18b is array (4 downto 0) of std_logic_vector(17 downto 0);


impure function InitTableFile (RomFileName : in string) return TlrdTable is                            
    file RomFile : text open read_mode is RomFileName;                                                              
    variable rdline : line;                                                                        
    variable rom : TlrdTable;  
    variable val_12b : std_logic_vector(11 downto 0);                                                                          
                                                                                                        
begin                                                                                                   
    for i in TlrdTable'range loop                                                                        
        readline (RomFile, rdline);                                                                
        hread (rdline, val_12b);   
        rom(i) := val_12b(8 downto 0);                                                                  
    end loop;                                                                                           
    return rom;                                                                                         
end function;  

impure function InitThresholdFile (RomFileName : in string) return TthresholdTable is                            
    file RomFile : text open read_mode is RomFileName;                                                              
    variable rdline : line;                                                                        
    variable rom : TthresholdTable;      
    variable val_20b : std_logic_vector(19 downto 0);                                                                     
                                                                                                        
begin                                                                                                   
    for i in TthresholdTable'range loop                                                                        
        readline (RomFile, rdline);                                                                
        hread (rdline, val_20b);   
        rom(i) := val_20b(17 downto 0);       
                                                                            
    end loop;                                                                                           
    return rom;                                                                                         
end function;  

------------------------------------------------------------------------------------------------------------

signal index0_next   : array_4x10b;
signal index1_next   : array_4x10b;

signal suma0_next   : array_5x18b;
signal suma1_next   : array_5x18b;

signal dsp0_data    : array_3x3x8b;
signal dsp1_data    : array_3x3x8b;
signal dsp0_valid   : std_logic;
signal dsp1_valid   : std_logic;
signal rank0_next   : std_logic_vector(7 downto 0);
signal rank1_next   : std_logic_vector(7 downto 0);


signal lrd0_data    : std_logic_vector(4 downto 0);
signal lrd1_data    : std_logic_vector(4 downto 0);
signal lrd0_addr    : std_logic_vector(15 downto 0);
signal lrd1_addr    : std_logic_vector(15 downto 0);
signal lrd0_alpha   : std_logic_vector(8 downto 0);
signal lrd1_alpha   : std_logic_vector(8 downto 0);
signal lrd0_alpha_next  : std_logic_vector(8 downto 0);
signal lrd1_alpha_next  : std_logic_vector(8 downto 0);
signal lrd0_valid   : std_logic;
signal lrd1_valid   : std_logic;
signal valid0_next  : std_logic_vector(1 downto 0);
signal valid1_next  : std_logic_vector(1 downto 0);
signal thres0       : std_logic_vector(17 downto 0);
signal thres1       : std_logic_vector(17 downto 0);

signal suma0        : std_logic_vector(17 downto 0);
signal suma1        : std_logic_vector(17 downto 0);

signal thr0_addr    : std_logic_vector(9 downto 0);
signal thr1_addr    : std_logic_vector(9 downto 0);

signal lrd_bram     : TlrdTable := InitTableFile("table.mem");
signal thr_bram     : TthresholdTable := InitThresholdFile("threshold.mem");

begin


--data0_in_ready <= out0_ready;
--data1_in_ready <= out1_ready;

sync0: process (aclk)
variable suma   : std_logic_Vector(17 downto 0);
begin
    if aclk'event and aclk = '1' then
        --if out0_ready = '1' then
            rank0_next <= rank0;
            index0_next(0) <= index0;
            index0_next(1) <= index0_next(0);
            index0_next(2) <= index0_next(1);
            index0_next(3) <= index0_next(2);
            
            suma0_next(0) <= suma0_in;
            suma0_next(1) <= suma0_next(0);
            suma0_next(2) <= suma0_next(1);
            suma0_next(3) <= suma0_next(2);
            suma0_next(4) <= suma0_next(3);
            
            valid0_next(0) <= lrd0_valid;
            valid0_next(1) <= valid0_next(0);
            out0_valid <= valid0_next(1);
            
            lrd0_alpha_next <= lrd0_alpha;
            
            suma0 <= suma0_next(3)  + "111111111100000000";
            
            suma := suma0 + lrd0_alpha_next;
            out0_suma <= suma;
            
            if suma >= thres0 then
                out0_status <= '1';
            else
                out0_status <= '0';
            end if;
        --end if;
    end if;
end process;

sync1: process (aclk)
variable suma : std_logic_vector(17 downto 0);
begin
    if aclk'event and aclk = '1' then
        --if out1_ready = '1' then
            rank1_next <= rank1;
            index1_next(0) <= index1;
            index1_next(1) <= index1_next(0);
            index1_next(2) <= index1_next(1);
            index1_next(3) <= index1_next(2);
            
            suma1_next(0) <= suma1_in;
            suma1_next(1) <= suma1_next(0);
            suma1_next(2) <= suma1_next(1);
            suma1_next(3) <= suma1_next(2);
            suma1_next(4) <= suma1_next(3);
            
            valid1_next(0) <= lrd1_valid;
            valid1_next(1) <= valid1_next(0);
            out1_valid <= valid1_next(1);
            
            lrd1_alpha_next <= lrd1_alpha;
            
            suma1 <= suma1_next(3) + "111111111100000000";
                       
            suma := suma1 + lrd1_alpha_next;      
            out1_suma <= suma;
            
            if suma >= thres1 then
                out1_status <= '1';
            else
                out1_status <= '0';
            end if;
        --end if;
    end if;
end process;


dsp0_map: dsp Port map ( 
        aclk            => aclk,        
        dsp_mode        => dsp_mode0,           
        data_in         => data0_in,
        data_in_valid   => data0_in_valid,
        data_in_ready   => data0_in_ready,
        data_out        => dsp0_data,
        data_out_valid  => dsp0_valid,
        data_out_ready  => '1'
    );
    
dsp1_map: dsp Port map ( 
        aclk            => aclk,            
        dsp_mode        => dsp_mode1,                
        data_in         => data1_in,
        data_in_valid   => data1_in_valid,
        data_in_ready   => data1_in_ready,
        data_out        => dsp1_data,
        data_out_valid  => dsp1_valid,
        data_out_ready  => '1'   
    );
    
lrd0_map: lrd port map(
        CLK         => aclk,
        RANK_POS_A  => rank0_next(7 downto 4),
        RANK_POS_B  => rank0_next(3 downto 0),
        
        DATA_READY  => '1',
        DATA_IN     => dsp0_data,
        DATA_IN_VALID=> dsp0_valid,        
        DATA_OUT    => lrd0_data,
        DATA_OUT_VALID=> lrd0_valid
    );
    
lrd1_map: lrd port map(
        CLK         => aclk,
        RANK_POS_A  => rank1_next(7 downto 4),
        RANK_POS_B  => rank1_next(3 downto 0),
        
        DATA_READY  => '1',
        DATA_IN     => dsp1_data,     
        DATA_IN_VALID=> dsp1_valid,   
        DATA_OUT    => lrd1_data,
        DATA_OUT_VALID=> lrd1_valid
    );


lrd0_addr <= "00"&index0_next(2)&"0000" + index0_next(2) + lrd0_data when table_we = '0' else table_addr;
lrd1_addr <= "00"&index1_next(2)&"0000" + index1_next(2) + lrd1_data;

----------------------------------------------------------------------------
gen_bram0: if FEATURE_LIMIT /= 1024 generate
    lrdBRAM_0: process (aclk)
    begin
        if aclk'event and aclk = '1' then
            if table_we = '1' then
                lrd_bram(conv_integer(lrd0_addr)) <= table_data;
            else
                --if out0_ready = '1' then
                    lrd0_alpha <= lrd_bram(conv_integer(lrd0_addr));
                --end if;
            end if;   
        end if;
    end process;
    
    lrdBRAM_1: process (aclk)
    begin
        if aclk'event and aclk = '1' then
            --if out1_ready = '1' then
                lrd1_alpha <= lrd_bram(conv_integer(lrd1_addr));
            --end if;
        end if;
    end process;
end generate;
-----------------------------------------------------------------------------
gen_bram1: if FEATURE_LIMIT = 1024 generate
type array_5x9b is array (4 downto 0) of std_logic_vector(8 downto 0);
type t_file_name  is array(0 to 4) of string(1 to 10);
constant tableFiles     : t_file_name  := ("table0.mem","table1.mem","table2.mem","table3.mem","table4.mem");
signal ram_we           : std_logic_vector(4 downto 0);
signal lrd0_addr_next   : std_logic_vector(2 downto 0);
signal lrd1_addr_next   : std_logic_vector(2 downto 0);
signal ram_out_A        : array_5x9b;
signal ram_out_B        : array_5x9b;
signal ram_out_A_next   : array_5x9b;
signal ram_out_B_next   : array_5x9b;
signal out0_ready_next  : std_logic;
signal out1_ready_next  : std_logic;
begin

    we_proc: process (table_we, table_addr)
    begin    
        ram_we <= "00000";        
        if table_we = '1' then
            ram_we(conv_integer(table_addr(14 downto 12))) <= '1';
        end if;
    end process;

    sync_addr: process(aclk)
    begin
        if aclk'event and aclk = '1' then
            ram_out_A_next <= ram_out_A;
            ram_out_B_next <= ram_out_B;
            
            out0_ready_next <= out0_ready;
            out1_ready_next <= out1_ready;
            
            --if out0_ready = '1' then
                lrd0_addr_next <= lrd0_addr(14 downto 12);
            
            --end if;
            --if out1_ready = '1' then
                lrd1_addr_next <= lrd1_addr(14 downto 12);
            
            --end if;   
        end if;
    end process;

    out0_lrd: process(out0_ready_next,lrd0_addr_next,ram_out_A,ram_out_A_next)
    begin
        --if out0_ready_next = '1' then
            lrd0_alpha <= ram_out_A(conv_integer(lrd0_addr_next));         
        --else
        --    lrd0_alpha <= ram_out_A_next(conv_integer(lrd0_addr_next));   
        --end if;    
    end process;

    out1_lrd: process(out1_ready_next,lrd1_addr_next,ram_out_B,ram_out_B_next)
    begin
        --if out1_ready_next = '1' then
            lrd1_alpha <= ram_out_B(conv_integer(lrd1_addr_next));         
        --else
        --    lrd1_alpha <= ram_out_B_next(conv_integer(lrd1_addr_next));   
        --end if;    
    end process;

    bram_gen: for y in 0 to 4 generate
        BRAM_TDP_MACRO_instc : BRAM_TDP_MACRO
           generic map (
              BRAM_SIZE => "36Kb",
              DEVICE => "7SERIES",
              READ_WIDTH_A => 9,
              READ_WIDTH_B => 9,
              WRITE_WIDTH_A => 9,
              WRITE_WIDTH_B => 9,
              SIM_COLLISION_CHECK => "NONE",
              DOA_REG => 0,
              DOB_REG => 0, 
              WRITE_MODE_A => "NO_CHANGE",
              WRITE_MODE_B => "NO_CHANGE",
              INIT_FILE => tableFiles(y)
              )
           port map (
              DOA => ram_out_A(y),       -- Output port-A data, width defined by READ_WIDTH_A parameter
              DOB => ram_out_B(y),       -- Output port-B data, width defined by READ_WIDTH_B parameter
              ADDRA => lrd0_addr(11 downto 0),   -- Input port-A address, width defined by Port A depth
              ADDRB => lrd1_addr(11 downto 0),   -- Input port-B address, width defined by Port B depth
              CLKA => aclk,     -- 1-bit input port-A clock
              CLKB => aclk,     -- 1-bit input port-B clock
              DIA => table_data,       -- Input port-A data, width defined by WRITE_WIDTH_A parameter
              DIB => (others => '0'),       -- Input port-B data, width defined by WRITE_WIDTH_B parameter
              ENA => '1',       -- 1-bit input port-A enable
              ENB => '1',       -- 1-bit input port-B enable
              REGCEA => '0', -- 1-bit input port-A output register enable
              REGCEB => '0', -- 1-bit input port-B output register enable
              RSTA => '0',     -- 1-bit input port-A reset
              RSTB => '0',     -- 1-bit input port-B reset
              WEA(0) => ram_we(y),       -- Input port-A write enable, width defined by Port A depth
              WEB(0) => '0'       -- Input port-B write enable, width defined by Port B depth
           );
    end generate bram_gen;



--lrd1024_bram_map : lrd1024_bram
--  PORT MAP (
--    clka => aclk,
--    regcea => out0_ready,
--    wea(0) => table_we,
--    addra => lrd0_addr(14 downto 0),
--    dina => table_data,
--    douta => lrd0_alpha,
--    clkb => aclk,
--    regceb => out1_ready,
--    web(0) => '0',
--    addrb => lrd1_addr(14 downto 0),
--    dinb => (others => '0'),
--    doutb => lrd1_alpha
--  );



end generate gen_bram1;
--------------------------------------------------------------------------------

thr0_addr <= threshold_addr when threshold_we = '1' else index0_next(3);
thr1_addr <= index1_next(3);

thrBRAM_0: process (aclk)
begin
    if aclk'event and aclk = '1' then
        if threshold_we = '1' then
            thr_bram(conv_integer(thr0_addr)) <= threshold_data;
        else
            --if out0_ready = '1' then
                thres0 <= thr_bram(conv_integer(thr0_addr));
            --end if;
        end if;   
    end if;
end process;

thrBRAM_1: process (aclk)
begin
    if aclk'event and aclk = '1' then
        --if out1_ready = '1' then
            thres1 <= thr_bram(conv_integer(thr1_addr));  
        --end if;
    end if;
end process;

end Behavioral;
