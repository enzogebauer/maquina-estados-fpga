-- =====================================================================
-- Pratica 3: gerador de sinal
--
-- A saida y fica 2 ciclos de clock em nivel baixo (2T0) e 6 ciclos em
-- nivel alto (6T0), repetindo para sempre. O periodo total tem 8 ciclos
-- de clock, entao a maquina tem 8 estados, um por ciclo:
--
--   L1 -> L2 -> H1 -> H2 -> H3 -> H4 -> H5 -> H6 -> L1 ...
--   (y=0) (y=0) (y=1 nos seis estados H)
--
-- Maquina de MOORE: y depende apenas do estado atual.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity pratica3 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;   -- assincrono, ativo em '1'
        y     : out std_logic
    );
end pratica3;

architecture fsm of pratica3 is
    -- L = estados com saida baixa (Low), H = estados com saida alta (High)
    type estado_t is (L1, L2, H1, H2, H3, H4, H5, H6);
    signal estado : estado_t;
begin

    -- Registrador de estado + proximo estado: so anda em fila, um
    -- estado por borda de clock. O "tempo" e contado pelos proprios
    -- estados, sem contador separado.
    process (clk, reset)
    begin
        if reset = '1' then
            estado <= L1;                  -- comeca pelo trecho em nivel baixo
        elsif rising_edge(clk) then
            case estado is
                when L1 => estado <= L2;
                when L2 => estado <= H1;   -- fim dos 2 ciclos em baixo
                when H1 => estado <= H2;
                when H2 => estado <= H3;
                when H3 => estado <= H4;
                when H4 => estado <= H5;
                when H5 => estado <= H6;
                when H6 => estado <= L1;   -- fim dos 6 ciclos em alto, recomeca
            end case;
        end if;
    end process;

    -- Saida (Moore): baixa em L1 e L2, alta nos outros 6 estados
    y <= '0' when (estado = L1 or estado = L2) else '1';

end fsm;
