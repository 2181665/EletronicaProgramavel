----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:01:57 12/10/2020 
-- Design Name: 
-- Module Name:    boxe_graph - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity boxe_graph is
   port(
        clk, reset: in std_logic;
        key_code: in std_logic_vector(3 downto 0);
        video_on: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0)
   );
end boxe_graph;

architecture arch of boxe_graph is
   signal refr_tick: std_logic;
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
   
	--=============================================
	--       Player 1
	--=============================================

	signal player1_x_L, player1_x_R: unsigned(9 downto 0);
   signal player1_y_T, player1_y_B: unsigned(9 downto 0);
	constant player1_x_SIZE: integer:=40;
   constant player1_y_SIZE: integer:=40;
   -- reg to track top boundary  (x position is fixed)
	signal player1_x_reg, player1_x_next: unsigned(9 downto 0);
   signal player1_y_reg, player1_y_next: unsigned(9 downto 0);


	signal player1_on: std_logic;
   signal player1_rgb: std_logic_vector(2 downto 0);
	--=============================================
	--       Player 2
	--=============================================

	signal player2_x_L, player2_x_R: unsigned(9 downto 0);
   signal player2_y_T, player2_y_B: unsigned(9 downto 0);
	constant player2_x_SIZE: integer:=40;
   constant player2_y_SIZE: integer:=40;
   -- reg to track top boundary  (x position is fixed)
	signal player2_x_reg, player2_x_next: unsigned(9 downto 0);
   signal player2_y_reg, player2_y_next: unsigned(9 downto 0);	
	
	signal player2_on: std_logic;
   signal player2_rgb: std_logic_vector(2 downto 0);
	
	--=============================================
   -- moving velocity when the button are pressed
	--=============================================
   constant BAR_V: integer:=1;
   
	
	
	
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
         player1_x_reg <= (others=>'0');
			player1_y_reg <= (others=>'0');
         player2_x_reg <= (others=>'0');
			player2_y_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         player1_x_reg <= player1_x_next;
			player1_y_reg <= player1_y_next;
			player2_x_reg <= player2_x_next;
			player2_y_reg <= player2_y_next;
      end if;
   end process;
	
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
	
   -- refr_tick: 1-clock tick asserted at start of v-sync
   --       i.e., when the screen is refreshed (60 Hz)
   refr_tick <= '1' when (pix_y=481) and (pix_x=1) else
                '0';

	--=============================================
	--       Player 1
	--=============================================

   -- boundary and output
	player1_x_L <= player1_x_reg;
   player1_x_R <= player1_x_L + player1_x_SIZE - 1;
   player1_y_T <= player1_y_reg;
   player1_y_B <= player1_y_T + player1_y_SIZE - 1;
	
   player1_on <=
      '1' when (player1_x_L<=pix_x) and (pix_x<=player1_x_R) and
               (player1_y_t<=pix_y) and (pix_y<=player1_y_b) else
      '0';
   -- player1 output
   player1_rgb <= "010"; --green
	
   -- new bar y-position
   process(player1_x_reg,player1_x_R,player1_x_L,player1_y_reg,player1_y_B,player1_y_T,refr_tick,key_code)
   begin
      player1_x_next <= player1_x_reg; -- no move
		player1_y_next <= player1_y_reg;
      
		if refr_tick='1' then
         if key_code="1000" and player1_y_B<(MAX_Y-10-BAR_V) then
            player1_y_next <= player1_y_reg + BAR_V; -- move down
         elsif key_code="0111" and player1_y_T > BAR_V+10 then
            player1_y_next <= player1_y_reg - BAR_V; -- move up
			elsif key_code="1001" and player1_x_R<(MAX_X-40-BAR_V) then
            player1_x_next <= player1_x_reg + BAR_V; 
			elsif key_code="1010" and player1_x_L > BAR_V+40 then 
            player1_x_next <= player1_x_reg - BAR_V; 	
         end if;
      end if;
   end process;

	--=============================================
	--       Player 2
	--=============================================

   -- boundary and output
	player2_x_L <= player2_x_reg;
   player2_x_R <= player2_x_L + player1_x_SIZE - 1;
   player2_y_T <= player2_y_reg;
   player2_y_B <= player2_y_T + player1_y_SIZE - 1;
	
   player2_on <=
      '1' when (player2_x_L<=pix_x) and (pix_x<=player2_x_R) and
               (player2_y_t<=pix_y) and (pix_y<=player2_y_b) else
      '0';
   -- player1 output
   player2_rgb <= "100"; --red
	
   -- new bar y-position
   process(player2_x_reg,player2_x_R,player2_x_L,player2_y_reg,player2_y_B,player2_y_T,refr_tick,key_code)
   begin
      player2_x_next <= player2_x_reg; -- no move
		player2_y_next <= player2_y_reg;
      
		if refr_tick='1' then
         if key_code="0100" and player2_y_B<(MAX_Y-10-BAR_V) then
            player2_y_next <= player2_y_reg + BAR_V; -- move down
         elsif key_code="0011" and player2_y_T > BAR_V+10 then
            player2_y_next <= player2_y_reg - BAR_V; -- move up
			elsif key_code="0010" and player2_x_R<(MAX_X-40-BAR_V) then
            player2_x_next <= player2_x_reg + BAR_V; 
			elsif key_code="0001" and player2_x_L > BAR_V+40 then 
            player2_x_next <= player2_x_reg - BAR_V; 	
         end if;
      end if;
   end process;




	process(video_on,player1_on, player1_rgb)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --blank
      else
         if player1_on='1' then
            graph_rgb <= player1_rgb;
			elsif	player2_on='1' then
				graph_rgb <= player2_rgb;
         else
            graph_rgb <= "110"; -- yellow background
         end if;
      end if;
   end process;
end arch;