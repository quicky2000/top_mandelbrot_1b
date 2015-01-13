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

entity mandel_iter is
    Port ( x_n : in  STD_LOGIC_VECTOR (15 downto 0);
           y_n : in  STD_LOGIC_VECTOR (15 downto 0);
           x_square_in : in  STD_LOGIC_VECTOR (15 downto 0);
           y_square_in : in  STD_LOGIC_VECTOR (15 downto 0);
           a : in  STD_LOGIC_VECTOR (15 downto 0);
           b : in  STD_LOGIC_VECTOR (15 downto 0);
           x_n_plus_1 : out  STD_LOGIC_VECTOR (15 downto 0);
           y_n_plus_1 : out  STD_LOGIC_VECTOR (15 downto 0));
end mandel_iter;

architecture Behavioral of mandel_iter is
  signal x_y : std_logic_vector(15 downto 0) := (others => '0');  -- x * y
begin
  x_y_mult : entity work.mult_16_8 
    port map (
      a => x_n,
      b => y_n,
      p => x_y);

    x_n_plus_1 <= std_logic_vector(signed(x_square_in) - signed(y_square_in) + signed(a));
    y_n_plus_1 <= std_logic_vector((signed(x_y) sll 1) + signed(b));
end Behavioral;

