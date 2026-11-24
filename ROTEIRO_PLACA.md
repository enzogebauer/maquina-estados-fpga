# Roteiro de teste na placa e gravação dos vídeos

Passo a passo para testar cada prática na DE0-CV e gravar um vídeo de cada uma. Marque os `[ ]` conforme for fazendo.

**Ordem sugerida:** prática 3 → prática 7 → prática 2 (LEDs) → prática 2 (motor) → extra (Morse). As mais simples primeiro, para pegar o jeito do Quartus.

---

## 0. Antes de ir para o lab

- [ ] Notebook **Windows** com o Quartus Prime 20.1 Lite instalado. O Quartus não roda no macOS.
- [ ] Repositório atualizado no notebook (`git pull`).
- [ ] Celular carregado, com espaço para uns 6 vídeos curtos.
- [ ] Algo para apoiar o celular por cima da placa (suporte, pilha de livros).
- [ ] **6 fios jumper fêmea-fêmea separados** para o motor. Os 2 cabos de 3 fios do kit não servem como estão, porque o conector de plástico junta 3 fios e eles precisam ir em pinos separados. Duas saídas:
  - levantar a trava de plástico de cada ponta com uma pinça ou agulha e puxar os fios um a um; ou
  - pedir 6 jumpers fêmea-fêmea no lab.
- [ ] Um pedaço de fita adesiva, para fazer uma "bandeirinha" no eixo do motor.

## 1. Preparar a placa (sempre que ligar)

1. [ ] Ligue a fonte na placa e aperte o **botão vermelho**. Os LEDs e displays devem acender com o programa de fábrica.
2. [ ] Ligue o cabo USB (o cinza, ponta quadrada) na entrada **USB BLASTER** da placa e no notebook.
3. [ ] Confira a chave **SW10**, à esquerda dos displays: tem que estar em **RUN**. Em PROG a gravação não funciona.

## 2. Como gravar um `.sof` (vale para todas as práticas)

1. [ ] No Quartus: **File > Open Project** e escolha o `.qpf` da prática.
2. [ ] **Tools > Programmer**.
3. [ ] Se aparecer "No Hardware" ao lado de Hardware Setup: clique em **Hardware Setup**, escolha **USB-Blaster** e feche.
4. [ ] Mode: **JTAG**.
5. [ ] Se a lista estiver vazia, clique em **Add File** e escolha `output_files/<nome>.sof`. Se já tiver um arquivo de outra prática, selecione e clique em **Delete** antes.
6. [ ] Marque a caixa **Program/Configure** da linha do `.sof`.
7. [ ] Clique em **Start**. A barra tem que chegar em **100% (Successful)**.

> O `.sof` fica só na memória do FPGA. Se desligar a placa, ele some e é preciso gravar de novo. É normal.

**Grave uma vez a tela do "100% (Successful)"** (print ou vídeo curto). Serve para os slides.

## 3. Como gravar os vídeos

- Celular em cima da placa, pegando **displays, LEDs, chaves e botões**.
- No iPhone, **segure o dedo na tela** sobre os LEDs até aparecer "Bloqueio AE/AF". Isso trava o brilho. Sem isso a câmera "corrige" o brilho e estraga o vídeo da prática 7.
- Um vídeo por prática, de 30 s a 1 min. Comece sempre apertando **KEY0 (reset)**.
- Fale o que vai fazer e o que deve acontecer, **antes** de fazer.
- Nomes: `pratica3.mp4`, `pratica7.mp4`, `pratica2_leds.mp4`, `pratica2_motor.mp4`, `extra_morse.mp4`.

Mapa da placa (olhando com os displays para cima):

```
 HEX5 HEX4 HEX3 HEX2 HEX1 HEX0
 LEDR9 .................... LEDR0
 SW9 ...................... SW0      KEY3 KEY2 KEY1 KEY0
```

Os LEDs, chaves e botões de número **0** ficam na **direita**. Chave **para cima = 1**. Botão **apertado** = ativo.

---

## 4. Prática 3: gerador de sinal (2T0 baixo, 6T0 alto)

Arquivo: `pratica3/output_files/pratica3.sof` (já compilado).

1. [ ] Grave o `.sof` (seção 2).
2. [ ] Todas as chaves para baixo.
3. [ ] Comece a filmar e aperte **KEY0**.
4. [ ] Confira:

| O que olhar | Esperado |
|---|---|
| LEDR9 | Pisca rápido (4 vezes por segundo). É o clock da FSM, a referência. |
| LEDR0 | Fica **apagado durante 2 piscadas** do LEDR9 e **aceso durante 6**, e repete. (0,5 s apagado, 1,5 s aceso.) |
| Apertar KEY0 no meio | LEDR0 apaga e o ciclo recomeça do início. |

5. [ ] No vídeo, conte em voz alta: "apagado 1, 2... aceso 1, 2, 3, 4, 5, 6".

**Se der errado:** se LEDR0 nunca mudar, confira se gravou o `.sof` certo (o nome aparece na lista do Programmer).

---

## 5. Prática 7: PWM com ciclo de trabalho x/7

Arquivo: `pratica7/output_files/pratica7.sof` (já compilado).

1. [ ] Grave o `.sof`.
2. [ ] Trave a exposição da câmera em cima do LEDR0 (seção 3).
3. [ ] Comece com **SW2, SW1, SW0 para baixo** e aperte KEY0.
4. [ ] Suba o valor de x devagar e confira:

| SW2 SW1 SW0 | HEX0 | LEDR0 |
|---|---|---|
| 0 0 0 | 0 | apagado |
| 0 0 1 | 1 | bem fraco |
| 0 1 0 | 2 | fraco |
| 0 1 1 | 3 | |
| 1 0 0 | 4 | médio |
| 1 0 1 | 5 | |
| 1 1 0 | 6 | forte |
| 1 1 1 | 7 | brilho máximo (sempre aceso) |

5. [ ] Compare o LEDR0 com os LEDR9..7, que repetem as chaves com brilho total.
6. [ ] Volte de 7 para 0 para mostrar que o brilho desce.

**Se der errado:** se o LED parecer piscar no vídeo, mas não ao vivo, é a câmera (o PWM pisca a ~1 kHz). Ao vivo deve parecer estável.

---

## 6. Prática 2, vídeo A: LEDs (sem motor)

Arquivo: `pratica2/output_files/pratica2.sof` (já compilado).

1. [ ] Grave o `.sof`.
2. [ ] **SW0 para baixo** e aperte KEY0.
3. [ ] Confira:

| Ação | Esperado |
|---|---|
| Depois do reset | Só **LEDR3** aceso (fase A) |
| SW0 para baixo | Um LED aceso "andando": LEDR3 → LEDR2 → LEDR1 → LEDR0 → LEDR3..., 4 passos por segundo |
| SW0 para cima | O LED anda no sentido contrário |
| KEY0 | Volta para LEDR3 |

---

## 7. Prática 2, vídeo B: motor de passo de verdade

### 7.1 Deixar o motor mais rápido

Com 4 passos por segundo o eixo parece parado: esse motor (28BYJ-48) precisa de ~2048 passos para dar uma volta, ou seja, uns 8 minutos por volta. Para o vídeo, gere uma versão rápida:

1. [ ] Abra `pratica2/pratica2_de0cv.vhd` e troque:
   ```vhdl
   generic map (DIVISOR => 6_250_000)
   ```
   por
   ```vhdl
   generic map (DIVISOR => 125_000)
   ```
   Isso dá 50 MHz / (2 × 125 000) = **200 passos por segundo**, cerca de 10 s por volta.
2. [ ] Abra `pratica2/pratica2.qpf` e rode **Processing > Start Compilation**. Tem que terminar sem erros.
3. [ ] **Ainda não grave.** Primeiro ligue os fios.

> No vídeo, explique: "para ver o motor girar, aumentamos o clock da FSM de 4 Hz para 200 Hz; a máquina de estados é a mesma, só muda a velocidade".
> Depois do vídeo, **volte o valor para 6_250_000** e compile de novo, para a apresentação mostrar os LEDs andando devagar.

### 7.2 Ligar os fios

**Desligue a placa (botão vermelho) antes de ligar qualquer fio.**

O motor já vem encaixado na plaquinha verde (driver ULN2003). Só precisa ligar a plaquinha verde no conector **GPIO 0** da DE0-CV (o conector preto grande da esquerda, dos dois da direita da placa).

1. [ ] Ache o **pino 1** do GPIO 0. Procure o número "1" ou uma seta impressa na placa ao lado do conector, ou o pino com a ilha quadrada. Os pinos ímpares (1, 3, 5...) ficam numa fileira e os pares (2, 4, 6...) na outra.
2. [ ] Confira no manual da DE0-CV (figura do conector GPIO, "JP1") que o **pino 11 é 5V** e o **pino 12 é GND**.
3. [ ] Ligue os 6 fios:

| Plaquinha verde | GPIO 0 da DE0-CV | Sinal |
|---|---|---|
| IN1 | pino **4** | fase A |
| IN2 | pino **3** | fase B |
| IN3 | pino **2** | fase C |
| IN4 | pino **1** | fase D |
| **+** (perto do "5-12V") | pino **11** | 5V |
| **−** | pino **12** | GND |

4. [ ] O jumper preto ao lado do "5-12V" da plaquinha verde tem que ficar **colocado**. Ele liga a alimentação do motor.
5. [ ] **Confira duas vezes o fio do 5V.** Ele **nunca** pode encostar nos pinos 1 a 4: os pinos do FPGA são de 3,3 V e queimam com 5 V.
6. [ ] Cole a fita no eixo do motor, como uma bandeirinha, para a rotação aparecer no vídeo.

### 7.3 Testar

1. [ ] Ligue a placa e grave o `.sof` novo (seção 2).
2. [ ] **SW0 para baixo**, aperte KEY0 e comece a filmar.
3. [ ] Confira:

| Ação | Esperado |
|---|---|
| SW0 para baixo | O eixo gira devagar (~1 volta a cada 10 s). Os LEDs A, B, C, D da plaquinha verde piscam em sequência, rápido. |
| SW0 para cima | O eixo gira para o outro lado |
| KEY0 apertado e segurado | O motor para (fica travado na fase A) |

**Se der errado:**

| Sintoma | O que fazer |
|---|---|
| Os LEDs da plaquinha não acendem | Falta alimentação: confira os fios dos pinos 11 e 12 e o jumper do 5-12V. |
| LEDs acendem, mas o motor só vibra ou zumbe | Ordem dos fios IN1..IN4 trocada. Confira a tabela. |
| Motor muito fraco ou parando | Teste `DIVISOR => 250_000` (100 passos/s). |
| O Programmer perde a placa ao ligar o motor | Tire o motor, regrave, e ligue o motor com a placa ligada só depois de conferir os fios. |

Os pinos do FPGA são de 3,3 V e a plaquinha foi feita para 5 V. Normalmente funciona mesmo assim; se nada funcionar com a fiação certa, essa pode ser a causa.

---

## 8. Prática extra: Conversor Morse

### 8.1 Compilar (só na primeira vez)

Essa prática ainda **não tem `.sof`**.

1. [ ] Abra `pratica_extra/morse.qpf`.
2. [ ] **Processing > Start Compilation**. Tem que terminar sem erros.
3. [ ] **Assignments > Pin Planner** e confira estes pinos (os outros são iguais às outras práticas):

| Sinal | Pino |
|---|---|
| KEY[2] | PIN_M7 |
| SW[3] | PIN_T12 |
| SW[4] | PIN_AA15 |
| HEX1[0] a HEX1[6] | AA20, AB20, AA19, AA18, AB18, AA17, U22 |

   Compare com a tabela de pinos do manual da DE0-CV. Se algum estiver diferente, corrija no Pin Planner, compile de novo e avise o grupo.
4. [ ] O arquivo gerado é `pratica_extra/output_files/morse.sof`.

### 8.2 Controles

| Controle | Função |
|---|---|
| KEY0 | Reset |
| KEY1 | Botão Morse |
| KEY2 | Troca o modo (codificar ↔ decodificar) |
| SW4..SW0 | Letra em binário: A = 00000, B = 00001, ..., Z = 11001 |
| HEX1 | `C` = codificar, `d` = decodificar |
| HEX0 | Letra |
| LEDR0 | Sinal Morse |
| LEDR1 | (decodificar) acende quando o aperto já conta como traço |
| LEDR5..2 | (decodificar) um LED por símbolo digitado |
| LEDR9 | aceso = modo decodificar |

Letras úteis:

| Letra | SW4 SW3 SW2 SW1 SW0 | Morse |
|---|---|---|
| A | 0 0 0 0 0 | `.-` |
| E | 0 0 1 0 0 | `.` |
| O | 0 1 1 1 0 | `---` |
| S | 1 0 0 1 0 | `...` |
| T | 1 0 0 1 1 | `-` |

### 8.3 Testar

1. [ ] Grave o `.sof` (seção 2).
2. [ ] Todas as chaves para baixo, aperte KEY0 e comece a filmar.

**Modo codificar:**

| # | Ação | Esperado |
|---|---|---|
| 1 | Depois do reset | HEX1 = `C`, HEX0 = `A`, LEDR9 apagado |
| 2 | Aperte e solte KEY1 | LEDR0: **curto, longo** (A = `.-`) |
| 3 | Chaves em S (10010), KEY1 | 3 piscadas curtas |
| 4 | Chaves em O (01110), KEY1 | 3 piscadas longas |
| 5 | Chaves em S de novo, KEY1 | 3 curtas. Pronto: **SOS** |
| 6 | Segure KEY1 apertado | Só uma letra sai; não repete enquanto segura |
| 7 | Todas as chaves de SW4 a SW0 para cima (11111) | HEX0 = `-`; KEY1 não faz nada |

**Modo decodificar:**

| # | Ação | Esperado |
|---|---|---|
| 8 | Aperte KEY2 | HEX1 = `d`, LEDR9 aceso, HEX0 apagado |
| 9 | Toque KEY1 **3 vezes rápido** e espere 1 s | LEDR2, 3 e 4 acendem um por toque; depois HEX0 = `S` |
| 10 | Segure KEY1 | LEDR0 acompanha o botão; depois de ~0,3 s o **LEDR1** acende. Ao soltar, LEDR1 apaga **na hora** (é a saída de Mealy). |
| 11 | Digite `-.-` (longo, curto, longo) e espere | HEX0 = `K` |
| 12 | Digite `---` | HEX0 = `O` |
| 13 | Digite `..--` | HEX0 = `-` (não existe essa letra) |
| 14 | Aperte KEY2 | Volta para `C` |

Dicas:

- **Ponto é um toque rápido** (menos de 0,3 s). Traço é segurar até o LEDR1 acender.
- Entre os símbolos da mesma letra, não demore: **1 s parado já fecha a letra**.

**Se der errado:**

| Sintoma | O que fazer |
|---|---|
| HEX1 mostra lixo ou nada | Pino do HEX1 errado: confira no Pin Planner (8.1). |
| KEY2 não troca o modo | Pino do KEY[2] errado. |
| Letras erradas no modo codificar com SW3/SW4 | Pinos do SW[3]/SW[4] errados. |
| Pontos viram traços sem querer | Toque mais rápido, ou aumente `LIMIAR_TRACO => 30` para `40` no `morse_de0cv.vhd` e recompile. |

---

## 9. Problemas gerais

| Sintoma | O que fazer |
|---|---|
| O Programmer não mostra "USB-Blaster" | Placa ligada? Cabo USB na entrada **USB BLASTER**? No Windows, abra o Gerenciador de Dispositivos, ache o "USB-Blaster" com aviso amarelo, clique em Atualizar driver e aponte para `C:\intelFPGA_lite\20.1\quartus\drivers`. |
| "Can't access JTAG chain" | Chave **SW10 em RUN**. Desligue e ligue a placa, e feche/abra o Programmer. |
| Start fica vermelho, "Failed" | Confira o Mode = JTAG e se a caixa Program/Configure está marcada. |
| Nada acontece depois de gravar | Aperte KEY0. Confira se gravou o `.sof` da prática certa. |

## 10. Checklist final

- [ ] Print ou vídeo do "100% (Successful)"
- [ ] `pratica3.mp4`
- [ ] `pratica7.mp4`
- [ ] `pratica2_leds.mp4`
- [ ] `pratica2_motor.mp4`
- [ ] `pratica2_de0cv.vhd` voltou para `DIVISOR => 6_250_000` e foi recompilado
- [ ] `extra_morse.mp4`
- [ ] Se algum pino foi corrigido no Pin Planner, avisar o grupo e fazer commit
