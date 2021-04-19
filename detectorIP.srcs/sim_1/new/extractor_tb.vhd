----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2015 11:40:30 AM
-- Design Name: 
-- Module Name: extractor_tb - Behavioral
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
use work.func_pkg.all;

entity tb_extractor is
end tb_extractor;

architecture tb of tb_extractor is

    component extractor
        port (aclk           : in std_logic;
              table_data     : in std_logic_vector (8 downto 0);
              table_addr     : in std_logic_vector (15 downto 0);
              table_we       : in std_logic;
              threshold_data : in std_logic_vector (17 downto 0);
              threshold_addr : in std_logic_vector (9 downto 0);
              threshold_we   : in std_logic;
              dsp_mode0      : in std_logic_vector (1 downto 0);
              rank0          : in std_logic_vector (7 downto 0);
              index0         : in std_logic_vector (9 downto 0);
              suma0_in       : in std_logic_vector (17 downto 0);
              data0_in       : in array_6x6x8b;
              data0_in_valid : in std_logic;
              data0_in_ready : out std_logic;
              out0_status    : out std_logic;
              out0_valid     : out std_logic;
              out0_ready     : in std_logic;
              out0_suma      : out std_logic_vector (17 downto 0);
              dsp_mode1      : in std_logic_vector (1 downto 0);
              rank1          : in std_logic_vector (7 downto 0);
              index1         : in std_logic_vector (9 downto 0);
              suma1_in       : in std_logic_vector (17 downto 0);
              data1_in       : in array_6x6x8b;
              data1_in_valid : in std_logic;
              data1_in_ready : out std_logic;
              out1_status    : out std_logic;
              out1_valid     : out std_logic;
              out1_ready     : in std_logic;
              out1_suma      : out std_logic_vector (17 downto 0));
    end component;

    signal aclk           : std_logic := '0';
    signal table_data     : std_logic_vector (8 downto 0) := (others => '0');
    signal table_addr     : std_logic_vector (15 downto 0) := (others => '0');
    signal table_we       : std_logic := '0';
    signal threshold_data : std_logic_vector (17 downto 0) := (others => '0');
    signal threshold_addr : std_logic_vector (9 downto 0) := (others => '0');
    signal threshold_we   : std_logic := '0';
    signal dsp_mode0      : std_logic_vector (1 downto 0):= (others => '0');
    signal rank0          : std_logic_vector (7 downto 0):= (others => '0');
    signal index0         : std_logic_vector (9 downto 0):= (others => '0');
    signal suma0_in       : std_logic_vector (17 downto 0):= (others => '0');
    signal data0_in       : array_6x6x8b:= (others =>(others =>(others => '0')));
    signal data0_in_valid : std_logic := '0';
    signal data0_in_ready : std_logic := '0';
    signal out0_status    : std_logic := '0';
    signal out0_valid     : std_logic := '0';
    signal out0_ready     : std_logic := '0';
    signal out0_suma      : std_logic_vector (17 downto 0):= (others => '0');
    signal dsp_mode1      : std_logic_vector (1 downto 0):= (others => '0');
    signal rank1          : std_logic_vector (7 downto 0):= (others => '0');
    signal index1         : std_logic_vector (9 downto 0):= (others => '0');
    signal suma1_in       : std_logic_vector (17 downto 0):= (others => '0');
    signal data1_in       : array_6x6x8b:= (others =>(others =>(others => '0')));
    signal data1_in_valid : std_logic := '0';
    signal data1_in_ready : std_logic := '0';
    signal out1_status    : std_logic := '0';
    signal out1_valid     : std_logic := '0';
    signal out1_ready     : std_logic := '0';
    signal out1_suma      : std_logic_vector (17 downto 0):= (others => '0');

    constant TbPeriod : time := 5 ns; -- EDIT put right period here

begin

    table_file_proc: process
        file vector_file : text open read_mode is "../table";
        variable rdline : line;
        variable data   : std_logic_vector(11 downto 0);
        variable addr   : integer;
    begin
        addr := 0;
        
        while not endfile(vector_file) loop
            readline(vector_file, rdline);
            hread(rdline, data);
            table_data <= data(8 downto 0);
            table_we <= '1';
            table_addr <= conv_std_logic_vector(addr,16);
            addr := addr +1;
            wait for TbPeriod;
        end loop;
        table_data <= (others => '0');
        table_addr <= (others => '0'); 
        table_we <= '0';
        wait;
    end process;
    
    thr_file_proc: process
        file vector_file : text open read_mode is "../treshold";
        variable rdline : line;
        variable data   : std_logic_vector(19 downto 0);
        variable addr   : integer;
    begin
        addr := 0;
        
        while not endfile(vector_file) loop
            readline(vector_file, rdline);
            hread(rdline, data);
            threshold_data <= data(17 downto 0);
            threshold_we <= '1';
            threshold_addr <= conv_std_logic_vector(addr,10);
            addr := addr +1;
            wait for TbPeriod;
        end loop;
        threshold_data <= (others => '0');
        threshold_addr <= (others => '0'); 
        threshold_we <= '0';
        wait;
    end process;

    dut : extractor
    port map (aclk           => aclk,
              table_data     => table_data,
              table_addr     => table_addr,
              table_we       => table_we,
              threshold_data => threshold_data,
              threshold_addr => threshold_addr,
              threshold_we   => threshold_we,
              dsp_mode0      => dsp_mode0,
              rank0          => rank0,
              index0         => index0,
              suma0_in       => suma0_in,
              data0_in       => data0_in,
              data0_in_valid => data0_in_valid,
              data0_in_ready => data0_in_ready,
              out0_status    => out0_status,
              out0_valid     => out0_valid,
              out0_ready     => out0_ready,
              out0_suma      => out0_suma,
              dsp_mode1      => dsp_mode1,
              rank1          => rank1,
              index1         => index1,
              suma1_in       => suma1_in,
              data1_in       => data1_in,
              data1_in_valid => data1_in_valid,
              data1_in_ready => data1_in_ready,
              out1_status    => out1_status,
              out1_valid     => out1_valid,
              out1_ready     => out1_ready,
              out1_suma      => out1_suma);

    aclk <= not aclk after TbPeriod/2;

    stimuli : process
    begin
    
        wait for TbPeriod*10;
        out0_ready <= '1';        
        wait for 3 us;       
        
        dsp_mode0 <= "01";
        rank0     <= X"01";
        index0    <= conv_std_logic_vector(1,10);  
        suma0_in  <= "00"&X"1000";
        data0_in(0)(0) <= X"01";  
        data0_in(0)(1) <= X"02"; 
        data0_in(0)(2) <= X"03"; 
        data0_in(0)(3) <= X"04"; 
        data0_in(0)(4) <= X"05";  
        data0_in(0)(5) <= X"06";  
        data0_in_valid <= '1'; 
        wait for TbPeriod;
        dsp_mode0 <= "00";
        rank0     <= X"00";
        index0    <= conv_std_logic_vector(0,10);  
        suma0_in  <= "00"&X"0000";
        data0_in <= (others =>(others =>(others => '0')));    
        data0_in_valid <= '0'; 
        
        
        wait;
    end process;

end tb;
