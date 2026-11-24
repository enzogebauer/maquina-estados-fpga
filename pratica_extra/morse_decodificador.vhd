-- =====================================================================
-- Pratica Extra: FSM de DECODIFICACAO (tempo do botao -> letra)
--
-- O usuario "tecla" Morse no botao, como num telegrafo:
--   aperto CURTO  (menos que LIMIAR_TRACO ticks) = ponto
--   aperto LONGO  (LIMIAR_TRACO ticks ou mais)   = traco
--   botao SOLTO por FIM_LETRA ticks              = a letra acabou
--
-- Quando a letra acaba, a maquina procura os simbolos na tabela Morse
-- e mostra a letra no display (ou "-" se nao existir).
--
-- Estados:
--   ESPERA     nada sendo digitado
--   APERTADO   botao apertado: mede quanto tempo ele fica assim
--   SOLTO      botao solto entre simbolos: mede se a pausa ja virou fim de letra
--
-- O "tempo" e medido contando bordas de clock (cont). A FSM decide o
-- que o tempo SIGNIFICA (ponto, traco, fim de letra).
--
-- Saidas:
--   resultado : ultima letra decodificada (registrador, muda so no clock)
--   simbolos  : quantos simbolos ja foram digitados na letra atual
--   traco     : SAIDA DE MEALY. Acende enquanto o botao esta apertado
--               ha tempo suficiente para virar traco. Depende do estado
--               (APERTADO), do contador E da entrada btn: se o usuario
--               solta o botao, ela apaga NA HORA, sem esperar o clock.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.morse_pkg.all;

entity morse_decodificador is
    generic (
        LIMIAR_TRACO : positive := 30;    -- 30 ticks a 100 Hz = 300 ms
        FIM_LETRA    : positive := 100    -- 100 ticks a 100 Hz = 1 s
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;                     -- assincrono, ativo em '1'
        ativo     : in  std_logic;                     -- '0' = modo desligado
        btn       : in  std_logic;                     -- '1' = botao apertado
        resultado : out std_logic_vector(4 downto 0);  -- codigo da letra
        simbolos  : out natural range 0 to 5;          -- simbolos ja digitados
        traco     : out std_logic                      -- "ja e traco" (Mealy)
    );
end morse_decodificador;

architecture fsm of morse_decodificador is
    type estado_t is (ESPERA, APERTADO, SOLTO);
    signal estado : estado_t;

    -- O contador so precisa ir ate o maior tempo que interessa.
    -- Ele SATURA (para de contar) para nao "dar a volta" se o usuario
    -- segurar o botao por muito tempo.
    constant CONT_MAX : natural := FIM_LETRA;
    signal cont   : natural range 0 to CONT_MAX;

    signal padrao : std_logic_vector(3 downto 0);   -- simbolos recebidos ('1' = traco)
    signal tam    : natural range 0 to 5;           -- 5 = passou do limite do Morse
    signal letra  : natural range 0 to 31;          -- ultima letra decodificada
begin

    process (clk, reset)
        variable bit_novo : std_logic;
    begin
        if reset = '1' then
            estado <= ESPERA;
            cont   <= 0;
            padrao <= (others => '0');
            tam    <= 0;
            letra  <= LETRA_VAZIA;

        elsif rising_edge(clk) then
            if ativo = '0' then
                -- Reset sincrono ao sair do modo. A ultima letra
                -- (registrador "letra") e mantida de proposito.
                estado <= ESPERA;
                cont   <= 0;
                padrao <= (others => '0');
                tam    <= 0;

            else
                case estado is

                    when ESPERA =>
                        cont <= 0;
                        if btn = '1' then
                            estado <= APERTADO;
                        end if;

                    when APERTADO =>
                        if btn = '1' then
                            -- Continua apertado: conta o tempo (saturando).
                            if cont < CONT_MAX then
                                cont <= cont + 1;
                            end if;
                        else
                            -- Soltou: decide se foi ponto ou traco PELO TEMPO.
                            if cont >= LIMIAR_TRACO then
                                bit_novo := '1';      -- traco
                            else
                                bit_novo := '0';      -- ponto
                            end if;
                            -- Registrador de deslocamento: o simbolo novo
                            -- entra pela direita e os antigos andam para a
                            -- esquerda. Assim o primeiro simbolo termina no
                            -- bit (tam - 1), igual a tabela do pacote.
                            if tam < 4 then
                                padrao <= padrao(2 downto 0) & bit_novo;
                            end if;
                            if tam < 5 then
                                tam <= tam + 1;       -- 5 marca "simbolos demais"
                            end if;
                            cont   <= 0;
                            estado <= SOLTO;
                        end if;

                    when SOLTO =>
                        if btn = '1' then
                            -- Apertou de novo antes do fim: mais um simbolo da mesma letra.
                            cont   <= 0;
                            estado <= APERTADO;
                        elsif cont = FIM_LETRA - 1 then
                            -- Pausa longa: a letra acabou. Consulta a tabela.
                            if tam <= 4 then
                                letra <= decodifica(tam, padrao);
                            else
                                letra <= LETRA_INVALIDA;
                            end if;
                            padrao <= (others => '0');
                            tam    <= 0;
                            cont   <= 0;
                            estado <= ESPERA;
                        else
                            cont <= cont + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- Saidas de Moore / registradas: so mudam na borda do clock.
    resultado <= std_logic_vector(to_unsigned(letra, 5));
    simbolos  <= tam;

    -- Saida de MEALY: usa o estado E a entrada btn (compare com o
    -- slide 18, "WHEN B => z <= w").
    traco <= '1' when estado = APERTADO and btn = '1' and cont >= LIMIAR_TRACO
             else '0';

end fsm;
