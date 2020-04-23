import 'dart:io';

void main(List<String> arguments) {
  print('Enter LC-3 binary, then press enter.');
  while (true) {
    try {
      var binaryString = stdin.readLineSync();
      assert(binaryString.length == 16);
      print(Instruction.decompile(binaryString));
    } catch (e, stacktrace) {
      print('$e \n $stacktrace');
    }
  }
}

class Instruction {
  static List<Instruction> allInstructions = [
    Instruction(name: 'ADD', code: '0001', identifierIndex: 10, chunks: {
      0: [Register(), Register(), Constant('000'), Register()],
      1: [Register(), Register(), Constant('1'), Offset(5)],
    }),
    Instruction(name: 'AND', code: '0101', identifierIndex: 10, chunks: {
      0: [Register(), Register(), Constant('000'), Register()],
      1: [Register(), Register(), Constant('1'), Offset(5)],
    }),
    Instruction(name: 'BR', code: '0000', chunks: {
      0: [Flag('n'), Flag('z'), Flag('p'), Offset(9)],
    }),
    Instruction(name: 'JMP', code: '1100', chunks: {
      0: [Constant('000'), Register(), Constant('000000')]
    }),
    Instruction(name: 'JSR', code: '0100', identifierIndex: 4, chunks: {
      0: [
        Flag('R', inverted: true),
        Constant('00'),
        Register(),
        Constant('000000')
      ],
      1: [Flag('R', inverted: true), Offset(11)]
    }),
    Instruction(name: 'LD', code: '0010', chunks: {
      0: [Register(), Offset(9)]
    }),
    Instruction(name: 'LDI', code: '1010', chunks: {
      0: [Register(), Offset(9)]
    }),
    Instruction(name: 'LDR', code: '0110', chunks: {
      0: [Register(), Register(), Offset(6)]
    }),
    Instruction(name: 'LEA', code: '1110', chunks: {
      0: [Register(), Offset(9)]
    }),
    Instruction(name: 'NOT', code: '1001', chunks: {
      0: [Register(), Register(), Constant('111111')]
    }),
    Instruction(name: 'ST', code: '0011', chunks: {
      0: [Register(), Offset(9)]
    }),
    Instruction(name: 'STI', code: '1011', chunks: {
      0: [Register(), Offset(9)]
    }),
    Instruction(name: 'STR', code: '0111', chunks: {
      0: [Register(), Register(), Offset(6)]
    }),
    Instruction(name: 'TRAP', code: '1111', chunks: {
      0: [Constant('0000'), Offset(8)]
    })
  ];
  static Map<String, Instruction> instructionsMap = () {
    var map = <String, Instruction>{};
    for (var inst in allInstructions) {
      // Ensure no duplicate instruction keys.
      assert(!map.containsKey(inst.code));
      map[inst.code] = inst;
    }
    return map;
  }();
  final String code;
  final String name;
  final int identifierIndex;
  final Map<int, List<Chunk>> chunks;

  Instruction({this.name, this.code, this.identifierIndex, this.chunks});

  static String decompile(String compiledBinary) {
    assert(compiledBinary.length == 16);
    var code = compiledBinary.substring(0, 4);
    var instruction = instructionsMap[code];
    var index = instruction.identifierIndex == null
        ? 0
        : int.parse(compiledBinary[instruction.identifierIndex]);
    var chunks = instruction.chunks[index];
    var curr = 4;
    var decompiled = instruction.name;
    for (var i = 0; i < chunks.length; i++) {
      var chunk = chunks[i];
      decompiled += chunk.before;
      var raw = compiledBinary.substring(curr, curr + chunk.length);
      decompiled += chunk.decompile(raw);
      if (i != chunks.length - 1) {
        decompiled += chunk.after;
      }
      curr += chunk.length;
    }
    return decompiled;
  }
}

abstract class Chunk {
  final int length;

  Chunk(this.length);

  String get before => '';

  String get after => '';

  String decompile(String raw);
}

/// For N, Z, P
class Flag extends Chunk {
  final String name;
  final bool inverted;

  Flag(this.name, {this.inverted = false}) : super(1);

  @override
  String decompile(String raw) {
    return raw == (inverted ? '0' : '1') ? name : '';
  }
}

mixin ArgumentMixin on Chunk {
  @override
  String get before => ' ';

  @override
  String get after => ',';
}

class Constant extends Chunk {
  final String expectedValue;

  Constant(this.expectedValue) : super(expectedValue.length);

  @override
  String decompile(String raw) {
    assert(raw == expectedValue);
    return '';
  }
}

class Offset extends Chunk with ArgumentMixin {
  Offset(int length) : super(length);

  @override
  String decompile(String raw) {
    return '#${binaryToInt(raw)}';
  }
}

class Register extends Chunk with ArgumentMixin {
  Register() : super(3);

  @override
  String decompile(String raw) {
    return 'R${binaryToInt(raw)}';
  }
}

int binaryToInt(String binStr) {
  return int.parse(binStr, radix: 2);
}
