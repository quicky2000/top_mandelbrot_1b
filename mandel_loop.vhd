--
--    This file is part of top_mandelbrot_1b
--    Copyright (C) 2011  Julien Thevenon ( julien_thevenon at yahoo.fr )
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mandel_loop is
    Port ( clk : in std_logic;
           rst : std_logic;
           x : in  STD_LOGIC_VECTOR (15 downto 0);
           y : in  STD_LOGIC_VECTOR (15 downto 0);
           nb_iter_max : in  STD_LOGIC_VECTOR (5 downto 0);
           ok : out  STD_LOGIC;
           ready : out std_logic);
end mandel_loop;

architecture Behavioral of mandel_loop is
  signal x_n_plus_1 : std_logic_vector(15 downto 0) := (others => '0');  -- x * x
  signal y_n_plus_1 : std_logic_vector(15 downto 0) := (others => '0');  -- y * y
  signal x_n : std_logic_vector(15 downto 0) := (others => '0');  -- x * x
  signal y_n : std_logic_vector(15 downto 0) := (others => '0');  -- y * y
  signal x_square_in : std_logic_vector(15 downto 0) := (others => '0');  -- x * y
  signal y_square_in : std_logic_vector(15 downto 0) := (others => '0');  -- x * y
  signal x_square_out : std_logic_vector(15 downto 0) := (others => '0');  -- x * y
  signal y_square_out : std_logic_vector(15 downto 0) := (others => '0');  -- x * y
begin 
  x_x_mult : entity work.mult_16_8
    port map (
      a => x_square_in,
      b => x_square_in,
      p => x_square_out);
      
  y_y_mult : entity work.mult_16_8
    port map (
      a => y_square_in,
      b => y_square_in,
      p => y_square_out);
      
  inst_mandel_iter : entity work.mandel_iter
   port map (
     x_n         => x_n,
     y_n         => y_n,
     x_square_in => x_square_out,
     y_square_in => y_square_out,
     a           => x,
     b           => y,
     x_n_plus_1  => x_n_plus_1,
     y_n_plus_1  => y_n_plus_1);

  compute_process : process (clk, rst)
  variable l_nb_iter : natural range 0 to 127:= 0;  -- current iteration
  begin  -- process compute_process
	if rising_edge(clk) then  -- rising clock edge
	   if rst = '1' then                   -- asynchronous reset (active low)
      ok <= '0';
      l_nb_iter := 0;
      x_square_in <= x;
      y_square_in <= y;
      x_n <= x;
      y_n <= y;
      ready <= '0';
      ok <= '0';
    else
--      if l_nb_iter /= 0 then 
        x_square_in <= x_n_plus_1;
        y_square_in <= y_n_plus_1;
        x_n <= x_n_plus_1;
        y_n <= y_n_plus_1;
--      else
--       x_square_in <= x; 
--       y_square_in <= y;        
--      end if;
      
      if  unsigned(x_square_out) + unsigned(y_square_out) > 16#400# then 
        ready <= '1';
        ok <= '0';
      else
          if l_nb_iter /= unsigned(nb_iter_max) then
            l_nb_iter := l_nb_iter +1;
				ready <= '0';
				ok <= '0';
          else
            ready <= '1';
            ok <= '1';
          end if;
      end if;
      end if ;
    end if;
  end process compute_process;
  
end Behavioral;

