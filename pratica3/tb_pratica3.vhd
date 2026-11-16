-- =====================================================================
-- Testbench da Pratica 3 (gerador 2T0 baixo / 6T0 alto)
--
-- Confere, ciclo a ciclo, se y segue o padrao 0,0,1,1,1,1,1,1 durante
-- tres periodos completos.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica3 is
end tb_pratica3;

architecture sim of tb_pratica3 is
    constant T : time := 20 ns;            -- periodo do clock (T0 do enunciado)
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal y     : std_logic;
    signal fim   : boolean := false;
    -- Valor esperado de y em cada um dos 8 ciclos do periodo.
    -- "0 to 7" faz o indice 0 ser o caractere mais a esquerda.
    constant PADRAO : std_logic_vector(0 to 7) := "00111111";
begin
    dut : entity work.pratica3
        port map (clk => clk, reset => reset, y => y);

    -- Gerador de clock (para quando fim = true)
    relogio : process
    begin
        while not fim loop
            clk <= '0'; wait for T / 2;
            clk <= '1'; wait for T / 2;
        end loop;
        wait;
    end process;

    estimulos : process
    begin
        wait for 5 ns;
        -- Logo apos o reset a maquina esta em L1 (ciclo 0 do padrao).
        assert y = PADRAO(0) report "y errado logo apos o reset" severity error;
        reset <= '0';
        -- 24 bordas = 3 periodos. Depois da i-esima borda a maquina esta
        -- no ciclo (i mod 8) do padrao; a leitura e feita 1 ns apos a
        -- borda, quando y ja atualizou.
        for i in 1 to 24 loop
            wait until rising_edge(clk); wait for 1 ns;
            assert y = PADRAO(i mod 8)
                report "y errado no ciclo " & integer'image(i) severity error;
        end loop;
        report "FIM DA SIMULACAO - pratica 3" severity note;
        fim <= true;
        wait;
    end process;
end sim;
