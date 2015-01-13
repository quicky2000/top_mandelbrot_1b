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

entity mult_16_8 is
    Port ( a : in  STD_LOGIC_VECTOR (15 downto 0);
           b : in  STD_LOGIC_VECTOR (15 downto 0);
           p : out  STD_LOGIC_VECTOR (15 downto 0));
end mult_16_8;

architecture Behavioral of mult_16_8 is

  
  signal internal : std_logic_vector(31 downto 0);
  signal internal_reduced : std_logic_vector(15 downto 0);
  signal abs_a : std_logic_vector(15 downto 0);
  signal abs_b : std_logic_vector(15 downto 0);
  signal l_neg : std_logic := '0';        -- sign of product
begin
  -- Compute absolute values of operands
  abs_a <= std_logic_vector(abs(signed(a)));
  abs_b <= std_logic_vector(abs(signed(b)));
  -- Compute sign of product
  l_neg <= a(15) xor b(15);
  -- Compute unsigned extendend product
  simple_mult : entity work.simple_mult port map(
	a => abs_a,
	b => abs_b,
	p => internal);
--  internal <= std_logic_vector(unsigned(abs_a) * unsigned(abs_b));
  -- Trunk product
  trunc : entity work.truncator port map(
	i => internal,
	o => internal_reduced);
	
  --internal_reduced(15 downto 0) <= internal(23 downto 8);
  -- restablish sign if needed
  p <= internal_reduced when l_neg = '0' else std_logic_vector(-signed(internal_reduced));
  
--        internal_a(15 downto 0) <= a;
--        internal_a(17) <= a(15);
--        internal_a(16) <= a(15);
--        internal_b(15 downto 0) <= b;
--        internal_b(17) <= b(15);
--        internal_b(16) <= b(15);
--	internal <= std_logic_vector(unsigned(internal_a) * unsigned(internal_b));
--	p(15 downto 0) <= internal(23 downto 8);




end Behavioral;

