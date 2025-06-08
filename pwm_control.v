module PWM_Control #(
    parameter CLK_FREQ = 25_000_000,  // Frequência do clock da placa
    parameter PWM_FREQ = 1250         // Frequência do sinal PWM (1.25 kHz)
)(
    input  wire clk,      // Clock do sistema
    input  wire rst_n,    // Reset assíncrono ativo em nível baixo
    output wire [7:0] leds // Saída para os LEDs
);

    // Cálculo do período necessário para gerar a frequência PWM desejada
    localparam integer PWM_PERIOD = CLK_FREQ / PWM_FREQ;

    // Valores mínimo e máximo de duty_cycle para o efeito fade
    localparam integer DUTY_MIN = 1; // ~0.0025%
    localparam integer DUTY_MAX = (PWM_PERIOD * 70) / 100; // 70% do período

    reg [15:0] duty_cycle;   // Duty cycle atual
    reg [15:0] period;       // Período fixo da onda PWM
    reg        dir;          // Direção do fade: 0 = aumentando, 1 = diminuindo
    reg [24:0] time_counter; // Contador para temporizar as mudanças de brilho

    wire pwm_signal;         // Sinal PWM gerado pelo módulo PWM

    // Instancia o módulo PWM
    PWM pwm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_cycle),
        .period(period),
        .pwm_out(pwm_signal)
    );

    // Espelha o sinal PWM nos 8 LEDs
    assign leds = {8{pwm_signal}};

    // Controle da transição de brilho (fade in/out)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Inicializa os valores no reset
            duty_cycle   <= DUTY_MIN;
            period       <= PWM_PERIOD;
            dir          <= 0; // Começa aumentando o brilho
            time_counter <= 0;
        end else begin
            // Incrementa o contador de tempo
            time_counter <= time_counter + 1;

            // Altera o duty_cycle a cada 1ms (~25.000 ciclos)
            if (time_counter >= (CLK_FREQ / 1000)) begin
                time_counter <= 0; // Reinicia contador de tempo

                if (!dir) begin
                    // Aumentando o brilho
                    if (duty_cycle < DUTY_MAX)
                        duty_cycle <= duty_cycle + 1;
                    else
                        dir <= 1; // Alcançou o máximo → começa a diminuir
                end else begin
                    // Diminuindo o brilho
                    if (duty_cycle > DUTY_MIN)
                        duty_cycle <= duty_cycle - 1;
                    else
                        dir <= 0; // Alcançou o mínimo → começa a aumentar
                end
            end
        end
    end

endmodule
