import sys
import serial


# Configuración prefijada
BAUDRATE = 19200      # Set baud rate for communication
SERIAL_PORT = "COM4"  # Establece el puerto COM directamente aquí

OPCODES = {
    'ADD': bytes([0b00100000]),
    'SUB': bytes([0b00100010]),
    'AND': bytes([0b00100100]),
    'OR':  bytes([0b00100101]),
    'XOR': bytes([0b00100110]),
    'NOR': bytes([0b00100111]),
    'SRA': bytes([0b00000011]),
    'SRL': bytes([0b00000010])
}

ACTIONS = {
    "GET RES":   bytes([0b00000000]),
    "SET_A":   bytes([0b00000001]),
    "SET_B":  bytes([0b00000010]),
    "SET OP": bytes([0b00000011]),
}

def exit_program() -> None:
    print('Saliendo...')
    serial_port.close()
    sys.exit()

def get_data(prompt: str, expected_length: int, base: int):
    while True:
        user_input = input(prompt).strip()
        
        # Check for quit command or empty input
        if user_input.lower() == "quit":
            exit_program()
            return -1
        if not user_input:
            print("Error: Entrada inválida, intente nuevamente.")
            continue
        
        # Validate input as an integer and check length
        try:
            operand = int(user_input,base)
            if len(user_input) == expected_length:
                return operand
            else:
                print(f"Error: la entrada debe tener una longitud de {expected_length} caracteres.")
        except ValueError:
            print("Error: la entrada debe ser un número válido.")

try:
    serial_port = serial.Serial(SERIAL_PORT, BAUDRATE, timeout=1)
except serial.SerialException as e:
    print(f"Error intentando abrir el puerto {SERIAL_PORT}: {e}")
    sys.exit(1)

loop = True

while loop:
    print("----------------------------------------------")
    action = get_data("Ingrese la accion deseada:\n 1) SET_A\n 2) SET_B\n 3) SET OP\n 4) GET RES : ", 1,base = 10)
    match action:
        case 1:
            serial_port.write(ACTIONS["SET_A"])  # Directly send the byte
            operand = get_data("Ingrese el valor para A (8 bits binario): ", 8,base=2)
            serial_port.write(bytes([operand]))  # Directly send the operand
        case 2:
            serial_port.write(ACTIONS["SET_B"])  # Directly send the byte
            operand = get_data("Ingrese el valor para B (8 bits binario): ", 8,base=2)
            serial_port.write(bytes([operand]))  # Directly send the operand
        case 3:
            operation_str = input("Ingrese la operacion ... ADD, SUB, AND, OR, XOR, NOR, SRA, SRL : ").strip().upper()
            if operation_str in OPCODES:
                opcode = OPCODES[operation_str]
                serial_port.write(ACTIONS["SET OP"])  # Directly send the byte
                serial_port.write(opcode)
            else:
                print("Operacion invalida")
        case 4:
            serial_port.write(ACTIONS["GET RES"])  # Directly send the byte
            received_data = serial_port.read(1)
            if len(received_data) == 1:
                result = int.from_bytes(received_data, byteorder='big', signed=True)
                binary_result = f'{result & 0xFF:08b}'
                print(f'Resultado: {binary_result} ({result})')
            else:
                print('Error de recepcion: ningun dato recibido')
        case _:
            print("Accion invalida, intente nuevamente.")
