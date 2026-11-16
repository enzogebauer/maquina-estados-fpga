-- =====================================================================
-- Testbench da Pratica 5 (LED liga/desliga com um botao)
--
-- Simula quatro apertos de duracoes diferentes e confere que cada
-- aperto inverte o LED exatamente uma vez, mesmo quando e longo.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica5 is
end tb_pratica5;

architecture sim of tb_pratica5 is
    constant T : time := 20 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal btn   : std_logic := '0';       -- botao comeca solto
    signal led   : std_logic;
    signal fim   : boolean := false;
begin
    dut : entity work.pratica5
        port map (clk => clk, reset => reset, btn => btn, led => led);

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
        -- Procedimento auxiliar: aperta o botao por n ciclos de clock,
        -- solta e espera 3 ciclos para a maquina estabilizar.
        -- As mudancas sao feitas na borda de DESCIDA para ficarem longe
        -- da borda de subida, que e quando a FSM le o botao.
        procedure apertar(n : positive) is
        begin
            wait until falling_edge(clk);
            btn <= '1';
            for i in 1 to n loop wait until falling_edge(clk); end loop;
            btn <= '0';
            for i in 1 to 3 loop wait until falling_edge(clk); end loop;
        end procedure;
    begin
        wait for 15 ns;
        reset <= '0';
        wait for 3 * T;
        assert led = '0' report "LED deveria comecar apagado" severity error;

        apertar(2);
        assert led = '1' report "1o aperto deveria ligar o LED" severity error;

        apertar(10);   -- aperto longo: tem que contar uma vez so
        assert led = '0' report "2o aperto deveria desligar o LED" severity error;

        apertar(1);    -- aperto minimo, de um unico ciclo
        assert led = '1' report "3o aperto deveria ligar o LED" severity error;

        apertar(5);
        assert led = '0' report "4o aperto deveria desligar o LED" severity error;

        report "FIM DA SIMULACAO - pratica 5" severity note;
        fim <= true;
        wait;
    end process;
end sim;
