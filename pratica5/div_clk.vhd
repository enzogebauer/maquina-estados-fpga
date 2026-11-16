-- Divisor de clock: clk_out = clk_in / (2 * DIVISOR)
-- Ex.: clk_in = 50 MHz e DIVISOR = 25_000_000 -> clk_out = 1 Hz
library ieee;
use ieee.std_logic_1164.all;

entity div_clk is
    generic (
        DIVISOR : positive := 25_000_000
    );
    port (
        clk_in  : in  std_logic;
        clk_out : out std_logic
    );
end div_clk;

architecture rtl of div_clk is
    signal cnt : natural range 0 to DIVISOR - 1 := 0;
    signal q   : std_logic := '0';
begin
    process (clk_in)
    begin
        if rising_edge(clk_in) then
            if cnt = DIVISOR - 1 then
                cnt <= 0;
                q   <= not q;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    clk_out <= q;
end rtl;
