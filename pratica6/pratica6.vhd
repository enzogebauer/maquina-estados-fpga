-- =====================================================================
-- Pratica 6: contador modulo 4 (0 a 3) com entrada de sentido
--
--   s = '0' : contagem crescente   0 -> 1 -> 2 -> 3 -> 0 ...
--   s = '1' : contagem decrescente 3 -> 2 -> 1 -> 0 -> 3 ...
--
-- Cada valor da contagem e um estado (S0..S3).
-- Maquina de MOORE: a saida depende so do estado; a entrada s escolhe
-- apenas se o proximo estado e o da frente ou o de tras.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica6 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;                     -- assincrono, ativo em '1'
        s     : in  std_logic;                     -- sentido da contagem
        q     : out std_logic_vector(1 downto 0)   -- contagem 0..3 (2 bits)
    );
end pratica6;

architecture fsm of pratica6 is
    type estado_t is (S0, S1, S2, S3);
    signal estado : estado_t;
begin

    -- Registrador de estado + logica de proximo estado
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= S0;
        elsif rising_edge(clk) then
            -- Em cada estado: s = '0' -> soma 1, s = '1' -> subtrai 1.
            -- As "voltas" sao S3 -> S0 (crescente) e S0 -> S3 (decrescente).
            case estado is
                when S0 => if s = '0' then estado <= S1; else estado <= S3; end if;
                when S1 => if s = '0' then estado <= S2; else estado <= S0; end if;
                when S2 => if s = '0' then estado <= S3; else estado <= S1; end if;
                when S3 => if s = '0' then estado <= S0; else estado <= S2; end if;
            end case;
        end if;
    end process;

    -- Saida (Moore): o numero binario correspondente ao estado
    with estado select
        q <= "00" when S0,
             "01" when S1,
             "10" when S2,
             "11" when S3;

end fsm;
