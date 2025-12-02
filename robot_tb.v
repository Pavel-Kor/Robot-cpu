`timescale 1ns/1ps

module PROCESSOR_CORE_TB;

    // ============================================================================
    // ОБЪЯВЛЕНИЕ СИГНАЛОВ
    // ============================================================================
    
    reg CLK;
    reg RESET;
    reg SENSOR_DISTANCE;
    reg SENSOR_SOUND;
    wire MOTOR_LEFT;
    wire MOTOR_RIGHT;
    wire [3:0] MEM_ADDR;
    wire [6:0] MEM_DATA;
    
    // Память (16 ячеек по 8 бит)
    reg [6:0] memory [0:15];
    
    // Внутренние сигналы для мониторинга
    wire [2:0] OPCODE;
    wire [3:0] OPERAND;
    wire [3:0] JUMP_ADDR;
    wire [1:0] MOTOR_CTRL;
    wire [3:0] WAIT_TIME;
    wire CMD_WAIT_N, CMD_OUT, CMD_JMP_N, CMD_JS_N, CMD_JD_N;
    wire WAIT_ACTIVE_N;
    wire SENSOR_DISTANCE_N, SENSOR_SOUND_N;
    wire PC_LOAD_N, RESET_LOW;
    
    // ============================================================================
    // ИНИЦИАЛИЗАЦИЯ ПАМЯТИ (все ячейки = 8'b11111111)
    // ============================================================================
    
    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            memory[i] = 7'b1111111;
        end
    end
    
    assign MEM_DATA = memory[MEM_ADDR];
    
    // ============================================================================
    // ПОДКЛЮЧЕНИЕ ИСПЫТУЕМОГО УСТРОЙСТВА
    // ============================================================================
    
    PROCESSOR_CORE dut (
        .CLK(CLK),
        .RESET(RESET),
        .SENSOR_DISTANCE(SENSOR_DISTANCE),
        .SENSOR_SOUND(SENSOR_SOUND),
        .MOTOR_LEFT(MOTOR_LEFT),
        .MOTOR_RIGHT(MOTOR_RIGHT),
        .MEM_ADDR(MEM_ADDR),
        .MEM_DATA(MEM_DATA)
    );
    
    // ============================================================================
    // ПОДКЛЮЧЕНИЕ К ВНУТРЕННИМ СИГНАЛАМ
    // ============================================================================
    
    assign OPCODE = dut.OPCODE;
    assign OPERAND = dut.OPERAND;
    assign JUMP_ADDR = dut.JUMP_ADDR;
    assign MOTOR_CTRL = dut.MOTOR_CTRL;
    assign CMD_WAIT_N = dut.CMD_WAIT_N;
    assign CMD_OUT = dut.CMD_OUT;
    assign CMD_JMP_N = dut.CMD_JMP_N;
    assign CMD_JS_N = dut.CMD_JS_N;
    assign CMD_JD_N = dut.CMD_JD_N;
    assign WAIT_ACTIVE_N = dut.WAIT_ACTIVE_N;
    assign SENSOR_DISTANCE_N = dut.SENSOR_DISTANCE_N;
    assign SENSOR_SOUND_N = dut.SENSOR_SOUND_N;
    assign PC_LOAD_N = dut.PC_LOAD_N;
    assign RESET_LOW = dut.RESET_LOW;
    assign WAIT_TIME = dut.WAIT_TIME;
    
    // ============================================================================
    // ГЕНЕРАЦИЯ ТАКТОВОГО СИГНАЛА
    // ============================================================================
    
    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;  // Период 20ns (50 MHz)
    end
    
    // ============================================================================
    // ВЫВОД ТАБЛИЦЫ С ЗАГОЛОВКАМИ
    // ============================================================================
    
    integer cycle_count = 0;
    
    // Функция для вывода заголовков таблицы
    task print_header;
        begin
            $display("==========================================================================================================================================================================================================================================");
            $display("                                                          ТАБЛИЦА СИГНАЛОВ ПРОЦЕССОРА");
            $display("==========================================================================================================================================================================================================================================");
            $display("Такт | MEM_ADDR | MEM_DATA  | OPCODE | OPERAND  | JMP_ADDR  | MTR_CTRL | CMD_WAIT_N | CMD_OUT |  CMD_JMP_N | CMD_JS_N   | CMD_JD_N  | WAIT_ACT_N   | SENS_DIST_N  | SENS_SOUND_N  | PC_LOAD_N  | RESET_LOW | M_LEFT  | M_RIGHT | SENS_D |SENS_S| RESET | WAIT_TIME");
            $display("-----|----------|------_----|--------|----_-----|-----------|----------|------------|---------|------------|------------|------------|-------------|--------------|---------------|------------|-----------|---------|---------|--------|------|-------|----------");
        end
    endtask
    
    // Печать заголовков таблицы
    initial begin
        
    // ПРОГРАММА ДЛЯ ПРОЦЕССОРА УПРАВЛЕНИЯ РОБОТОМ
// Адреса памяти: 0-15 (16 ячеек)

// ============================================================================
// ИНИЦИАЛИЗАЦИЯ ПАМЯТИ ПРОГРАММ
// ============================================================================

    // Адрес 0: START - Движение вперед
    memory[0]  = 7'b0011111; // OUT 0011 - вперед

    // Адрес 1: CHECK_SOUND
    memory[1]  = 7'b0100100; // JS 0100 → STOP если звук

    // Адрес 2: CHECK_OBSTACLE  
    memory[2]  = 7'b1001000; // JD 0110 → TURN_RIGHT если препятствие

    // Адрес 3: CONTINUE
    memory[3]  = 7'b0110001; // JMP 0001 → JS

    // Адрес 4: STOP
    memory[4]  = 7'b0010000; // OUT 0000 - остановка
    // Адрес 5: WAIT_SOUND_LOOP
    memory[5]  = 7'b0000111; // wait end of sound
    memory[6]  = 7'b0101101; // JS 0010 → wait
    memory[7]  = 7'b0110110; // JMP 0101 → WAIT_SOUND_LOOP

    // Адрес 7: TURN_RIGHT
    memory[8]  = 7'b0011101; // OUT 0001 - направо
    memory[9]  = 7'b0000111; // WAIT 1111 - задержка поворота

    // Адрес 9: FORWARD_AFTER_TURN
    memory[10] = 7'b0011111; // OUT 0011 - вперед
    memory[11] = 7'b0000111; // WAIT 1111 - задержка движения

    // Адрес 11: TURN_LEFT
    memory[12] = 7'b0011110; // OUT 0010 - налево
    memory[13] = 7'b0000111; // WAIT 1111 - задержка поворота

    // Адрес 13: RETURN_TO_MAIN
    memory[14] = 7'b0110000; // JMP 00 → START

    // Адрес 14: (резерв)
    memory[15] = 7'b1111111; // NOP

        print_header();
    end
    
    // Вывод состояния на каждом отрицательном фронте такта
    always @(negedge CLK) begin
        // Выводим заголовок каждые 10 тактов
        if (cycle_count % 10 == 0 && cycle_count > 0) begin
            print_header();
        end
        
        $display("%4d |      %2d   | %7b |   %3b  |   %4b  |     %2d    |    %2b    |      %1b     |    %1b    |      %1b     |      %1b     |      %1b     |      %1b      |       %1b      |       %1b       |      %1b     |      %1b    |    %1b    |     %1b   |    %1b   |   %1b  |    %1b  |   %4b",
                 cycle_count,
                 MEM_ADDR,
                 MEM_DATA,
                 OPCODE,
                 OPERAND,
                 JUMP_ADDR,
                 MOTOR_CTRL,
                 CMD_WAIT_N,
                 CMD_OUT,
                 CMD_JMP_N,
                 CMD_JS_N,
                 CMD_JD_N,
                 WAIT_ACTIVE_N,
                 SENSOR_DISTANCE_N,
                 SENSOR_SOUND_N,
                 PC_LOAD_N,
                 RESET_LOW,
                 MOTOR_LEFT,
                 MOTOR_RIGHT,
                 SENSOR_DISTANCE,
                 SENSOR_SOUND,
                 RESET, WAIT_TIME);
        cycle_count = cycle_count + 1;
    end
    
    // ============================================================================
    // СЦЕНАРИЙ ТЕСТИРОВАНИЯ
    // ============================================================================
    
    initial begin
        // Инициализация
        $dumpfile("processor.vcd");
        $dumpvars(0, PROCESSOR_CORE_TB);
        
        RESET = 1;
        SENSOR_DISTANCE = 0;
        SENSOR_SOUND = 0;
        
        // Сброс
        #6 RESET = 0;
        
        // Тест 1: Работа с памятью 11111111
        #200;
        
        // Тест 2: Изменение состояния сенсоров
        SENSOR_DISTANCE = 1;
        #10;
        SENSOR_DISTANCE = 0;
        #200
        SENSOR_SOUND = 1;
        #5;
        SENSOR_SOUND = 0;
        #10;
        SENSOR_SOUND = 1;
        #3;
        SENSOR_SOUND = 0;
        #40;
        // Тест 3: Еще один сброс
        #50 RESET = 0;
        #30 RESET = 1;
        
        // Завершение симуляции
        #200;
        $display("==========================================================================================================================================================================================================================================");
        $display("Симуляция завершена после %0d тактов", cycle_count);
        $finish;
    end
    
    // ============================================================================
    // МОНИТОРИНГ ИЗМЕНЕНИЙ ПАМЯТИ
    // ============================================================================
    
    always @(MEM_ADDR) begin
        if (cycle_count > 0) begin
            $display("                    [Память] Адрес %2d: данные = %8b", MEM_ADDR, MEM_DATA);
        end
    end
    
    // Мониторинг изменений сенсоров
    always @(SENSOR_DISTANCE or SENSOR_SOUND) begin
        if (cycle_count > 0) begin
            $display("                    [Сенсоры] DISTANCE=%1b, SOUND=%1b", SENSOR_DISTANCE, SENSOR_SOUND);
        end
    end
    
    // Мониторинг сброса
    always @(RESET) begin
        if (cycle_count > 0) begin
            $display("                    [Сброс] RESET=%1b", RESET);
        end
    end

endmodule