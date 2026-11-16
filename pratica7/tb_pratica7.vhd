-- =====================================================================
-- Testbench da Pratica 7 (PWM x/7)
--
-- Para cada valor de x de 0 a 7, conta em quantos dos 7 ciclos de um
-- periodo a saida y esta em '1'. O resultado tem que ser igual a x.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      -- to_unsigned: converte inteiro em vetor de bits

entity tb_pratica7 is
end tb_pratica7;

architecture sim of tb_pratica7 is
    constant T : time := 20 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal x     : std_logic_vector(2 downto 0) := "000";
    signal y     : std_logic;
    signal fim   : boolean := false;
begin
    dut : entity work.pratica7
        port map (clk => clk, reset => reset, x => x, y => y);

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
        variable altos : natural;   -- quantos ciclos y ficou em '1'
    begin
        wait for 5 ns;
        reset <= '0';
        for duty in 0 to 7 loop
            x <= std_logic_vector(to_unsigned(duty, 3));   -- aplica o novo x

            -- Deixa passar um periodo inteiro (7 ciclos) com o novo x...
            for i in 1 to 7 loop wait until rising_edge(clk); end loop;

            -- ...e mede o periodo seguinte: olha y no meio de cada ciclo
            -- (borda de descida), quando o valor esta estavel.
            altos := 0;
            for i in 1 to 7 loop
                wait until falling_edge(clk);
                if y = '1' then altos := altos + 1; end if;
                wait until rising_edge(clk);
            end loop;

            assert altos = duty
                report "x=" & integer'image(duty) & ": y alto em " & integer'image(altos)
                       & " de 7 ciclos (esperado " & integer'image(duty) & ")"
                severity error;
        end loop;
        report "FIM DA SIMULACAO - pratica 7" severity note;
        fim <= true;
        wait;
    end process;
end sim;
