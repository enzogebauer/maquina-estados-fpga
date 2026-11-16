-- =====================================================================
-- Pratica 4: contador progressivo/regressivo em codigo Gray de 2 bits
--
-- No codigo Gray apenas UM bit muda entre valores vizinhos:
--
--   00 -> 01 -> 11 -> 10 -> 00 ...
--
--   x = '1' : vai para o numeral SEGUINTE da sequencia
--   x = '0' : vai para o numeral ANTERIOR da sequencia
--
-- Cada numeral e um estado (G00, G01, G11, G10).
-- Maquina de MOORE: a saida e o proprio codigo do estado atual; a
-- entrada x so escolhe para qual vizinho a maquina vai.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica4 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;                     -- assincrono, ativo em '1'
        x     : in  std_logic;                     -- '1' sobe, '0' desce
        q     : out std_logic_vector(1 downto 0)   -- codigo Gray atual
    );
end pratica4;

architecture fsm of pratica4 is
    -- Os estados estao declarados na ordem da sequencia Gray.
    type estado_t is (G00, G01, G11, G10);
    signal estado : estado_t;
begin

    -- Registrador de estado + logica de proximo estado
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= G00;
        elsif rising_edge(clk) then
            -- Em cada estado: x = '1' -> proximo da sequencia,
            --                 x = '0' -> anterior da sequencia.
            case estado is
                when G00 => if x = '1' then estado <= G01; else estado <= G10; end if;
                when G01 => if x = '1' then estado <= G11; else estado <= G00; end if;
                when G11 => if x = '1' then estado <= G10; else estado <= G01; end if;
                when G10 => if x = '1' then estado <= G00; else estado <= G11; end if;
            end case;
        end if;
    end process;

    -- Saida (Moore): o codigo Gray correspondente ao estado
    with estado select
        q <= "00" when G00,
             "01" when G01,
             "11" when G11,
             "10" when G10;

end fsm;
