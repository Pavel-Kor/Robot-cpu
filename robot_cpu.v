`timescale 1ns/1ps

// ============================================================================
// ОСНОВНОЙ МОДУЛЬ ПРОЦЕССОРА С 8-БИТНЫМИ КОМАНДАМИ
// ============================================================================

module PROCESSOR_CORE(
    input  wire        CLK,              // Тактовый сигнал
    input  wire        RESET,            // Сигнал сброса
    input  wire        SENSOR_DISTANCE,  // Сигнал датчика расстояния (1 - препятствие)
    input  wire        SENSOR_SOUND,     // Сигнал датчика звука (1 - звук)
    output wire        MOTOR_LEFT,       // Управление левым мотором (1 - вперед)
    output wire        MOTOR_RIGHT,      // Управление правым мотором (1 - вперед)
    output wire [3:0]  MEM_ADDR,         // Адрес памяти (4 бита) - 16 ячеек
    input  wire [6:0]  MEM_DATA         // Данные памяти (8 бит) - команда
    //output wire        MEM_READ          // Сигнал чтения памяти (1 - чтение)
);

    // ============================================================================
    // ДЕКОДИРОВАНИЕ КОМАНДЫ
    // ============================================================================
    
    // Формат команды: [7:5] - код операции, [4:0] - операнд
    wire [2:0] OPCODE = MEM_DATA[6:4];  // 3 бита - код операции
    wire [4:0] OPERAND = MEM_DATA[3:0];
    // Разбиение операнда для разных команд:
    wire [3:0] JUMP_ADDR = OPERAND[3:0];    // Для JMP/JS/JD - адрес перехода
    wire [1:0] MOTOR_CTRL = OPERAND[1:0];   // Для OUT - управление моторами
    wire [3:0] WAIT_TIME = OPERAND[3:0];
    // ============================================================================
    // ВНУТРЕННИЕ СИГНАЛЫ ПРОЦЕССОРА
    // ============================================================================
    
    wire CMD_WAIT_N, CMD_OUT, CMD_JMP_N, CMD_JS_N, CMD_JD_N;
    wire WAIT_ACTIVE_N;
    wire SENSOR_DISTANCE_N, SENSOR_SOUND_N;  
    wire PC_LOAD_N, RESET_LOW;
    
    // Сигналы управления состоянием
    //wire FETCH_STATE, EXECUTE_STATE;
    
    // Сигналы управления переходами
    
    INVERTER_74HC04 INVERT_RESET(
        .A1(RESET), .Y1(RESET_LOW),
        .A2(SENSOR_DISTANCE), .Y2(SENSOR_DISTANCE_N),
        .A3(SENSOR_SOUND), .Y3(SENSOR_SOUND_N)
    );
     

    COMMAND_DECODER command_decoder(
        .OPCODE(OPCODE),
        .RESET_LOW(RESET_LOW),
        .CMD_WAIT_N(CMD_WAIT_N),
        .CMD_OUT(CMD_OUT), 
        .CMD_JMP_N(CMD_JMP_N),
        .CMD_JS_N(CMD_JS_N),
        .CMD_JD_N(CMD_JD_N)
    );

    // ============================================================================
    // МОДУЛЬ УПРАВЛЕНИЯ ПЕРЕХОДАМИ
    // ============================================================================
    // Назначение: Определяет условия выполнения переходов и управляет счетчиком
    // Как работает: Проверяет условия для условных переходов (JS/JD) и выдает сигналы управления PC
    // Verilog-эквивалент:
    //   assign jump_condition = CMD_JMP | (CMD_JS & SENSOR_SOUND) | (CMD_JD & SENSOR_DISTANCE);
    //   assign PC_LOAD = jump_condition & EXECUTE_STATE;
    //   assign PC_ENABLE_BASE = EXECUTE_STATE;
    
    JUMP_MANAGER jump_manager(
        .CMD_JMP_N(CMD_JMP_N),
        .CMD_JS_N(CMD_JS_N),
        .CMD_JD_N(CMD_JD_N),
        .SENSOR_DISTANCE_N(SENSOR_DISTANCE_N),
        .SENSOR_SOUND_N(SENSOR_SOUND_N),
        .PC_LOAD_N(PC_LOAD_N)
    );


    PROGRAM_COUNTER program_counter(
        .CLK(CLK),
        .RESET_LOW(RESET_LOW),
        .WAIT_ACTIVE_N(WAIT_ACTIVE_N),
        .PC_LOAD_N(PC_LOAD_N),
        .JUMP_ADDR(JUMP_ADDR),
        .MEM_ADDR(MEM_ADDR)
    );


    MOTOR_MANAGER motor_manager(
        .CMD_OUT(CMD_OUT),
        .RESET_LOW(RESET_LOW),
        .MOTOR_CTRL(MOTOR_CTRL),
        .MOTOR_LEFT(MOTOR_LEFT),
        .MOTOR_RIGHT(MOTOR_RIGHT)
    );


    DELAY_MANAGER delay_manager(
        .CMD_WAIT_N(CMD_WAIT_N),
        .CLK(CLK),
        .WAIT_TIME(WAIT_TIME),
        .WAIT_ACTIVE_N(WAIT_ACTIVE_N)
    );

 
    //   assign MEM_READ = FETCH_STATE;

endmodule

module PROGRAM_COUNTER(
    input  wire CLK,
    input  wire RESET_LOW,
    input  wire WAIT_ACTIVE_N,
    input  wire PC_LOAD_N, 
    input  wire [3:0] JUMP_ADDR,
    output wire [3:0] MEM_ADDR
);

    COUNTER_4BIT_74HC161 pc_counter(
        .MR(RESET_LOW),           // Сброс (активный низкий)
        .CLK(CLK),             // Тактовый сигнал  
        .ENP(1'b1),       // Разрешение счета от контроля состояни ???????????????????????????????
        .ENT(WAIT_ACTIVE_N),            // Отсутствие задержки
        .LOAD(PC_LOAD_N),       // Загрузка (активный низкий)
        .D0(JUMP_ADDR[0]), .D1(JUMP_ADDR[1]), .D2(JUMP_ADDR[2]), .D3(JUMP_ADDR[3]),
        .Q0(MEM_ADDR[0]), .Q1(MEM_ADDR[1]), .Q2(MEM_ADDR[2]), .Q3(MEM_ADDR[3]),
        .RCO()
    );
endmodule


module COMMAND_DECODER(
    input  wire [2:0] OPCODE,
    input wire RESET_LOW,
    output wire CMD_WAIT_N,
    output wire CMD_OUT,
    output wire CMD_JMP_N, 
    output wire CMD_JS_N,
    output wire CMD_JD_N
);

    wire [7:0] decryptor_out_bus;
    wire CMD_OUT_N;

    DECRYPTOR_74HC138 command_decoder(
        .A(OPCODE),
        .E1_n(1'b0),
        .E2_n(1'b0),
        .E3(RESET_LOW),
        .Y_n(decryptor_out_bus)
    );

    
    assign {CMD_JD_N, CMD_JMP_N, CMD_JS_N, CMD_OUT_N, CMD_WAIT_N} = decryptor_out_bus[4:0];

    INVERTER_74HC04 Invert_cmd(
        .A1(CMD_OUT_N), .Y1(CMD_OUT)
    );
endmodule


module JUMP_MANAGER(
    input  wire CMD_JMP_N,
    input  wire CMD_JS_N, 
    input  wire CMD_JD_N,
    input  wire SENSOR_DISTANCE_N,
    input  wire SENSOR_SOUND_N,
    output wire PC_LOAD_N
);

    // Внутренние сигналы
    wire jump_distance_temp_n;
    wire jump_sound_temp_n;
    wire jump_conddition_n;
    
    AND_GATE_74HC08 jump_controller(
        .A1(jump_sound_temp_n), .B1(jump_distance_temp_n), .Y1(jump_conddition_n), // sound or distance condition +
        .A2(jump_conddition_n), .B2(CMD_JMP_N), .Y2(PC_LOAD_N) // Управление загрузкой счетчика
        
    );

    OR_GATE_74HC32 jump_controller_or(
        .A1(CMD_JD_N), .B1(SENSOR_DISTANCE_N), .Y1(jump_distance_temp_n), // Условный переход по расстоянию

        
        .A2(CMD_JS_N), .B2(SENSOR_SOUND_N), .Y2(jump_sound_temp_n) // Условный переход по sound 
    );
endmodule


module MOTOR_MANAGER(
    input  wire CMD_OUT,
    input  wire [1:0] MOTOR_CTRL,
    input  wire RESET_LOW, 
    output wire MOTOR_LEFT,
    output wire MOTOR_RIGHT
);

    wire motor_left_forward, motor_right_forward;

    D_FLIPFLOP_74HC74 REGISTR_OUT_MOTOR(
    .CLK1(CMD_OUT),            // Команда обновить значения
    .RESET1(RESET_LOW),       // Асинхронный сброс первого триггера (активный LOW) - Reset 1
    .D1(MOTOR_CTRL[0]),      // Вход данных первого триггера - Data 1
    .Q1(MOTOR_LEFT),        // Прямой выход первого триггера - Output 1    
    .CLK2(CMD_OUT),        // Команда обновить значения
    .RESET2(RESET_LOW),   // Асинхронный сброс второго триггера (активный LOW) - Reset 2
    .D2(MOTOR_CTRL[1]),  // Вход данных второго триггера - Data 2
    .Q2(MOTOR_RIGHT)    // Прямой выход второго триггера - Output 2
);
endmodule

module DELAY_MANAGER(
    input  wire CMD_WAIT_N,
    input wire  CLK, 
    input wire [3:0] WAIT_TIME,
    output wire WAIT_ACTIVE_N
);

    wire [3:0] time_up;
    wire [3:0] compare_time;
    wire [1:0] temporary_comparer;
    wire wait_act, wait_act_n;

    IC_74HC4060_COUNT DELAY_COUNT(
    .CLK_IN(CLK),        // Clock Input (pin 9) - тактовый вход
    .CLK_INHIBIT(1'b0),   // Clock Inhibit (pin 10) - запрет тактирования
    .RESET(CMD_WAIT_N),         // Reset (pin 11) - асинхронный сброс
    .Q8(time_up[0]),
    .Q9(time_up[1]),
    .Q10(time_up[2]),
    .Q12(time_up[3])
    );

    XOR_GATE_74HC86 COMPARE_TIME(
        .A1(time_up[0]), .B1(WAIT_TIME[0]), .Y1(compare_time[0]),
        .A2(time_up[1]), .B2(WAIT_TIME[1]), .Y2(compare_time[1]),
        .A3(time_up[2]), .B3(WAIT_TIME[2]), .Y3(compare_time[2]),
        .A4(time_up[3]), .B4(WAIT_TIME[3]), .Y4(compare_time[3])
    );

    OR_GATE_74HC32 LOGIC_DELAY(
        .A1(compare_time[0]), .B1(compare_time[1]), .Y1(temporary_comparer[0]),
        .A2(compare_time[2]), .B2(compare_time[3]), .Y2(temporary_comparer[1]),
        .A3(temporary_comparer[0]), .B3(temporary_comparer[1]), .Y3(wait_act),
        .A4(wait_act_n), .B4(CMD_WAIT_N), .Y4(WAIT_ACTIVE_N)
    );

    
    INVERTER_74HC04 Invert_DELAY_LOGIC(
        .A1(wait_act), .Y1(wait_act_n)
    );

endmodule