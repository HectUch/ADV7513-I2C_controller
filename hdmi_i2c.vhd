Library ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hdmi_I2C IS

	PORT( 
			clk 	: in std_logic;
			reset : in std_logic;
			start_transf: in std_logic;
			wr_bit : in std_logic;			
			d_byte : in std_logic_vector(7 downto 0);
			addr_byte :  in std_logic_vector(7 downto 0);
			SDA_o,SCL : INOUT std_logic;
			PD,busy,ready, Fail: out std_logic			
		);
		
END hdmi_I2C;


ARCHITECTURE hdmi_I2C_Arch OF hdmi_I2C IS
   
	TYPE STATE_TYPE IS (IDLE,START,TRANSF_SLAVE_ADDR, TRANSF_ADDR , TRANSF_DATA,ACK,STOP);
   SIGNAL state   : STATE_TYPE;
	signal start_bit: std_logic := '0';
	signal slave_addr : std_logic_vector(6 downto 0) := "0111001"; --0x72 PD = 0, 0x7A PD = 1
	signal count,pstate : natural := 0;
	signal slave_addr_word,base_addr_word,data_byte_word : std_logic_vector(7 downto 0) := (others => '0');
	signal SDA: std_logic := '1';
	
	signal stop_count : natural := 0;
	signal clk_25mhz,clk_400khz,on_going_transf : std_logic := '1';
	signal count_400khz : natural := 124;
	signal count_25mhz : natural := 1;
	signal start_count : natural := 4;
	signal sent_bit : natural := 0;
	
	
begin
	clk_divider : process(clk,reset)
	begin
	if(reset = '1') then
		count_25mhz <= 1;
		count_400khz <= 124;
		clk_25mhz <= '1';
		clk_400khz <= '1';
		slave_addr  <= "0111001";
		stop_count <= 0;
	elsif (clk'EVENT AND clk = '1') then
		if(on_going_transf = '1') then
			if(count_400khz = 0) then
				count_400khz <= 124;
				clk_400khz <= not clk_400khz;
			else
				count_400khz <= count_400khz - 1;
			end if;
		else
			count_400khz <= 124;
			clk_400khz <= '1';
		end if;

		if count_25mhz = 0 then
			clk_25mhz <= not clk_25mhz;
			count_25mhz <= 1;
		else
			count_25mhz <= count_25mhz - 1;
		end if;		
		
	end if;	
	
	end process; --clock divider;
	

	PROCESS (clk, reset,state)
   BEGIN
      IF reset = '1' THEN
			on_going_transf <= '0';
			ready <= '1';
         state <= IDLE;
			--SCL <= '1';
			--SDA <= '1';			
		ELSIF (clk'EVENT AND clk = '1') THEN
         CASE state IS
            WHEN IDLE=>
               IF start_transf = '1' THEN
						SDA <= start_bit; -- ZERO('0')
						on_going_transf <= '1';
						slave_addr_word <= slave_addr & wr_bit;
						base_addr_word	 <= addr_byte;
						base_addr_word	 <= d_byte;
						ready <= '0';
						pstate <= 0;
						--SCL <= CLK_400khz;
						state <= START;
					ELSE
						--SCL <= '1';
						SDA <= '1';
						pstate <= 0;
						on_going_transf <= '0';
						ready <= '1';
						state <= IDLE;
               END IF;
				WHEN START=>
					if(count_400khz = 52  AND clk_400khz = '1')then
						state <= TRANSF_SLAVE_ADDR;
					end if;
           	WHEN TRANSF_SLAVE_ADDR =>
					--SCL <= CLK_400khz;
					if(count_400khz = 60  AND clk_400khz = '0')then
					
						if (sent_bit = 8) then
							sent_bit <= 0;
							state <= ACK;
						end if;
						
						SDA <= slave_addr_word(7);
						slave_addr_word <= slave_addr_word(6 downto 0) & slave_addr_word(7);
						sent_bit <= sent_bit + 1;
						
					end if;			
				
				WHEN TRANSF_ADDR =>
				
					if(count_400khz = 60  AND clk_400khz = '0')then
					
						if (sent_bit = 8) then
							sent_bit <= 0;
							state <= ACK;
						end if;
						
						SDA <= base_addr_word(7);
						base_addr_word <= base_addr_word(6 downto 0) & base_addr_word(7);
						sent_bit <= sent_bit + 1;
						
					end if;
					
					WHEN TRANSF_DATA =>
				
						if(count_400khz = 60  AND clk_400khz = '0')then
						
							if (sent_bit = 8) then
								sent_bit <= 0;
								state <= ACK;
							end if;
							
							SDA <= data_byte_word(7);
							data_byte_word <= data_byte_word(6 downto 0) & data_byte_word(7);
							sent_bit <= sent_bit + 1;
							
						end if;
					
					WHEN STOP =>
						if(count_400khz = 120 AND clk_400khz = '0')then
							SDA <= '0';							
						end if;
						
						if(count_400khz = 20  AND clk_400khz = '1')then
							SDA <= '1';
							ready <= '1';
							on_going_transf <= '0';
							state <= idle;
						end if;
					WHEN ACK=>
						
						if(count_400khz = 60  AND clk_400khz = '1')then
							sent_bit <= 0;
							IF SDA_o = '0'and pstate = 0 THEN
								pstate <= 1;
								state <= TRANSF_ADDR;
							ELSIF SDA_o = '0'and pstate = 1 THEN
								pstate <= 2;
								state <= TRANSF_DATA;
							ELSIF SDA_o = '0'and pstate = 2 THEN
								pstate <= 0;
								state <= STOP;						
							ELSE
								fail <= '1';
								ready <= '1';
								pstate <= 0;
								state <= IDLE;
							END IF;
						end if;
				 WHEN OTHERS =>
								
						
         END CASE;			
			
	END IF;

	END PROCESS;


	
	SDA_o <= SDA when state /= ACK else '0' ;
	SCL <= CLK_400khz or not on_going_transf when state /= idle else '1';
	PD <= '0';
	busy <= on_going_transf;

END hdmi_I2C_Arch;