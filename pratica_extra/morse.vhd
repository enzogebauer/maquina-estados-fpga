-- =====================================================================
-- Pratica Extra: Conversor Morse Interativo com FSM Multimodo
--
-- Este e o bloco principal. Ele tem a FSM de MODO e liga as outras
-- duas FSMs (codificador e decodificador). Nao tem nada da placa aqui,
-- por isso pode ser simulado sozinho (tb_morse.vhd).
--
--                      +----------------------+
--   func (botao de  -->|  FSM de MODO         |--> modo_dec
--   funcao)            |  (este arquivo)      |
--                      +----------+-----------+
--                         ativo   |  ativo
--                  +--------------+--------------+
--                  v                             v
--      +-----------------------+     +-------------------------+
--      | FSM CODIFICADORA      |     | FSM DECODIFICADORA      |
--      | letra + btn -> sinal  |     | btn -> letra            |
--      +-----------------------+     +-------------------------+
--
-- Essa organizacao e chamada de FSMs HIERARQUICAS: uma maquina "chefe"
-- (modo) liga e desliga as maquinas "trabalhadoras". Cada FSM continua
-- pequena e facil de desenhar, em vez de uma unica FSM gigante com
-- todos os estados misturados.
--
-- FSM de MODO (Moore), 4 estados:
--   CODIFICA         modo = codificar
--   VAI_DECODIFICAR  modo = decodificar, esperando soltar o botao de funcao
--   DECODIFICA       modo = decodificar
--   VAI_CODIFICAR    modo = codificar, esperando soltar o botao de funcao
--
-- Por que 4 e nao 2 estados: e o mesmo problema da pratica 5. Um aperto
-- dura muitos clocks; com 2 estados o modo ficaria trocando sem parar
-- enquanto o botao estivesse apertado.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.morse_pkg.all;

entity morse is
    generic (
        UNIDADE      : positive := 20;    -- codificador: ticks por unidade Morse
        LIMIAR_TRACO : positive := 30;    -- decodificador: aperto >= isso e traco
        FIM_LETRA    : positive := 100    -- decodificador: pausa >= isso fecha a letra
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;                     -- assincrono, ativo em '1'
        func     : in  std_logic;                     -- botao de funcao ('1' = apertado)
        btn      : in  std_logic;                     -- botao Morse ('1' = apertado)
        letra_sw : in  std_logic_vector(4 downto 0);  -- letra escolhida nas chaves
        modo_dec : out std_logic;                     -- '0' = codificar, '1' = decodificar
        sinal    : out std_logic;                     -- LED / buzzer Morse
        traco    : out std_logic;                     -- decodificador: "ja e traco"
        simbolos : out natural range 0 to 5;          -- decodificador: simbolos digitados
        letra    : out std_logic_vector(4 downto 0)   -- letra para o display
    );
end morse;

architecture fsm of morse is
    type modo_t is (CODIFICA, VAI_DECODIFICAR, DECODIFICA, VAI_CODIFICAR);
    signal modo : modo_t;

    signal dec       : std_logic;                     -- '1' nos estados de decodificar
    signal ativo_cod : std_logic;
    signal sinal_cod : std_logic;
    signal letra_dec : std_logic_vector(4 downto 0);
begin

    -- -----------------------------------------------------------------
    -- FSM de MODO: registrador de estado + proximo estado
    -- -----------------------------------------------------------------
    process (clk, reset)
    begin
        if reset = '1' then
            modo <= CODIFICA;
        elsif rising_edge(clk) then
            case modo is
                when CODIFICA =>
                    if func = '1' then modo <= VAI_DECODIFICAR; end if;
                when VAI_DECODIFICAR =>
                    if func = '0' then modo <= DECODIFICA; end if;
                when DECODIFICA =>
                    if func = '1' then modo <= VAI_CODIFICAR; end if;
                when VAI_CODIFICAR =>
                    if func = '0' then modo <= CODIFICA; end if;
            end case;
        end if;
    end process;

    -- Saida da FSM de modo (Moore). O modo troca no APERTO do botao,
    -- nao quando ele e solto (igual ao LED da pratica 5).
    dec       <= '1' when modo = VAI_DECODIFICAR or modo = DECODIFICA else '0';
    ativo_cod <= not dec;
    modo_dec  <= dec;

    -- -----------------------------------------------------------------
    -- As duas FSMs de trabalho. As duas recebem o MESMO botao "btn";
    -- quem decide qual delas reage e o sinal "ativo", vindo da FSM de modo.
    -- -----------------------------------------------------------------
    u_cod : entity work.morse_codificador
        generic map (UNIDADE => UNIDADE)
        port map (
            clk   => clk,
            reset => reset,
            ativo => ativo_cod,
            letra => letra_sw,
            btn   => btn,
            sinal => sinal_cod
        );

    u_dec : entity work.morse_decodificador
        generic map (LIMIAR_TRACO => LIMIAR_TRACO, FIM_LETRA => FIM_LETRA)
        port map (
            clk       => clk,
            reset     => reset,
            ativo     => dec,
            btn       => btn,
            resultado => letra_dec,
            simbolos  => simbolos,
            traco     => traco
        );

    -- -----------------------------------------------------------------
    -- Multiplexadores de saida: o modo escolhe o que aparece.
    --   Codificar   : LED = piscadas do codificador; display = letra das chaves
    --   Decodificar : LED = eco do botao (o usuario ve o que esta teclando);
    --                 display = ultima letra decodificada
    -- -----------------------------------------------------------------
    sinal <= btn when dec = '1' else sinal_cod;

    letra <= letra_dec when dec = '1' else
             letra_sw  when to_integer(unsigned(letra_sw)) <= 25 else
             std_logic_vector(to_unsigned(LETRA_INVALIDA, 5));   -- chaves 26..31

end fsm;
