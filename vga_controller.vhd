Library ieee;
USE ieee.std_logic_1164.ALL;

ENTITY VGA_CONTROLLER IS

	PORT(
			clk,reset_n :			  in std_logic;
			HDMI_TX_INT : in std_logic;
			HDMI_TX_CLK : out std_logic;
			HDMI_TX_VS : out std_logic;
			HDMI_TX_HS : out std_logic;
			HDMI_TX_DE 	: out std_logic;
			HDMI_TX_D	   : out std_logic_vector(23 downto 0)

		);

END VGA_CONTROLLER;


ARCHITECTURE VGACONTROL OF VGA_CONTROLLER IS


--VGA Pattern definition
--VGA_640x480p60: begin  // 640x480@60 25.175 MHZ

constant h_total : natural := 799;
constant h_sync : natural := 95;
constant h_start : natural := 141;
constant h_end : natural := 781;

constant v_total : natural := 524;
constant v_sync : natural := 1;
constant v_start : natural := 34;
constant v_end : natural := 514;

constant v_active14 : natural := 154;
constant v_active24 : natural := 274;
constant v_active34 : natural := 394;

signal v_count,h_count : natural := 0;
signal vga_vs,v_de,h_de : std_logic := '0';

signal color : std_logic_vector(23 downto 0) := (others => '0');

	component clk_div port ( s_CLK     : in  std_logic;
            s_RST     : in  std_logic;
            s_SEL_PR  : in  std_logic_vector (1 downto 0);
            OUT_CLK   : out std_logic);
	end component;

BEGIN

divider : clk_div port map(
				s_CLK     => clk,
            s_RST     => reset_n,
            s_SEL_PR  => "01",--25.175Mhz
            OUT_CLK   => HDMI_TX_CLK
				);


	PROCESS(clk,reset_n)

	BEGIN


	if(reset_n = '1') then
		v_count		<=	0;
		h_count <= 0;
		HDMI_TX_VS	<=	'1';
		HDMI_TX_HS	<=	'1';
		HDMI_TX_DE <= '0';
		h_de <= '0';
		v_de <= '0';
	elsif(clk'event and clk = '1') then

		--Horizontal Controls
		if(h_count = h_total) then
			h_count <= 0;

			--Vertical Controls
			if(v_count = v_total) then
				v_count <= 0;
			else
				v_count <= v_count + 1;
			end if;

			if ((v_count >= v_sync) and (not(v_count = v_total))) then
				HDMI_TX_VS	<=	'1';
			else
				HDMI_TX_VS	<=	'0';
			end if;


			if(v_count = v_start)then
				v_de <= '1';
			elsif(v_count = v_end) then
				v_de <= '0';
			end if;
			--End of Vertical controls

		else
			h_count <= h_count + 1;
		end if;
		if ((h_count >= h_sync) and (not(h_count = h_total))) then
			HDMI_TX_HS	<=	'1';
		else
			HDMI_TX_HS	<=	'0';
		end if;
		--end of horizontal controls
		if(h_count = h_start)then
			h_de <= '1';
		elsif(h_count = h_end) then
			h_de <= '0';
		end if;



	end if;

	HDMI_TX_DE <= (v_de and h_de);

 end process;


 color(23 downto 20) <= "1111";
 HDMI_TX_D <= color;

END VGACONTROL;
