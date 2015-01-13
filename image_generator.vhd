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

entity image_generator is
  Port ( clk : in  STD_LOGIC;
         rst : in  STD_LOGIC;
         addr : out  STD_LOGIC_VECTOR (18 downto 0);
         write_enable : out  STD_LOGIC;
         data : out  STD_LOGIC;
         next_step : in std_logic);
end image_generator;

architecture Behavioral of image_generator is
  type state_type is (reseting,computing,writing);
  signal state :state_type := reseting;
  signal next_state : state_type := reseting;
  signal ready : std_logic := '0';
  signal rst_mandel : std_logic := '0';
  signal x : std_logic_vector(15 downto 0) := (others => '0');
  signal y : std_logic_vector(15 downto 0) := (others => '0');
  signal x_mandel : std_logic_vector(15 downto 0) := (others => '0');
  signal y_mandel : std_logic_vector(15 downto 0) := (others => '0');
  signal nb_iter_max : std_logic_vector(5 downto 0) := (others => '0');
  constant max_iter : positive range 2 to 63 := 4;
  constant x_ref : positive := 16#FE00#;
  constant y_ref : positive := 16#FF10#;
begin

  process (clk,rst)
  begin
    if rst = '1' then
      nb_iter_max <= (others => '0');
    elsif rising_edge(clk) then
      if next_step = '1' then
        if unsigned(nb_iter_max) >= 18 then
          nb_iter_max <= (others => '0');
        else
          nb_iter_max <= std_logic_vector(unsigned(nb_iter_max)+1);
        end if;
      else
        nb_iter_max <= nb_iter_max;
      end if;
    end if;
  end process;

  --state register
  process(clk,rst)
  begin
    if rst = '1' then
      state <= reseting;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process;
  
  --state transition
  process(state,ready)
  begin
    if state = reseting then
      next_state <= computing;
    elsif state = computing then
      if ready = '1' then
        next_state <= reseting;
      else
        next_state <= computing;
      end if;
    elsif state = writing then
      next_state <= reseting;
    end if;
  end process;

  --output function
  rst_mandel <= '1' when state = reseting else '0';
  write_enable <= ready;
--        nb_iter_max <= std_logic_vector(to_unsigned(16#4#,6));
--        nb_iter_max <= std_logic_vector(to_unsigned(max_iter-2,6));
  x_mandel <= std_logic_vector(unsigned(x) + to_unsigned(x_ref,16));
  y_mandel <= std_logic_vector(unsigned(y) + to_unsigned(y_ref,16));

  inst_mandel_loop : entity work.mandel_loop port map (
    clk         => clk,
    rst         => rst_mandel,
    x           => x_mandel,
    y           => y_mandel,
    nb_iter_max => nb_iter_max,
    ok          => data,
    ready       => ready);

  process(clk,rst)
    constant x_max : positive := 639;
    constant y_max : positive := 479;
    variable x_write : natural range 0 to x_max := 0;
    variable y_write : natural range 0 to y_max := 0;
    variable address : natural range 0 to 307199 := 0;
  begin
    if rst = '1' then
--			write_enable <= '0';
      addr <= (others => '0');
--			data <= '0';		
    elsif rising_edge(clk) and ready = '1' then
      -- Address management 
      if address /= 307199 then
        address := address + 1;
      else
        address := 0;
      end if; -- addr max
      -- Coordinate management
      if x_write /= x_max then
        x_write := x_write + 1;
      else --xmax
        x_write := 0;
        if y_write /= y_max then
          y_write := y_write + 1;
        else
          y_write := 0;
        end if;	--ymax
      end if; -- xmax

      addr <= std_logic_vector(to_unsigned(address,19));
      x <= std_logic_vector(to_unsigned(x_write,16));
      y <= std_logic_vector(to_unsigned(y_write,16));

    end if;-- clock rising edge
  end process;

end Behavioral;

