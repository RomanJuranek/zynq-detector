----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2015 09:18:14 PM
-- Design Name: 
-- Module Name: detector_tb - Behavioral
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

entity tb_detector2 is
end tb_detector2;

architecture tb of tb_detector2 is

    component detector
        Generic (        
            S_AXI_DATA_WIDTH    : integer    := 32;
            S_AXI_ADDR_WIDTH    : integer    := 16;
            
            MAX_WIDTH     : integer  := 1024;
            MAX_HEIGTH    : integer  := 1536;
            FEATURE_LIMIT: integer  := 1024;    
            DETECT_STEP_X : integer  := 1;
            DETECT_STEP_Y : integer  := 1 
            
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
              m_axis_tdata  : out std_logic_vector (63 downto 0);
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
    signal m_axis_tdata  : std_logic_vector (63 downto 0) := (others => '0');
    signal m_axis_tvalid : std_logic := '0';
    signal m_axis_tready : std_logic := '0';
    signal m_axis_tlast  : std_logic := '0';


begin

    dut : detector
    generic map(
            S_AXI_DATA_WIDTH    => S_AXI_DATA_WIDTH,
            S_AXI_ADDR_WIDTH    => S_AXI_ADDR_WIDTH,
            DETECT_STEP_X       => 1,
            DETECT_STEP_Y       => 1
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
        type T_array is array(0 to 15) of std_logic_vector(31 downto 0);
        
        file table_file : text open read_mode is "../table";
        file thres_file : text open read_mode is "../treshold";
        file instr_file : text open read_mode is "../instruct";
        file scale_file : text open read_mode is "../scale";     
        file detect_file: text open read_mode is "../detect";
             
        variable rdline : line;
        variable table0 : std_logic_vector(11 downto 0);
        variable table1 : std_logic_vector(11 downto 0);
        variable thres  : std_logic_vector(19 downto 0);
        variable data   : std_logic_vector(31 downto 0);
        variable addr   : std_logic_vector(s_axi_addr_width-1 downto 0);
        
        constant scale_addr : T_array := (  conv_std_logic_vector(0,32),    conv_std_logic_vector(640,32),
                                            conv_std_logic_vector(1184,32), conv_std_logic_vector(1632,32),
                                            conv_std_logic_vector(2000,32), conv_std_logic_vector(2304,32),
                                            conv_std_logic_vector(2560,32), conv_std_logic_vector(2768,32),
                                            conv_std_logic_vector(2944,32), conv_std_logic_vector(3088,32),
                                            conv_std_logic_vector(3216,32), conv_std_logic_vector(3312,32),
                                            conv_std_logic_vector(3392,32), conv_std_logic_vector(3456,32),
                                            conv_std_logic_vector(3520,32), conv_std_logic_vector(3568,32)); 
                                            
        constant detect_width : T_array :=( conv_std_logic_vector(619,32), conv_std_logic_vector(509,32),
                                            conv_std_logic_vector(419,32), conv_std_logic_vector(344,32),
                                            conv_std_logic_vector(279,32), conv_std_logic_vector(229,32),
                                            conv_std_logic_vector(184,32), conv_std_logic_vector(149,32),
                                            conv_std_logic_vector(119,32), conv_std_logic_vector(94,32),
                                            conv_std_logic_vector(74,32),  conv_std_logic_vector(54,32),
                                            conv_std_logic_vector(39,32),  conv_std_logic_vector(29,32),
                                            conv_std_logic_vector(19,32),  conv_std_logic_vector(0,32)); 
                                            
        constant scale_len : T_array :=(    conv_std_logic_vector(636,32), conv_std_logic_vector(528,32),
                                            conv_std_logic_vector(438,32), conv_std_logic_vector(360,32),
                                            conv_std_logic_vector(300,32), conv_std_logic_vector(246,32),
                                            conv_std_logic_vector(204,32), conv_std_logic_vector(168,32),
                                            conv_std_logic_vector(138,32), conv_std_logic_vector(114,32),
                                            conv_std_logic_vector(90,32),  conv_std_logic_vector(72,32),
                                            conv_std_logic_vector(60,32),  conv_std_logic_vector(48,32),
                                            conv_std_logic_vector(36,32),  conv_std_logic_vector(0,32));                                     
    begin
        
        wait for Clk_Period*20;
        addr := "00"&X"0010"; 
        data := X"00000000";
        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);                
        wait for Clk_Period*20;
        
--        addr := conv_std_logic_vector(128*1024,s_axi_addr_width); 
--        while not endfile(table_file) loop
--            readline(table_file, rdline);
--            hread(rdline, table0);
--            readline(table_file, rdline);
--            hread(rdline, table1);
            
--            data := "0000"&table1&"0000"&table0;
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
--        wait for Clk_Period*20;
        
--        addr := conv_std_logic_vector(4*1024,s_axi_addr_width);        
--        while not endfile(thres_file) loop
--            readline(thres_file, rdline);
--            hread(rdline, thres);
--            data := X"000" & thres;
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--            addr := addr +"100";
--        end loop;
        
--        addr := conv_std_logic_vector(8*1024,s_axi_addr_width);        
--        while not endfile(instr_file) loop
--            readline(instr_file, rdline);
--            hread(rdline, data);
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
        
--        for i in 0 to 15 loop
--            addr := conv_std_logic_vector(256+ i*4,s_axi_addr_width);    -- scale len       
--            data := scale_len(i);
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--        end loop;
        
--        for i in 0 to 15 loop
--            addr := conv_std_logic_vector(128 + i*4,s_axi_addr_width);    -- scale addr      
--            data := scale_addr(i);
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--        end loop; 
                              
--        for i in 0 to 15 loop
--            addr := conv_std_logic_vector(384+ i*4,s_axi_addr_width);    -- detect width       
--            data := detect_width(i);
--            AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
--        end loop;        
        
--        addr := conv_std_logic_vector(28,s_axi_addr_width);    -- window height       
--        data := conv_std_logic_vector(24,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
                
--        addr := conv_std_logic_vector(24,s_axi_addr_width);    -- image height     
--        data := conv_std_logic_vector(479,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
                
--        addr := conv_std_logic_vector(36,s_axi_addr_width);    -- final threshosd     
--        --data := X"0001fc00";
--        data := X"0001fc00";
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
        
--        addr := conv_std_logic_vector(12,s_axi_addr_width);    -- default sum    
--        data := X"00020000";
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);
       
--        addr := conv_std_logic_vector(32,s_axi_addr_width);    -- feature count    
--        data := conv_std_logic_vector(1023,32);
--        AXIL_set(addr,data, S_AXI_araddr,S_AXI_arprot,S_AXI_arready,S_AXI_arvalid,S_AXI_awaddr,S_AXI_awprot,S_AXI_awready,S_AXI_awvalid,S_AXI_bready,S_AXI_bresp,S_AXI_bvalid,S_AXI_rdata,S_AXI_rready,S_AXI_rresp,S_AXI_rvalid,S_AXI_wdata,S_AXI_wready,S_AXI_wstrb,S_AXI_wvalid);

                        
--        wait for Clk_Period*20;        
        
        
        wait for Clk_Period*5;
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
    variable width  : integer := 640;
	variable height : integer := 480;  
    begin
    	wait until aclk'event and aclk = '1';
        wait for Clk_Period;
        --assert false severity failure;
        resetn <= '1';
        wait for Clk_Period;         
        wait until s_axis_tready = '1';
        
        for frame in 0 to 1 loop  
            file_open(foto_file,"../foto",READ_MODE); 
            for y in 0 to height-1 loop
				for x in 0 to width/4-1 loop  
					readline(foto_file, rdline);
					hread(rdline, data);
					s_axis_tdata <= data;
					s_axis_tvalid <= '1';
					if x = 0 and y = 0 then
						s_axis_tuser <= '1';
					else
						s_axis_tuser <= '0';
					end if;
					
					if x = width/4-1 then
						s_axis_tlast <= '1';
					else
						s_axis_tlast <= '0';
					end if; 
					wait until aclk'event and aclk = '1' and s_axis_tready = '1';
					s_axis_tdata <= (others => '0');
					s_axis_tvalid <= '0';
					s_axis_tlast <= '0';
					--wait for Clk_Period*4; 
				end loop;
				report "Line: " &integer'image(y);
			end loop;
			s_axis_tdata <= (others => '0');
            s_axis_tlast <= '0';
            s_axis_tvalid <= '0';
            file_close(foto_file);            
            wait for Clk_Period*1;
        end loop;  
        wait for Clk_Period*100;        
        wait;
    end process;
    
    out_proc: process
    file out_file : text open write_mode is "../out";
    variable outline : line;
    begin
    
    m_axis_tready <= '1';
    if m_axis_tvalid = '1' then
        if m_axis_tlast = '1' then
            assert false severity failure;
        else
            hwrite(outline, m_axis_tdata(31 downto 0)&m_axis_tdata(63 downto 32));
            WRITELINE(out_file, outline);
        end if;
    end if;
    wait for Clk_Period;
    
    end process;
end tb;