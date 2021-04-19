----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2015 07:52:00 PM
-- Design Name: 
-- Module Name: memory_tb - Behavioral
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
use work.func_pkg.all;

entity tb_memory is
end tb_memory;

architecture tb of tb_memory is

    component memory
        port (aclk            : in std_logic;
              resetn          : in std_logic;
              scale_addr_data : in std_logic_vector (15 downto 0);
              scale_addr_addr : in std_logic_vector (4 downto 0);
              scale_addr_we   : in std_logic;
              scale_len_data  : in std_logic_vector (15 downto 0) := (others => '0');
              scale_len_addr  : in std_logic_vector (4 downto 0) := (others => '0');
              scale_len_we    : in std_logic;
              image_width     : in std_logic_vector (12 downto 0);
              image_height    : in std_logic_vector (12 downto 0);
              window_height   : in std_logic_vector (12 downto 0);
              s_axis_tdata    : in std_logic_vector (31 downto 0);
              s_axis_tvalid   : in std_logic;
              s_axis_tready   : out std_logic;
              s_axis_tuser    : in std_logic;
              s_axis_tlast    : in std_logic;
              next_line       : in std_logic;
              new_image       : in std_logic;
              input_line      : out std_logic_vector (12 downto 0);
              addr0_x         : in std_logic_vector (12 downto 0);
              addr0_y         : in std_logic_vector (12 downto 0);
              addr0_scale     : in std_logic_vector (4 downto 0);
              addr0_valid     : in std_logic;
              addr0_ready     : out std_logic;
              data0           : out array_6x6x8b;
              data0_valid     : out std_logic;
              data0_ready     : in std_logic;
              addr1_x         : in std_logic_vector (12 downto 0);
              addr1_y         : in std_logic_vector (12 downto 0);
              addr1_scale     : in std_logic_vector (4 downto 0);
              addr1_valid     : in std_logic;
              addr1_ready     : out std_logic;
              data1           : out array_6x6x8b;
              data1_valid     : out std_logic;
              data1_ready     : in std_logic);
    end component;


    signal aclk            : std_logic := '0';
    signal resetn          : std_logic := '0';
    signal scale_addr_data : std_logic_vector (15 downto 0):= (others => '0');
    signal scale_addr_addr : std_logic_vector (4 downto 0):= (others => '0');
    signal scale_addr_we   : std_logic := '0';
    signal scale_len_data  : std_logic_vector (15 downto 0) := (others => '0');
    signal scale_len_addr  : std_logic_vector (4 downto 0) := (others => '0');
    signal scale_len_we    : std_logic := '0';
    signal image_width     : std_logic_vector (12 downto 0):= (others => '0');
    signal image_height    : std_logic_vector (12 downto 0):= (others => '0');
    signal window_height   : std_logic_vector (12 downto 0):= conv_std_logic_vector(22,13);
    signal s_axis_tdata    : std_logic_vector (31 downto 0):= (others => '0');
    signal s_axis_tvalid   : std_logic := '0';
    signal s_axis_tready   : std_logic := '0';
    signal s_axis_tuser    : std_logic := '0';
    signal s_axis_tlast    : std_logic := '0';
    signal next_line       : std_logic := '0';
    signal new_image       : std_logic := '0';
    signal input_line      : std_logic_vector (12 downto 0):= (others => '0');
    signal addr0_x         : std_logic_vector (12 downto 0):= (others => '0');
    signal addr0_y         : std_logic_vector (12 downto 0):= (others => '0');
    signal addr0_scale     : std_logic_vector (4 downto 0):= (others => '0');
    signal addr0_valid     : std_logic := '0';
    signal addr0_ready     : std_logic := '0';
    signal data0           : array_6x6x8b;
    signal data0_valid     : std_logic := '0';
    signal data0_ready     : std_logic := '1';
    signal addr1_x         : std_logic_vector (12 downto 0):= (others => '0');
    signal addr1_y         : std_logic_vector (12 downto 0):= (others => '0');
    signal addr1_scale     : std_logic_vector (4 downto 0):= (others => '0');
    signal addr1_valid     : std_logic := '0';
    signal addr1_ready     : std_logic := '0';
    signal data1           : array_6x6x8b;
    signal data1_valid     : std_logic := '0';
    signal data1_ready     : std_logic := '1';


begin

    dut : memory
    port map (aclk            => aclk,
              resetn          => resetn,
              scale_addr_data => scale_addr_data,
              scale_addr_addr => scale_addr_addr,
              scale_addr_we   => scale_addr_we,
              scale_len_data  => scale_len_data,
              scale_len_addr  => scale_len_addr,
              scale_len_we    => scale_len_we,
              image_width     => image_width,
              image_height    => image_height,
              window_height   => window_height,
              s_axis_tdata    => s_axis_tdata,
              s_axis_tvalid   => s_axis_tvalid,
              s_axis_tready   => s_axis_tready,
              s_axis_tuser    => s_axis_tuser,
              s_axis_tlast    => s_axis_tlast,
              next_line       => next_line,
              new_image       => new_image,
              input_line      => input_line,
              addr0_x         => addr0_x,
              addr0_y         => addr0_y,
              addr0_scale     => addr0_scale,
              addr0_valid     => addr0_valid,
              addr0_ready     => addr0_ready,
              data0           => data0,
              data0_valid     => data0_valid,
              data0_ready     => data0_ready,
              addr1_x         => addr1_x,
              addr1_y         => addr1_y,
              addr1_scale     => addr1_scale,
              addr1_valid     => addr1_valid,
              addr1_ready     => addr1_ready,
              data1           => data1,
              data1_valid     => data1_valid,
              data1_ready     => data1_ready);

    aclk <= not aclk after Clk_Period/2;


    init : process
    begin
        wait for Clk_Period*5;        
        resetn <= '1';
        wait for Clk_Period*5;
        
        wait_for(s_axis_tready ,'1');
        
        for y in 0 to 255 loop
            for x in 0 to 31 loop
                
                s_axis_tdata <= conv_std_logic_vector(y+4*x+3,8)&conv_std_logic_vector(y+4*x+2,8)&conv_std_logic_vector(y+4*x+1,8)&conv_std_logic_vector(y+4*x,8);
                s_axis_tvalid<= '1';
                if y = 0 and x = 0 then
                    s_axis_tuser <= '1';
                else
                    s_axis_tuser <= '0';
                end if;
                if x = 31 then
                    s_axis_tlast <= '1';
                else
                    s_axis_tlast <='0';
                end if;
                wait_for(s_axis_tready,'1');
                wait for Clk_Period;                 
            end loop;
        end loop;
        wait;
    end process;
    
    data : process
        begin
            wait for Clk_Period*0.55;        
            wait_for(addr0_ready ,'1');
            
            for y in 0 to 255 loop
                for x in 0 to 31 loop
                    addr0_x <= conv_std_logic_vector(x,13);
                    addr0_y <= conv_std_logic_vector(y,13);
                    addr0_valid <= '1';
                    wait_for(addr0_ready,'1');
                    wait for Clk_Period;                 
                end loop;
            end loop;
            
            addr0_valid <= '0';
            wait;
        end process;

end tb;

