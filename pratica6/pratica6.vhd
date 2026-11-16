-- Pratica 6: contador modulo 4 (0 a 3) com entrada de sentido
--   s = '0' : contagem crescente   0 1 2 3 0 ...
--   s = '1' : contagem decrescente 3 2 1 0 3 ...
-- Maquina de Moore.
library ieee;
use ieee.std_logic_1164.all;

entity pratica6 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        s     : in  std_logic;
        q     : out std_logic_vector(1 downto 0)
    );
end pratica6;

architecture fsm of pratica6 is
    type estado_t is (S0, S1, S2, S3);
    signal estado : estado_t;
begin

    process (clk, reset)
    begin
        if reset = '1' then
            estado <= S0;
        elsif rising_edge(clk) then
            case estado is
                when S0 => if s = '0' then estado <= S1; else estado <= S3; end if;
                when S1 => if s = '0' then estado <= S2; else estado <= S0; end if;
                when S2 => if s = '0' then estado <= S3; else estado <= S1; end if;
                when S3 => if s = '0' then estado <= S0; else estado <= S2; end if;
            end case;
        end if;
    end process;

    with estado select
        q <= "00" when S0,
             "01" when S1,
             "10" when S2,
             "11" when S3;

end fsm;
