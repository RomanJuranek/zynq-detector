library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package func_pkg is
    
    constant Clk_Period : time := 5 ns; -- 200 Mhz
    
    constant S_AXI_DATA_WIDTH    : integer    := 32;
    constant S_AXI_ADDR_WIDTH    : integer    := 18;
    

    procedure AXIL_set(
		variable addr: in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0); 
		variable data : in std_logic_vector(31 downto 0);
		signal S_AXI_araddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
		signal S_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		signal S_AXI_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_awaddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
		signal S_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		signal S_AXI_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		signal S_AXI_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
		signal S_AXI_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		signal S_AXI_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
		signal S_AXI_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
		signal S_AXI_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 )
	);
	procedure AXIL_read(
		variable addr: in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0); 
		signal S_AXI_araddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
		signal S_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		signal S_AXI_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_awaddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
		signal S_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		signal S_AXI_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		signal S_AXI_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
		signal S_AXI_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		signal S_AXI_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
		signal S_AXI_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
		signal S_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
		signal S_AXI_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 )
	);
	
	procedure wait_for(
            signal sig : in STD_LOGIC;
            constant con : in STD_LOGIC            
    );    
    

end func_pkg;

package body func_pkg is



procedure wait_for(
    signal sig : in STD_LOGIC;
    constant con : in STD_LOGIC            
) is
begin
    while 1=1 loop        
		if sig = con then			
			exit;
		end if;
		wait for Clk_Period;
	end loop;
end procedure;

procedure AXIL_set(
   	variable  addr: in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0); 
    variable data : in std_logic_vector(31 downto 0);
	signal S_AXI_araddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
    signal S_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    signal S_AXI_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_awaddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
    signal S_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    signal S_AXI_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S_AXI_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S_AXI_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S_AXI_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S_AXI_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    signal S_AXI_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 )
	) is
begin

    s_axi_awaddr <= addr;
		
	s_axi_awvalid(0) <= '1';
	
	wait_for(S_AXI_awready(0) ,'1');
	
	s_axi_awaddr <= (others => '0');
	s_axi_awvalid(0) <= '0';
	
	s_axi_wdata <= data;
	s_axi_wvalid(0) <= '1';
	wait for Clk_Period;
	s_axi_wdata <= (others => '0');
	s_axi_wvalid(0) <= '0';
	
	s_axi_bready(0) <= '1';
	wait for Clk_Period;
	s_axi_bready(0) <= '0';
	
	wait for Clk_Period;
end procedure;

procedure AXIL_read(
   	variable  addr: in std_logic_vector(S_AXI_ADDR_WIDTH-1 downto 0); 
	signal S_AXI_araddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
    signal S_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    signal S_AXI_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_awaddr : out STD_LOGIC_VECTOR (s_axi_addr_width-1 downto 0);
    signal S_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    signal S_AXI_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S_AXI_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S_AXI_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S_AXI_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S_AXI_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    signal S_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    signal S_AXI_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 )
	) is
begin		
	

    s_axi_araddr <= addr(13 downto 0);
	
	s_axi_arvalid(0) <= '1';
	
	wait_for(S_AXI_awready(0) ,'1');
			
	s_axi_araddr <= (others => '0');
	s_axi_arvalid(0) <= '0';
	
	s_axi_rready(0) <= '1';
	wait for Clk_Period*2;
	s_axi_rready(0) <= '0';
	
	wait for Clk_Period*2;
end procedure;

end package body func_pkg;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------