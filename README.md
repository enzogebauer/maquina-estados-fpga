# Práticas de Máquina de Estados (FSM) em VHDL, placa DE0-CV

**Para testar na placa e gravar os vídeos, siga o [ROTEIRO_PLACA.md](ROTEIRO_PLACA.md).**

**Para entender o código, leia [EXPLICACAO.md](EXPLICACAO.md):** ele explica cada prática, com diagrama de estados e o que esperar na simulação e na placa.

A prática extra (Conversor Morse) fica em `pratica_extra/` e tem o top-level `morse_de0cv`.

Cada pasta `praticaN` é um projeto do Quartus Prime 20.1 Lite, montado para o dispositivo 5CEBA4F23C7 (DE0-CV).

| Arquivo | Função |
|---|---|
| `praticaN.vhd` | A máquina de estados pedida no slide |
| `tb_praticaN.vhd` | Testbench com verificações automáticas (`assert`) |
| `praticaN_de0cv.vhd` | Top-level da placa: divisor de clock + FSM + LEDs/displays |
| `div_clk.vhd`, `hex7seg.vhd` | Divisor de clock e decodificador de 7 segmentos |

## Ligações na placa

| Prática | Clock da FSM | Entradas | Saídas |
|---|---|---|---|
| 2. Motor de passo (wave) | 4 Hz | KEY0 = reset, SW0 = sentido | LEDR3..0 = A,B,C,D; GPIO_0[3..0] = A..D |
| 3. Gerador 2T0/6T0 | 4 Hz | KEY0 = reset | LEDR0 = y, LEDR9 = clock |
| 7. PWM x/7 | ~8,3 Hz | KEY0 = reset, SW2..0 = x | LEDR0 = PWM, HEX0 = x |
| Extra. Conversor Morse multimodo | 100 Hz | KEY0 = reset, KEY1 = botão Morse, KEY2 = função, SW4..0 = letra | LEDR0/GPIO_0[0] = Morse, LEDR1 = traço, LEDR5..2 = símbolos, LEDR9 = modo, HEX0 = letra, HEX1 = modo |

## Como usar

1. **Abrir:** File > Open Project > `praticaN/praticaN.qpf`.
2. **Compilar:** Processing > Start Compilation.
3. **Simular:** Tools > Run Simulation Tool > RTL Simulation. O ModelSim abre com o testbench `tb_praticaN` já configurado.
4. **Gravar:** Tools > Programmer > Hardware Setup: USB-Blaster > Add File: `output_files/praticaN.sof` > Start.

No ModelSim, para ver o estado da FSM, arraste `dut/estado` para a janela de ondas.
