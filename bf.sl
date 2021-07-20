function main() {
  // lexing tokens
  lexer = Lexer(tokenTypes());
  while (lexer.read(lexer)) {
  }

  // evaluating tokens
  input = Array();
  evaluator = Evaluator(input, MemorySpace(256), lexer.tokens);
  evaluator.eval(evaluator);

  // showing output
  println(chars(evaluator.output));
}

function true() { return 1 == 1; }
function false() { return 1 != 1; }
function null() {}
function Number() { return typeOf(1); }

/* Array contains elements in numerical properties */
function Array() {
  self = new();
  self.len = 0;

  self.push = arrayPush;
  self.pop = arrayPop;
  self.shift = arrayShift;

  return self;
}

function arrayPush(self, elem) {
  self[self.len] = elem;
  self.len = self.len + 1;
}

function arrayPop(self) {
  if (self.len == 0) {
    return;
  }

  // NOTE: self[self.len] cannot be deleted physically
  e = self[self.len];
  self.len = self.len - 1;
  return e;
}

function arrayShift(self, elem) {
  if (self.len == 0) {
    return;
  }

  // NOTE: self[self.len] cannot be deleted physically
  e = self[0];
  self.len = self.len - 1;

  i = 0;
  while (i < self.len) {
    self[i] = self[i + 1];
    i = i + 1;
  }
  return e;
}

/* tokenTypes defines token types used in brainf*ck */
function tokenTypes() {
  types = Array();
  types.push(types, ">");
  types.push(types, "<");
  types.push(types, "+");
  types.push(types, "-");
  types.push(types, ".");
  types.push(types, ",");
  types.push(types, "[");
  types.push(types, "]");

  return types;
}


/* Lexer reads stdin and keeps appeared tokens */
function Lexer(tokenTypes) {
  self = new();
  self.tokens = Array();
  self.tokenTypes = tokenTypes;

  self.read = lexerRead;
  self.isToken = lexerIsToken;

  return self;
}

function lexerRead(self) {
  // NOTE: each line must contain only one character
  // (because sl cannot trim string)
  l = readln();

  // EOF
  if (l == "") {
    return false();
  }

  if (self.isToken(self, l)) {
    self.tokens.push(self.tokens, l);
  }

  return true();
}

function lexerIsToken(self, l) {
  i = 0;
  while (i < self.tokenTypes.len) {
    if (l == self.tokenTypes[i]) {
      return true();
    }
    i = i + 1;
  }
  return false();
}


/* Evaluator evaluates each token */
function Evaluator(input, memorySpace, tokens) {
  self = new();
  self.input = input;
  self.output = Array();
  self.memorySpace = memorySpace;
  self.tokens = tokens;
  self.tokenCursor = 0;
  // cache corresponding token positions of `[` and `]`
  self.correspondingCursors = Array();

  self.eval = EvaluatorEval;
  self.evalToken = EvaluatorEvalToken;
  self.cacheCorrespondingCursors = EvaluatorselfCacheCorrespondingCursors;
  self.plus = EvaluatorPlus;
  self.minus = EvaluatorMinus;
  self.inc = EvaluatorInc;
  self.dec = EvaluatorDec;
  self.dot = EvaluatorDot;
  self.comma = EvaluatorComma;
  self.start = EvaluatorStart;
  self.end = EvaluatorEnd;

  return self;
}

function EvaluatorEval(self) {
  self.cacheCorrespondingCursors(self);

  while (self.tokenCursor < self.tokens.len) {
    if (self.evalToken(self, self.tokens[self.tokenCursor]) == false()) {
      println("fatal: evaluation error occurred: token " +
              self.tokenCursor + "(" + self.tokens[self.tokenCursor] + ")");
      return;
    }
    self.tokenCursor = self.tokenCursor + 1;
  }
}


function EvaluatorEvalToken(self, token) {
  if (token == "+") { return self.plus(self); }
  if (token == "-") { return self.minus(self); }
  if (token == ">") { return self.inc(self); }
  if (token == "<") { return self.dec(self); }
  if (token == ".") { return self.dot(self); }
  if (token == ",") { return self.comma(self); }
  if (token == "[") { return self.start(self); }  
  if (token == "]") { return self.end(self); }
  return false();
}

function EvaluatorselfCacheCorrespondingCursors(self) {
  start = 0;
  while(start < self.tokens.len) {
    if (self.tokens[start] != "[") {
      start = start + 1;
      continue;
    }

    nest = 1;
    end = start;
    while(nest > 0 && end < self.tokens.len - 1) {
      end = end + 1;
      if (self.tokens[end] == "[") {
        nest = nest + 1;
      }
      if (self.tokens[end] == "]") {
        nest = nest - 1;
      }
    }

    // cache "[" -> "]", "]" -> "["
    self.correspondingCursors[start] = end;
    self.correspondingCursors[end] = start;

    start = start + 1;
  }
}

function EvaluatorPlus(self) {
  self.memorySpace.incValue(self.memorySpace);
  return true();
}

function EvaluatorMinus(self) {
  self.memorySpace.decValue(self.memorySpace);
  return true();
}

function EvaluatorInc(self) {
  self.memorySpace.incPtr(self.memorySpace);
  return true();
}

function EvaluatorDec(self) {
  self.memorySpace.decPtr(self.memorySpace);
  return true();
}

function EvaluatorDot(self) {
  self.output.push(self.output, self.memorySpace.getValue(self.memorySpace));
  return true();
}

function EvaluatorComma(self) {
  v = self.input.shift(self.input);
  if (isNull(v)) {
    // do nothing
    return true();
  }
  return self.memorySpace.setValue(self.memorySpace, v);
}

function EvaluatorStart(self) {
  if (self.memorySpace.getValue(self.memorySpace) == 0) {
    // jump to "]"
    self.tokenCursor = self.correspondingCursors[self.tokenCursor];
  }
  return true();
}

function EvaluatorEnd(self) {
  if (self.memorySpace.getValue(self.memorySpace) != 0) {
    // jump to "["
    self.tokenCursor = self.correspondingCursors[self.tokenCursor];
  }
  return true();
}

/* MemorySpace is an array of Memory */
function MemorySpace(size) {
  self = new();
  self.ptr = MemoryPointer(size);

  // initialize memories
  self.memories = Array();
  i = 0;
  while (i < size) {
    self.memories.push(self.memories, Memory());
    i = i + 1;
  }

  self.getValue = MemorySpaceGetValue;
  self.setValue = MemorySpaceSetValue;
  self.incPtr = MemorySpaceIncPtr;
  self.decPtr = MemorySpaceDecPtr;
  self.incValue = MemorySpaceIncValue;
  self.decValue = MemorySpaceDecValue;

  return self;
}

function MemorySpaceGetValue(self) {
  memory = self.memories[self.ptr.value];
  return memory.get(memory);
}

function MemorySpaceSetValue(self, n) {
  memory = self.memories[self.ptr.value];
  // true: success, false: failed
  return memory.set(memory, n);
}

function MemorySpaceIncValue(self) {
  memory = self.memories[self.ptr.value];
  memory.inc(memory);
}

function MemorySpaceDecValue(self) {
  memory = self.memories[self.ptr.value];
  memory.dec(memory);
}

function MemorySpaceIncPtr(self) {
  self.ptr.inc(self.ptr);
}

function MemorySpaceDecPtr(self) {
  self.ptr.dec(self.ptr);
}


/* Memory represents 1-byte memory */
function Memory() {
  self = new();
  self.v = 0;
  self.LIMIT = 255;

  self.inc = MemoryInc;
  self.dec = MemoryDec;
  self.get = MemoryGet;
  self.set = MemorySet;

  return self;
}

function MemoryInc(self) {
  if (self.v >= self.LIMIT) {
    self.v = 0;
  } else {
    self.v = self.v + 1;
  }
}

function MemoryDec(self) {
  if (self.v <= 0) {
    self.v = self.LIMIT;
  } else {
    self.v = self.v - 1;
  }
}

function MemoryGet(self) {
  return self.v;
}

// return whether set succeeded
function MemorySet(self, n) {
  if (isInstance(n, Number) == false()) {
    return false();
  }

  if (n > self.LIMIT || n < 0) {
    return false();
  }

  self.v = n;
  return true();
}

/* MemoryPointer represents pointer to size n MemorySpace */
function MemoryPointer(size) {
  self = new();
  self.value = 0;
  self.memorySize = size;

  self.inc = MemoryPointerInc;
  self.dec = MemoryPointerDec;

  return self;
}

function MemoryPointerInc(self) {
  if (self.value >= self.memorySize - 1) {
    self.value = 0;
  } else {
    self.value = self.value + 1;
  }
}

function MemoryPointerDec(self) {
  if (self.value <= 0) {
    self.value = self.memorySize - 1;
  } else {
    self.value = self.value - 1;
  }
}

/* chars converts byte array into string */
function chars(a) {
  s = "";
  i = 0;
  while(i < a.len) {
    s = s + char(a[i]);
    i = i + 1;
  }
  
  return s;
}

function char(b) {
  if (isInstance(Number(), b) == false()) {
    // ignore non-number
    return "";
  }

  if (b == 32) { return " "; }
  if (b == 33) { return "!"; }
  // NOTE: double-quotation cannot be parsed (because sl cannot escape it)
  if (b == 35) { return "#"; }
  if (b == 36) { return "$"; }
  if (b == 37) { return "%"; }
  if (b == 38) { return "&"; }
  if (b == 39) { return "'"; }
  if (b == 40) { return "("; }
  if (b == 41) { return ")"; }
  if (b == 42) { return "*"; }
  if (b == 43) { return "+"; }
  if (b == 44) { return ","; }
  if (b == 45) { return "-"; }
  if (b == 46) { return "."; }
  if (b == 47) { return "/"; }
  if (b == 48) { return "0"; }
  if (b == 49) { return "1"; }
  if (b == 50) { return "2"; }
  if (b == 51) { return "3"; }
  if (b == 52) { return "4"; }
  if (b == 53) { return "5"; }
  if (b == 54) { return "6"; }
  if (b == 55) { return "7"; }
  if (b == 56) { return "8"; }
  if (b == 57) { return "9"; }
  if (b == 58) { return ":"; }
  if (b == 59) { return ";"; }
  if (b == 60) { return "<"; }
  if (b == 61) { return "="; }
  if (b == 62) { return ">"; }
  if (b == 63) { return "?"; }
  if (b == 64) { return "@"; }
  if (b == 65) { return "A"; }
  if (b == 66) { return "B"; }
  if (b == 67) { return "C"; }
  if (b == 68) { return "D"; }
  if (b == 69) { return "E"; }
  if (b == 70) { return "F"; }
  if (b == 71) { return "G"; }
  if (b == 72) { return "H"; }
  if (b == 73) { return "I"; }
  if (b == 74) { return "J"; }
  if (b == 75) { return "K"; }
  if (b == 76) { return "L"; }
  if (b == 77) { return "M"; }
  if (b == 78) { return "N"; }
  if (b == 79) { return "O"; }
  if (b == 80) { return "P"; }
  if (b == 81) { return "Q"; }
  if (b == 82) { return "R"; }
  if (b == 83) { return "S"; }
  if (b == 84) { return "T"; }
  if (b == 85) { return "U"; }
  if (b == 86) { return "V"; }
  if (b == 87) { return "W"; }
  if (b == 88) { return "X"; }
  if (b == 89) { return "Y"; }
  if (b == 90) { return "Z"; }
  if (b == 91) { return "["; }
  // NOTE: back-quotation cannot be parsed (because sl cannot escape it)
  if (b == 93) { return "]"; }
  if (b == 94) { return "^"; }
  if (b == 95) { return "_"; }
  if (b == 96) { return "`"; }
  if (b == 97) { return "a"; }
  if (b == 98) { return "b"; }
  if (b == 99) { return "c"; }
  if (b == 100) { return "d"; }
  if (b == 101) { return "e"; }
  if (b == 102) { return "f"; }
  if (b == 103) { return "g"; }
  if (b == 104) { return "h"; }
  if (b == 105) { return "i"; }
  if (b == 106) { return "j"; }
  if (b == 107) { return "k"; }
  if (b == 108) { return "l"; }
  if (b == 109) { return "m"; }
  if (b == 110) { return "n"; }
  if (b == 111) { return "o"; }
  if (b == 112) { return "p"; }
  if (b == 113) { return "q"; }
  if (b == 114) { return "r"; }
  if (b == 115) { return "s"; }
  if (b == 116) { return "t"; }
  if (b == 117) { return "u"; }
  if (b == 118) { return "v"; }
  if (b == 119) { return "w"; }
  if (b == 120) { return "x"; }
  if (b == 121) { return "y"; }
  if (b == 122) { return "z"; }
  if (b == 123) { return "{"; }
  if (b == 124) { return "|"; }
  if (b == 125) { return "}"; }
  if (b == 126) { return "~"; }

  // ignore unprintable chars
  return "";
}
