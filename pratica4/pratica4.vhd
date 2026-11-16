-- Pratica 4: contador progressivo/regressivo em codigo Gray de 2 bits
-- Sequencia: 00 -> 01 -> 11 -> 10 -> 00 ...
--   x = '1' : vai para o numeral seguinte
--   x = '0' : vai para o numeral anterior
-- Maquina de Moore (a saida e o proprio codigo do estado).
library ieee;
use ieee.std_logic_1164.all;

entity pratica4 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        x     : in  std_logic;
        q     : out std_logic_vector(1 downto 0)
    );
end pratica4;

architecture fsm of pratica4 is
    type estado_t is (G00, G01, G11, G10);
    signal estado : estado_t;
begin

    process (clk, reset)
    begin
        if reset = '1' then
            estado <= G00;
        elsif rising_edge(clk) then
            case estado is
                when G00 => if x = '1' then estado <= G01; else estado <= G10; end if;
                when G01 => if x = '1' then estado <= G11; else estado <= G00; end if;
                when G11 => if x = '1' then estado <= G10; else estado <= G01; end if;
                when G10 => if x = '1' then estado <= G00; else estado <= G11; end if;
            end case;
        end if;
    end process;

    with estado select
        q <= "00" when G00,
             "01" when G01,
             "11" when G11,
             "10" when G10;

end fsm;
