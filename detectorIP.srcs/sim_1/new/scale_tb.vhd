----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2015 06:55:58 PM
-- Design Name: 
-- Module Name: scale_tb - Behavioral
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

entity scale_tb is
--  Port ( );
end scale_tb;

architecture Behavioral of scale_tb is
component detector
        Generic (        
            S_AXI_DATA_WIDTH    : integer    := 32;
            S_AXI_ADDR_WIDTH    : integer    := 16;
            
            MAX_WIDTH     : integer  := 1024;
            MAX_HEIGTH    : integer  := 1024;
            FEATURE_LIMIT: integer  := 1024
        );
        port (aclk          : in std_logic;
              resetn        : in std_logic;
              s_axi_awaddr  : in std_logic_vector (s_axi_addr_width-1 downto 0);
              s_axi_awprot  : in std_logic_vector (2 downto 0);
              s_axi_awvalid : in std_logic;
              s_axi_awready : out std_logic;
              s_axi_wdata   : in std_logic_vector (s_axi_data_width-1 downto 0);
              s_axi_wstrb   : in std_logic_vector ((s_axi_data_width/8)-1 downto 0);
              s_axi_wvalid  : in std_logic;
              s_axi_wready  : out std_logic;
              s_axi_bresp   : out std_logic_vector (1 downto 0);
              s_axi_bvalid  : out std_logic;
              s_axi_bready  : in std_logic;
              s_axi_araddr  : in std_logic_vector (s_axi_addr_width-1 downto 0);
              s_axi_arprot  : in std_logic_vector (2 downto 0);
              s_axi_arvalid : in std_logic;
              s_axi_arready : out std_logic;
              s_axi_rdata   : out std_logic_vector (s_axi_data_width-1 downto 0);
              s_axi_rresp   : out std_logic_vector (1 downto 0);
              s_axi_rvalid  : out std_logic;
              s_axi_rready  : in std_logic;
              s_axis_tdata  : in std_logic_vector (31 downto 0);
              s_axis_tvalid : in std_logic;
              s_axis_tready : out std_logic;
              s_axis_tuser  : in std_logic;
              s_axis_tlast  : in std_logic;
              m_axis_tdata  : out std_logic_vector (31 downto 0);
              m_axis_tvalid : out std_logic;
              m_axis_tready : in std_logic;
              m_axis_tlast  : out std_logic);
    end component;

    signal aclk          : std_logic := '0';
    signal resetn        : std_logic := '0';
    signal s_axi_awaddr  : std_logic_vector (s_axi_addr_width-1 downto 0) := (others => '0');
    signal s_axi_awprot  : std_logic_vector (2 downto 0) := (others => '0');
    signal s_axi_awvalid : std_logic_vector(0 downto 0) := "0";
    signal s_axi_awready : std_logic_vector(0 downto 0) := "0";
    signal s_axi_wdata   : std_logic_vector (s_axi_data_width-1 downto 0) := (others => '0');
    signal s_axi_wstrb   : std_logic_vector ((s_axi_data_width/8)-1 downto 0) := (others => '0');
    signal s_axi_wvalid  : std_logic_vector(0 downto 0) := "0";
    signal s_axi_wready  : std_logic_vector(0 downto 0) := "0";
    signal s_axi_bresp   : std_logic_vector (1 downto 0) := (others => '0');
    signal s_axi_bvalid  : std_logic_vector(0 downto 0) := "0";
    signal s_axi_bready  : std_logic_vector(0 downto 0) := "0";
    signal s_axi_araddr  : std_logic_vector (s_axi_addr_width-1 downto 0) := (others => '0');
    signal s_axi_arprot  : std_logic_vector (2 downto 0) := (others => '0');
    signal s_axi_arvalid : std_logic_vector(0 downto 0) := "0";
    signal s_axi_arready : std_logic_vector(0 downto 0) := "0";
    signal s_axi_rdata   : std_logic_vector (s_axi_data_width-1 downto 0) := (others => '0');
    signal s_axi_rresp   : std_logic_vector (1 downto 0) := (others => '0');
    signal s_axi_rvalid  : std_logic_vector(0 downto 0) := "0";
    signal s_axi_rready  : std_logic_vector(0 downto 0) := "0";
    signal s_axis_tdata  : std_logic_vector (31 downto 0) := (others => '0');
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tready : std_logic := '0';
    signal s_axis_tuser  : std_logic := '0';
    signal s_axis_tlast  : std_logic := '0';
    signal m_axis_tdata  : std_logic_vector (31 downto 0) := (others => '0');
    signal m_axis_tvalid : std_logic := '0';
    signal m_axis_tready : std_logic := '0';
    signal m_axis_tlast  : std_logic := '0';


begin

    dut : detector
    generic map(
            S_AXI_DATA_WIDTH    => S_AXI_DATA_WIDTH,
            S_AXI_ADDR_WIDTH    => S_AXI_ADDR_WIDTH
    )
    port map (aclk          => aclk,
              resetn        => resetn,
              s_axi_awaddr  => s_axi_awaddr,
              s_axi_awprot  => s_axi_awprot,
              s_axi_awvalid => s_axi_awvalid(0),
              s_axi_awready => s_axi_awready(0),
              s_axi_wdata   => s_axi_wdata,
              s_axi_wstrb   => s_axi_wstrb,
              s_axi_wvalid  => s_axi_wvalid(0),
              s_axi_wready  => s_axi_wready(0),
              s_axi_bresp   => s_axi_bresp,
              s_axi_bvalid  => s_axi_bvalid(0),
              s_axi_bready  => s_axi_bready(0),
              s_axi_araddr  => s_axi_araddr,
              s_axi_arprot  => s_axi_arprot,
              s_axi_arvalid => s_axi_arvalid(0),
              s_axi_arready => s_axi_arready(0),
              s_axi_rdata   => s_axi_rdata,
              s_axi_rresp   => s_axi_rresp,
              s_axi_rvalid  => s_axi_rvalid(0),
              s_axi_rready  => s_axi_rready(0),
              s_axis_tdata  => s_axis_tdata,
              s_axis_tvalid => s_axis_tvalid,
              s_axis_tready => s_axis_tready,
              s_axis_tuser  => s_axis_tuser,
              s_axis_tlast  => s_axis_tlast,
              m_axis_tdata  => m_axis_tdata,
              m_axis_tvalid => m_axis_tvalid,
              m_axis_tready => m_axis_tready,
              m_axis_tlast  => m_axis_tlast);

    aclk <= not aclk after Clk_Period/2;

    init: process
        file table_file : text open read_mode is "../table";
        file thres_file : text open read_mode is "../treshold";
        file instr_file : text open read_mode is "../instruct";
        file scale_file : text open read_mode is "../scale";
        file detect_file: text open read_mode is "../detect";    
        file settings_file: text open read_mode is "../settings";     
        variable rdline : line;
        variable table0 : std_logic_vector(11 downto 0);
        variable table1 : std_logic_vector(11 downto 0);
        variable thres  : std_logic_vector(19 downto 0);
        variable data   : std_logic_vector(31 downto 0);  
        variable addr_full : std_logic_vector(31 downto 0);     
        variable addr   : std_logic_vector(s_axi_addr_width-1 downto 0);
    begin
        
        wait for Clk_Period*20;
        
        while not endfile(settings_file) loop
            readline(settings_file, rdline);
            hread(rdline, addr_full);
            hread(rdline, data);
            addr := addr_full(s_axi_addr_width-1 downto 0);
            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
            --addr := addr +"100";
        end loop;
        
        
        
--        addr := "00"&X"0010"; 
--        data := X"00000000";
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);                
--        wait for Clk_Period*20;
        
--        addr := conv_std_logic_vector(128*1024,s_axi_addr_width); 
--        for i in 0 to 31 loop  
--            data := X"00100010";
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
--        wait for Clk_Period*20;
        
--        addr := conv_std_logic_vector(4*1024,s_axi_addr_width);        
--        for i in 0 to 31 loop  
--            data := X"00001000" ;
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
        
--        addr := conv_std_logic_vector(8*1024,s_axi_addr_width);        
--        while not endfile(instr_file) loop
--            readline(instr_file, rdline);
--            hread(rdline, data);
--            data := X"00000000";
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
        
--        addr := conv_std_logic_vector(12*1024,s_axi_addr_width);        
--        while not endfile(scale_file) loop
--            readline(scale_file, rdline);
--            hread(rdline, data);
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
        
--        addr := conv_std_logic_vector(16*1024,s_axi_addr_width);        
--        while not endfile(detect_file) loop
--            readline(detect_file, rdline);
--            hread(rdline, data);
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
        
--        addr := conv_std_logic_vector(256,s_axi_addr_width);    -- scale len       
--        data := conv_std_logic_vector(522,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
--        addr := conv_std_logic_vector(260,s_axi_addr_width);    -- scale len       
--        data := conv_std_logic_vector(438,32);  -- 438
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);

--        addr := conv_std_logic_vector(264,s_axi_addr_width);    -- scale len       
--        data := conv_std_logic_vector(366,32);  -- 366
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
        
--        addr := conv_std_logic_vector(128,s_axi_addr_width);    -- scale addr      
--        data := conv_std_logic_vector(0,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
--        addr := conv_std_logic_vector(132,s_axi_addr_width);    -- scale addr       
--        data := conv_std_logic_vector(528,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);

--        addr := conv_std_logic_vector(136,s_axi_addr_width);    -- scale addr       
--        data := conv_std_logic_vector(528+448,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
                        
        
--        addr := conv_std_logic_vector(384,s_axi_addr_width);    -- detect width       
--        data := conv_std_logic_vector(520-70,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
--        addr := conv_std_logic_vector(388,s_axi_addr_width);    -- detect width       
--        data := conv_std_logic_vector(438-70,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
        
--        addr := conv_std_logic_vector(392,s_axi_addr_width);    -- detect width       
--        data := conv_std_logic_vector(366-70,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
        
--        addr := conv_std_logic_vector(396,s_axi_addr_width);    -- detect width       
--        data := conv_std_logic_vector(0,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);

        
--        addr := conv_std_logic_vector(28,s_axi_addr_width);    -- window height       
--        data := conv_std_logic_vector(13,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
                
--        addr := conv_std_logic_vector(24,s_axi_addr_width);    -- image height     
--        data := conv_std_logic_vector(214,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
                
        
                        
--        wait for Clk_Period*20;        
        
        
        wait for Clk_Period*20;
        addr := "00"&X"0010"; 
        data := X"00000001";
        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);                
        wait for Clk_Period*20;
        
        wait;
    end process;


    stimuli : process
        file foto_file : text;-- open read_mode is "../foto";
        variable rdline : line;
        variable data   : std_logic_vector(31 downto 0);   
        variable packet : std_logic_vector(7 downto 0); 
        variable addr   : std_logic_vector(31 downto 0);  
        variable line_id: std_logic_vector(31 downto 0);  
        begin
            wait for Clk_Period*5;
            resetn <= '1';
            wait for Clk_Period*5;
                    
            m_axis_tready <= '1';
            
            
            for i in 0 to 5 loop
                wait_for(s_axis_tready ,'1');
                addr := conv_std_logic_vector(0,32); 
                line_id  := conv_std_logic_vector(0,32); 
                file_open(foto_file,"../foto",READ_MODE); 
                while not endfile(foto_file) loop
                    readline(foto_file, rdline);
                    hread(rdline, data);
                    s_axis_tdata <= data;
                    s_axis_tvalid <= '1';
                    if addr = X"00000000" and line_id = X"00000000" then
                        s_axis_tuser <= '1';
                    else
                        s_axis_tuser <= '0';
                    end if;
                    
                    if addr = X"00000063" then
                        addr := conv_std_logic_vector(0,32);
                        line_id := line_id + '1';
                        s_axis_tlast <= '1';
                    else
                        addr := addr + '1';
                        s_axis_tlast <= '0';
                    end if;
                    wait_for(s_axis_tready ,'1');
                    wait for Clk_Period;
                    
                end loop;
                s_axis_tlast <= '0';
                s_axis_tvalid <= '0';
                file_close(foto_file);
                
                wait for Clk_Period*1000;
            end loop;
        
        
            
        wait for Clk_Period*1;
  
        
        
        s_axis_tvalid <= '0';
     
        wait;
    end process;


end Behavioral;
