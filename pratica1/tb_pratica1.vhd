-- =====================================================================
-- Testbench da Pratica 1 (contador modulo 6)
--
-- Um testbench e um VHDL que so existe na simulacao: gera o clock e as
-- entradas, e confere as saidas com "assert". Se alguma saida estiver
-- errada, o ModelSim imprime a mensagem de erro; se nada aparecer alem
-- de "FIM DA SIMULACAO", o circuito passou em todos os testes.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      -- to_unsigned: converte inteiro em vetor de bits

entity tb_pratica1 is          -- testbench nao tem portas
end tb_pratica1;

architecture sim of tb_pratica1 is
    constant T : time := 20 ns;            -- periodo do clock de simulacao
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';       -- comeca em reset
    signal q     : std_logic_vector(2 downto 0);
    signal fim   : boolean := false;       -- vira true para parar o clock
begin
    -- DUT (device under test): o circuito que esta sendo testado.
    dut : entity work.pratica1
        port map (clk => clk, reset => reset, q => q);

    -- Gerador de clock: meio periodo em '0', meio em '1'.
    -- Quando "fim" vira true o clock para e a simulacao termina sozinha.
    relogio : process
    begin
        while not fim loop
            clk <= '0'; wait for T / 2;
            clk <= '1'; wait for T / 2;    -- bordas de subida em 10, 30, 50 ns...
        end loop;
        wait;                              -- "wait" sem tempo = dorme para sempre
    end process;

    estimulos : process
    begin
        -- Reset inicial: solta aos 5 ns, antes da primeira borda (10 ns).
        reset <= '1';
        wait for 5 ns;
        reset <= '0';

        -- Duas voltas e meia: esperado 0,1,2,3,4,5,0,1,...
        -- No instante exato da borda de subida o contador ainda nao
        -- atualizou, entao aqui se le o valor do ciclo que esta terminando.
        for i in 0 to 14 loop
            wait until rising_edge(clk);
            assert q = std_logic_vector(to_unsigned(i mod 6, 3))   -- i mod 6 = valor esperado
                report "contagem errada no ciclo " & integer'image(i)
                severity error;
        end loop;

        -- Reset no meio da contagem: deve zerar na hora (assincrono),
        -- sem esperar a proxima borda de clock.
        wait for 3 ns;
        reset <= '1';
        wait for 4 ns;
        assert q = "000" report "reset nao zerou o contador" severity error;
        reset <= '0';

        -- Depois do reset a contagem recomeca do 0.
        for i in 0 to 7 loop
            wait until rising_edge(clk);
            assert q = std_logic_vector(to_unsigned(i mod 6, 3))
                report "contagem errada apos o reset, ciclo " & integer'image(i)
                severity error;
        end loop;

        report "FIM DA SIMULACAO - pratica 1" severity note;
        fim <= true;   -- para o clock
        wait;
    end process;
end sim;
