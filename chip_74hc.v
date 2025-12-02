`timescale 1ns/1ps

// ============================================================================
// БАЗОВЫЕ МИКРОСХЕМЫ СЕРИИ 74HC (РЕАЛЬНЫЕ КОРПУСА)
// ============================================================================

// Четырехразрядный синхронный счетчик 74HC161
module COUNTER_4BIT_74HC161(
    input  wire MR,      // Сброс (активный 0) - Master Reset
    input  wire CLK,     // Тактовый сигнал - Clock input
    input  wire ENP,     // Разрешение счета P - Enable Parallel
    input  wire ENT,     // Разрешение счета T - Enable Trickle
    input  wire LOAD,    // Загрузка данных (активный 0) - Parallel Load
    input  wire D0,      // Младший бит данных - Data input bit 0
    input  wire D1,      // Бит данных 1 - Data input bit 1
    input  wire D2,      // Бит данных 2 - Data input bit 2
    input  wire D3,      // Старший бит данных - Data input bit 3
    output wire Q0,      // Младший бит выхода - Output bit 0
    output wire Q1,      // Бит выхода 1 - Output bit 1
    output wire Q2,      // Бит выхода 2 - Output bit 2
    output wire Q3,      // Старший бит выхода - Output bit 3
    output wire RCO      // Выход переноса - Ripple Carry Output
);

    reg [3:0] count = 4'b0000;  // Внутренний 4-битный регистр счетчика
    
    // Процесс счетчика: срабатывает по фронту такта или сбросу
    always @(posedge CLK or negedge MR) begin
        if (!MR) begin
            count <= 4'b0000;  // При сбросе - обнуление счетчика
        end else if (!LOAD) begin
            count <= {D3, D2, D1, D0};  // Загрузка данных при активном LOAD
        end else if (ENP && ENT) begin
            count <= count + 1'b1;  // Инкремент при разрешении счета
        end
    end
    
    assign {Q3, Q2, Q1, Q0} = count;  // Назначение выходов счетчика
    assign RCO = (count == 4'b1111) && ENT;  // Перенос при достижении 15

endmodule

// Двойной D-триггер с установкой и сбросом 74HC74
module D_FLIPFLOP_74HC74(
    input  wire CLK1,     // Тактовый вход первого триггера - Clock 1
    input  wire RESET1,   // Асинхронный сброс первого триггера (активный LOW) - Reset 1
    input  wire D1,       // Вход данных первого триггера - Data 1
    output reg Q1,        // Прямой выход первого триггера - Output 1
    output reg Q1_N,    // Инверсный выход первого триггера - Inverted Output 1
    
    input  wire CLK2,     // Тактовый вход второго триггера - Clock 2
    input  wire RESET2,   // Асинхронный сброс второго триггера (активный LOW) - Reset 2
    input  wire D2,       // Вход данных второго триггера - Data 2
    output reg Q2,        // Прямой выход второго триггера - Output 2
    output reg Q2_N     // Инверсный выход второго триггера - Inverted Output 2
);

    // Первый D-триггер с асинхронным сбросом
    always @(posedge CLK1 or negedge RESET1) begin
        if (!RESET1) begin
            Q1 <= 1'b0;      // При сбросе - выход в 0
            Q1_N <= 1'b1;  // Инверсный выход в 1
        end else begin
            Q1 <= D1;        // По фронту такта - защелкиваем данные
            Q1_N <= ~D1;   // Инверсные данные
        end
    end

    // Второй D-триггер с асинхронным сбросом
    always @(posedge CLK2 or negedge RESET2) begin
        if (!RESET2) begin
            Q2 <= 1'b0;      // При сбросе - выход в 0
            Q2_N <= 1'b1;  // Инверсный выход в 1
        end else begin
            Q2 <= D2;        // По фронту такта - защелкиваем данные
            Q2_N <= ~D2;   // Инверсные данные
        end
    end

endmodule

// Четырехканальный логический элемент И 74HC08
module AND_GATE_74HC08(
    input  wire A1,  // Вход A первого элемента - Input A1
    input  wire B1,  // Вход B первого элемента - Input B1
    output wire Y1,  // Выход первого элемента - Output Y1 (A1 AND B1)
    
    input  wire A2,  // Вход A второго элемента - Input A2
    input  wire B2,  // Вход B второго элемента - Input B2
    output wire Y2,  // Выход второго элемента - Output Y2 (A2 AND B2)
    
    input  wire A3,  // Вход A третьего элемента - Input A3
    input  wire B3,  // Вход B третьего элемента - Input B3
    output wire Y3,  // Выход третьего элемента - Output Y3 (A3 AND B3)
    
    input  wire A4,  // Вход A четвертого элемента - Input A4
    input  wire B4,  // Вход B четвертого элемента - Input B4
    output wire Y4   // Выход четвертого элемента - Output Y4 (A4 AND B4)
);

    assign Y1 = A1 & B1;  // Логическое И для первого канала
    assign Y2 = A2 & B2;  // Логическое И для второго канала
    assign Y3 = A3 & B3;  // Логическое И для третьего канала
    assign Y4 = A4 & B4;  // Логическое И для четвертого канала

endmodule

// Четырехканальный логический элемент ИЛИ 74HC32
module OR_GATE_74HC32(
    input  wire A1,  // Вход A первого элемента - Input A1
    input  wire B1,  // Вход B первого элемента - Input B1
    output wire Y1,  // Выход первого элемента - Output Y1 (A1 OR B1)
    
    input  wire A2,  // Вход A второго элемента - Input A2
    input  wire B2,  // Вход B второго элемента - Input B2
    output wire Y2,  // Выход второго элемента - Output Y2 (A2 OR B2)
    
    input  wire A3,  // Вход A третьего элемента - Input A3
    input  wire B3,  // Вход B третьего элемента - Input B3
    output wire Y3,  // Выход третьего элемента - Output Y3 (A3 OR B3)
    
    input  wire A4,  // Вход A четвертого элемента - Input A4
    input  wire B4,  // Вход B четвертого элемента - Input B4
    output wire Y4   // Выход четвертого элемента - Output Y4 (A4 OR B4)
);

    assign Y1 = A1 | B1;  // Логическое ИЛИ для первого канала
    assign Y2 = A2 | B2;  // Логическое ИЛИ для второго канала
    assign Y3 = A3 | B3;  // Логическое ИЛИ для третьего канала
    assign Y4 = A4 | B4;  // Логическое ИЛИ для четвертого канала

endmodule

// Шестиканальный инвертор 74HC04
module INVERTER_74HC04(
    input  wire A1,  // Вход первого инвертора - Input A1
    output wire Y1,  // Выход первого инвертора - Output Y1 (NOT A1)
    
    input  wire A2,  // Вход второго инвертора - Input A2
    output wire Y2,  // Выход второго инвертора - Output Y2 (NOT A2)
    
    input  wire A3,  // Вход третьего инвертора - Input A3
    output wire Y3,  // Выход третьего инвертора - Output Y3 (NOT A3)
    
    input  wire A4,  // Вход четвертого инвертора - Input A4
    output wire Y4,  // Выход четвертого инвертора - Output Y4 (NOT A4)
    
    input  wire A5,  // Вход пятого инвертора - Input A5
    output wire Y5,  // Выход пятого инвертора - Output Y5 (NOT A5)
    
    input  wire A6,  // Вход шестого инвертора - Input A6
    output wire Y6   // Выход шестого инвертора - Output Y6 (NOT A6)
);

    assign Y1 = ~A1;  // Инверсия для первого канала
    assign Y2 = ~A2;  // Инверсия для второго канала
    assign Y3 = ~A3;  // Инверсия для третьего канала
    assign Y4 = ~A4;  // Инверсия для четвертого канала
    assign Y5 = ~A5;  // Инверсия для пятого канала
    assign Y6 = ~A6;  // Инверсия для шестого канала

endmodule

// Четырехканальный логический элемент И-НЕ 74HC00
module NAND_GATE_74HC00(
    input  wire A1,  // Вход A первого элемента - Input A1
    input  wire B1,  // Вход B первого элемента - Input B1
    output wire Y1,  // Выход первого элемента - Output Y1 (A1 NAND B1)
    
    input  wire A2,  // Вход A второго элемента - Input A2
    input  wire B2,  // Вход B второго элемента - Input B2
    output wire Y2,  // Выход второго элемента - Output Y2 (A2 NAND B2)
    
    input  wire A3,  // Вход A третьего элемента - Input A3
    input  wire B3,  // Вход B третьего элемента - Input B3
    output wire Y3,  // Выход третьего элемента - Output Y3 (A3 NAND B3)
    
    input  wire A4,  // Вход A четвертого элемента - Input A4
    input  wire B4,  // Вход B четвертого элемента - Input B4
    output wire Y4   // Выход четвертого элемента - Output Y4 (A4 NAND B4)
);

    assign Y1 = ~(A1 & B1);  // Логическое И-НЕ для первого канала
    assign Y2 = ~(A2 & B2);  // Логическое И-НЕ для второго канала
    assign Y3 = ~(A3 & B3);  // Логическое И-НЕ для третьего канала
    assign Y4 = ~(A4 & B4);  // Логическое И-НЕ для четвертого канала

endmodule

// Четырехканальный логический элемент ИЛИ-НЕ 74HC02
module NOR_GATE_74HC02(
    input  wire A1,  // Вход A первого элемента - Input A1
    input  wire B1,  // Вход B первого элемента - Input B1
    output wire Y1,  // Выход первого элемента - Output Y1 (A1 NOR B1)
    
    input  wire A2,  // Вход A второго элемента - Input A2
    input  wire B2,  // Вход B второго элемента - Input B2
    output wire Y2,  // Выход второго элемента - Output Y2 (A2 NOR B2)
    
    input  wire A3,  // Вход A третьего элемента - Input A3
    input  wire B3,  // Вход B третьего элемента - Input B3
    output wire Y3,  // Выход третьего элемента - Output Y3 (A3 NOR B3)
    
    input  wire A4,  // Вход A четвертого элемента - Input A4
    input  wire B4,  // Вход B четвертого элемента - Input B4
    output wire Y4   // Выход четвертого элемента - Output Y4 (A4 NOR B4)
);

    assign Y1 = ~(A1 | B1);  // Логическое ИЛИ-НЕ для первого канала
    assign Y2 = ~(A2 | B2);  // Логическое ИЛИ-НЕ для второго канала
    assign Y3 = ~(A3 | B3);  // Логическое ИЛИ-НЕ для третьего канала
    assign Y4 = ~(A4 | B4);  // Логическое ИЛИ-НЕ для четвертого канала

endmodule

module XOR_GATE_74HC86(
    input  wire A1,  // Вход A первого элемента - Input A1
    input  wire B1,  // Вход B первого элемента - Input B1
    output wire Y1,  // Выход первого элемента - Output Y1 (A1 XOR B1)
    
    input  wire A2,  // Вход A второго элемента - Input A2
    input  wire B2,  // Вход B второго элемента - Input B2
    output wire Y2,  // Выход второго элемента - Output Y2 (A2 XOR B2)
    
    input  wire A3,  // Вход A третьего элемента - Input A3
    input  wire B3,  // Вход B третьего элемента - Input B3
    output wire Y3,  // Выход третьего элемента - Output Y3 (A3 XOR B3)
    
    input  wire A4,  // Вход A четвертого элемента - Input A4
    input  wire B4,  // Вход B четвертого элемента - Input B4
    output wire Y4   // Выход четвертого элемента - Output Y4 (A4 XOR B4)
);

    assign Y1 = A1 ^ B1;  // Логическое ИСКЛЮЧАЮЩЕЕ ИЛИ для первого канала
    assign Y2 = A2 ^ B2;  // Логическое ИСКЛЮЧАЮЩЕЕ ИЛИ для второго канала
    assign Y3 = A3 ^ B3;  // Логическое ИСКЛЮЧАЮЩЕЕ ИЛИ для третьего канала
    assign Y4 = A4 ^ B4;  // Логическое ИСКЛЮЧАЮЩЕЕ ИЛИ для четвертого канала

endmodule


module IC_74HC4060_COUNT (
    input wire CLK_IN,        // Clock Input (pin 9) - тактовый вход
    input wire CLK_INHIBIT,   // Clock Inhibit (pin 10) - запрет тактирования
    input wire RESET,         // Reset (pin 11) - асинхронный сброс
    output wire Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14 // Выходы счётчика
);

// ==================== НАЗНАЧЕНИЕ ВЫВОДОВ ====================
//
// CLK_IN (pin 9)     - Вход тактовых импульсов. Счётчик увеличивается 
//                      по ВОЗРАСТАЮЩЕМУ фронту этого сигнала
//
// CLK_INHIBIT (pin 10) - Запрет тактирования. Когда =1, счётчик останавливается
//                      Когда =0, счётчик работает нормально
//
// RESET (pin 11)     - Асинхронный сброс (активный HIGH). Когда =1, 
//                      счётчик немедленно сбрасывается в 0
//
// Q4-Q14 (pins 1-7,12-15) - Выходы счётчика. Каждый выход соответствует
//                      определённому биту счётчика и меняет состояние
//                      каждые 2^N тактов (где N = номер выхода)
//
// ==================== РЕАЛЬНЫЕ ВЫХОДЫ 74HC4060 ====================
// Q1, Q2, Q3 - НЕ ВЫВЕДЕНЫ на корпус! Доступны только Q4-Q14
//

// 14-битный внутренний счётчик
reg [13:0] counter = 14'b0;

// Основной счётчик - работает на ВОЗРАСТАЮЩЕМ фронте CLK_IN
always @(posedge CLK_IN or posedge RESET) begin
    if (RESET) begin
        // Асинхронный сброс - немедленно в 0
        counter <= 14'b0;
    end else if (!CLK_INHIBIT) begin
        // Инкремент счётчика, только если CLK_INHIBIT = 0
        counter <= counter + 1;
    end
end

// ==================== ПОДКЛЮЧЕНИЕ РЕАЛЬНЫХ ВЫХОДОВ ====================
// В реальной микросхеме доступны только выходы Q4-Q14
// Q1, Q2, Q3 не выведены на корпус!

assign Q4  = counter[3];   // Деление на 16   (2^4)
assign Q5  = counter[4];   // Деление на 32   (2^5)  
assign Q6  = counter[5];   // Деление на 64   (2^6)
assign Q7  = counter[6];   // Деление на 128  (2^7)
assign Q8  = counter[7];   // Деление на 256  (2^8)
assign Q9  = counter[8];   // Деление на 512  (2^9)
assign Q10 = counter[9];   // Деление на 1024 (2^10)
assign Q11 = counter[10];  // Деление на 2048 (2^11)
assign Q12 = counter[11];  // Деление на 4096 (2^12)
assign Q13 = counter[12];  // Деление на 8192 (2^13)
assign Q14 = counter[13];  // Деление на 16384 (2^14)

endmodule

module DECRYPTOR_74HC138 (
    input wire [2:0] A,     // Адресные входы A[2:0]
    input wire E1_n,        // Разрешение 1 (active low)
    input wire E2_n,        // Разрешение 2 (active low) 
    input wire E3,          // Разрешение 3 (active high)
    output reg [7:0] Y_n    // Выходы (active low)
);

    always @(*) begin
        if (E3 && !E1_n && !E2_n) begin
            Y_n = ~(8'b00000001 << A); // Сдвиг единицы
        end else begin
            Y_n = 8'b11111111; // Все выходы отключены
        end
    end

endmodule

module DECODER_74HC154_4_to_16 (
    input [3:0] A,
    input E1,
    input E2,
    output reg [15:0] Y
);

always @(*) begin
    if (E1 == 1'b0 && E2 == 1'b0) begin
        Y = ~(16'b1 << A);  // Сдвигаем 1 на позицию A и инвертируем
    end else begin
        Y = 16'b1111_1111_1111_1111;
    end
end

endmodule
