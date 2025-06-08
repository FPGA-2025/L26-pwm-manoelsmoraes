module PWM (
    input wire clk,              // Clock do sistema
    input wire rst_n,            // Reset assíncrono ativo em nível baixo
    input wire [15:0] duty_cycle, // Duty cycle: tempo em que a saída permanece alta
    input wire [15:0] period,     // Período total do sinal PWM
    output reg pwm_out            // Saída PWM
);

    reg [15:0] counter; // Contador interno para contar o tempo dentro de cada ciclo

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset: zera contador e a saída PWM
            counter  <= 0;
            pwm_out  <= 0;
        end else begin
            // Incrementa o contador até o valor do período
            if (counter < period - 1)
                counter <= counter + 1;
            else
                counter <= 0; // Reinicia o contador quando chega ao final do ciclo

            // Compara o contador com o duty_cycle para gerar a saída PWM
            if (counter < duty_cycle)
                pwm_out <= 1; // Mantém a saída alta durante o tempo do duty_cycle
            else
                pwm_out <= 0; // Resto do ciclo permanece em nível baixo
        end
    end

endmodule
