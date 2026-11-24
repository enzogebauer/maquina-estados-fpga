-- =====================================================================
-- Divisor de clock (usado no top-level de todas as praticas)
--
-- A placa DE0-CV fornece um clock de 50 MHz. Nessa velocidade nao da
-- para ver nada nos LEDs, entao este bloco gera um clock bem mais lento
-- para alimentar a maquina de estados.
--
-- Formula:  f_saida = f_entrada / (2 * DIVISOR)
--   DIVISOR = 25_000_000 -> 50 MHz / 50_000_000 = 1 Hz
--   DIVISOR =  6_250_000 -> 4 Hz
--   DIVISOR =    250_000 -> 100 Hz
--
-- O "2 *" aparece porque a saida inverte a cada DIVISOR ciclos: sao
-- DIVISOR ciclos em '0' e mais DIVISOR ciclos em '1' por periodo.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity div_clk is
    generic (
        -- "generic" e um parametro definido na hora de instanciar o bloco;
        -- cada pratica escolhe o seu valor no "generic map".
        DIVISOR : positive := 25_000_000
    );
    port (
        clk_in  : in  std_logic;   -- clock rapido (50 MHz da placa)
        clk_out : out std_logic    -- clock lento gerado
    );
end div_clk;

architecture rtl of div_clk is
    -- Contador de ciclos do clock rapido. O "range" limita os valores
    -- possiveis, e o Quartus usa so os bits necessarios.
    signal cnt : natural range 0 to DIVISOR - 1 := 0;
    -- Registrador que guarda o nivel atual do clock lento.
    signal q   : std_logic := '0';
begin
    process (clk_in)
    begin
        if rising_edge(clk_in) then          -- a cada borda de subida de 50 MHz
            if cnt = DIVISOR - 1 then        -- ja contou DIVISOR ciclos?
                cnt <= 0;                    --   recomeca a contagem
                q   <= not q;                --   e inverte a saida (meio periodo)
            else
                cnt <= cnt + 1;              -- senao, continua contando
            end if;
        end if;
    end process;

    clk_out <= q;
end rtl;
