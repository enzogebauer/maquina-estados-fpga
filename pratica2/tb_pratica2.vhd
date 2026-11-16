-- =====================================================================
-- Testbench da Pratica 2 (motor de passo, modo wave)
--
-- Testa tres coisas: a sequencia no sentido horario, a sequencia no
-- sentido anti-horario e o reset no meio do movimento.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;

entity tb_pratica2 is
end tb_pratica2;

architecture sim of tb_pratica2 is
    constant T : time := 20 ns;             -- periodo do clock de simulacao
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal sentido : std_logic := '0';
    signal a, b, c, d : std_logic;
    -- As 4 fases juntas num vetor (A & B & C & D), so para facilitar a
    -- comparacao e a leitura na forma de onda.
    signal fases   : std_logic_vector(3 downto 0);
    signal fim     : boolean := false;

    -- Tabelas com a sequencia esperada apos cada borda de clock.
    -- Partindo da fase A ("1000"):
    type vet_t is array (natural range <>) of std_logic_vector(3 downto 0);
    --   horario: B, C, D, A, B, C, D, A
    constant HORARIO     : vet_t := ("0100", "0010", "0001", "1000", "0100", "0010", "0001", "1000");
    --   anti-horario: D, C, B, A, D, C, B, A
    constant ANTIHORARIO : vet_t := ("0001", "0010", "0100", "1000", "0001", "0010", "0100", "1000");
begin
    dut : entity work.pratica2
        port map (clk => clk, reset => reset, sentido => sentido,
                  a => a, b => b, c => c, d => d);

    fases <= a & b & c & d;

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
        -- Com reset ativo a maquina deve ficar parada na fase A, mesmo
        -- com o clock batendo (ha uma borda aos 10 ns).
        wait for 15 ns;
        assert fases = "1000" report "estado inicial deveria ser a fase A" severity error;
        reset <= '0';

        -- Sentido horario: confere a fase 1 ns depois de cada borda,
        -- quando a saida ja atualizou.
        sentido <= '0';
        for i in HORARIO'range loop
            wait until rising_edge(clk); wait for 1 ns;
            assert fases = HORARIO(i)
                report "horario: fase errada no passo " & integer'image(i) severity error;
        end loop;

        -- Sentido anti-horario (a sequencia anterior terminou na fase A).
        sentido <= '1';
        for i in ANTIHORARIO'range loop
            wait until rising_edge(clk); wait for 1 ns;
            assert fases = ANTIHORARIO(i)
                report "anti-horario: fase errada no passo " & integer'image(i) severity error;
        end loop;

        -- Reset no meio do movimento: da um passo (vai para B) e reseta.
        sentido <= '0';
        wait until rising_edge(clk); wait for 1 ns;
        reset <= '1'; wait for 2 ns;
        assert fases = "1000" report "reset nao voltou para a fase A" severity error;
        reset <= '0';
        wait for 3 * T;

        report "FIM DA SIMULACAO - pratica 2" severity note;
        fim <= true;
        wait;
    end process;
end sim;
