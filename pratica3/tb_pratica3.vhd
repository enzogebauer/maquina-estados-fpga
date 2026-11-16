-- Testbench da Pratica 3 (gerador 2T0 baixo / 6T0 alto)
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica3 is
end tb_pratica3;

architecture sim of tb_pratica3 is
    constant T : time := 20 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal y     : std_logic;
    signal fim   : boolean := false;
    -- valor esperado de y em cada ciclo do periodo
    constant PADRAO : std_logic_vector(0 to 7) := "00111111";
begin
    dut : entity work.pratica3
        port map (clk => clk, reset => reset, y => y);

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
        assert y = PADRAO(0) report "y errado logo apos o reset" severity error;
        reset <= '0';
        -- 3 periodos completos; verifica 1 ns depois de cada borda de subida
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
