// little-scheme-in-dart (edited)
// Original repo: https://github.com/nukata/little-scheme-in-dart

/* MIT License
*
* Copyright (c) 2019 SUZUKI Hisao
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
*/
// ignore_for_file: constant_identifier_names

import 'package:xeonjia/game/xeonjia_game.dart';

const intBits = 63; // 53 for dart2js

/// Converts [a] into an int if possible.
Object normalize(BigInt a) => (a.bitLength <= intBits) ? a.toInt() : a;

/// Is [a] a number?
bool isNumber(Object a) => a is num || a is BigInt;

/// Calculates [a] + [b].
Object add(Object a, Object b) {
  if (a is int) {
    if (b is int) {
      if (a.bitLength < intBits && b.bitLength < intBits) {
        return a + b;
      } else {
        return normalize(BigInt.from(a) + BigInt.from(b));
      }
    } else if (b is double) {
      return a + b;
    } else if (b is BigInt) {
      return normalize(BigInt.from(a) + b);
    }
  } else if (a is double) {
    if (b is num) {
      return a + b;
    } else if (b is BigInt) {
      return a + b.toDouble();
    }
  } else if (a is BigInt) {
    if (b is int) {
      return normalize(a + BigInt.from(b));
    } else if (b is double) {
      return a.toDouble() + b;
    } else if (b is BigInt) {
      return normalize(a + b);
    }
  }
  throw ArgumentError('$a, $b');
}

/// Calculates [a] - [b].
Object subtract(Object a, Object b) {
  if (a is int) {
    if (b is int) {
      if (a.bitLength < intBits && b.bitLength < intBits) {
        return a - b;
      } else {
        return normalize(BigInt.from(a) - BigInt.from(b));
      }
    } else if (b is double) {
      return a - b;
    } else if (b is BigInt) {
      return normalize(BigInt.from(a) - b);
    }
  } else if (a is double) {
    if (b is num) {
      return a - b;
    } else if (b is BigInt) {
      return a - b.toDouble();
    }
  } else if (a is BigInt) {
    if (b is int) {
      return normalize(a - BigInt.from(b));
    } else if (b is double) {
      return a.toDouble() - b;
    } else if (b is BigInt) {
      return normalize(a - b);
    }
  }
  throw ArgumentError('$a, $b');
}

/// Compares [a] and [b].
/// Returns -1, 0 or 1 as [a] is less than, equal to, or greater than [b].
num compare(Object a, Object b) {
  if (a is int) {
    if (b is int) {
      if (a.bitLength < intBits && b.bitLength < intBits) {
        return (a - b).sign;
      } else {
        return (BigInt.from(a) - BigInt.from(b)).sign;
      }
    } else if (b is double) {
      return (a - b).sign;
    } else if (b is BigInt) {
      return (BigInt.from(a) - b).sign;
    }
  } else if (a is double) {
    if (b is num) {
      return (a - b).sign;
    } else if (b is BigInt) {
      return (a - b.toDouble()).sign;
    }
  } else if (a is BigInt) {
    if (b is int) {
      return (a - BigInt.from(b)).sign;
    } else if (b is double) {
      return (a.toDouble() - b).sign;
    } else if (b is BigInt) {
      return (a - b).sign;
    }
  }
  throw ArgumentError('$a, $b');
}

/// Calculates [a] * [b].
Object multiply(Object a, Object b) {
  if (a is int) {
    if (b is int) {
      if (a.bitLength + b.bitLength < intBits) {
        return a * b;
      } else {
        return normalize(BigInt.from(a) * BigInt.from(b));
      }
    } else if (b is double) {
      return a * b;
    } else if (b is BigInt) {
      return BigInt.from(a) * b;
    }
  } else if (a is double) {
    if (b is num) {
      return a * b;
    } else if (b is BigInt) {
      return a * b.toDouble();
    }
  } else if (a is BigInt) {
    if (b is int) {
      return a * BigInt.from(b);
    } else if (b is double) {
      return a.toDouble() * b;
    } else if (b is BigInt) {
      return a * b;
    }
  }
  throw ArgumentError('$a, $b');
}

/// Tries to parse a string as an int, a BigInt or a double.
/// Returns null if [s] was not parsed successfully.
Object tryParse(String s) {
  var r = BigInt.tryParse(s);
  return (r == null) ? double.tryParse(s) : normalize(r);
}

//----------------------------------------------------------------------

/// Cons cell
class Cell extends Iterable<Object> {
  Cell(this.car, this.cdr);
  final Object car;
  dynamic cdr;

  /// Yields car, cadr, caddr and so on.
  @override
  Iterator<Object> get iterator => _CellIterator(this);
}

class _CellIterator extends Iterator<Object> {
  _CellIterator(this.k);
  Cell j;
  dynamic k;

  @override
  Object get current => j?.car;

  @override
  bool moveNext() {
    if (k == null) {
      return false;
    } else if (k is Cell) {
      j = k as Cell;
      k = k.cdr;
      return true;
    } else {
      throw ImproperListException(k);
    }
  }
}

/// Exception which means that the last tail of the list is not null
class ImproperListException implements Exception {
  ImproperListException(this.tail);
  final Object tail;
}

//----------------------------------------------------------------------

/// Scheme's symbol
class Sym {
  /// Constructs an interned symbol.
  factory Sym(String name) =>
      symbols.putIfAbsent(name, () => Sym.notInterned(name));

  /// Constructs a symbol that is not interned yet.
  const Sym.notInterned(this.name);

  final String name;

  @override
  String toString() => name;

  /// The table of interned symbols
  static final Map<String, Sym> symbols = {};
}

final quoteSym = Sym('quote');
final ifSym = Sym('if');
final beginSym = Sym('begin');
final lambdaSym = Sym('lambda');
final defineSym = Sym('define');
final setqSym = Sym('set!');
final applySym = Sym('apply');
final callccSym = Sym('call/cc');
final waitSym = Sym('wait');

//----------------------------------------------------------------------

typedef Setter = void Function(Object val);

/// List of frames which map symbols to values
class Environment {
  /// Construct a new frame on the [next] (= current) environment or null.
  Environment(Cell symbols, Cell data, Environment next) {
    var names = symbols?.map((e) => e as Sym)?.toList() ?? [];
    var values = data?.toList() ?? [];
    if (names?.length != values?.length) {
      throw 'arity not matched: $names and $values';
    }
    _names = names;
    _values = values;
    _next = next;
  }

  List<Sym> _names;
  List<Object> _values;
  Environment _next;

  /// Searches the environment for [symbol] and returns its setter.
  Setter lookForSetter(Sym symbol) {
    var frame = this;
    do {
      var i = frame._names.indexOf(symbol);
      if (i >= 0) {
        return (Object val) {
          frame._values[i] = val;
        };
      }
      frame = frame._next;
    } while (frame != null);
    throw 'name to be set not found: $symbol';
  }

  /// Searches the environment for [symbol] and returns its value.
  Object lookForValue(Sym symbol) {
    var frame = this;
    do {
      var i = frame._names.indexOf(symbol);
      if (i >= 0) return frame._values[i];
      frame = frame._next;
    } while (frame != null);
    throw 'name not found: $symbol';
  }

  /// Defines [symbol] as [value] in the current frame.
  void defineSymbol(Sym symbol, Object value) {
    var i = _names.indexOf(symbol);
    if (i >= 0) {
      _values[i] = value;
    } else {
      _names.add(symbol);
      _values.add(value);
    }
  }

  /// Symbols in the current frame
  Iterable<Sym> get names => _names;

  @override
  String toString() {
    var ss = <String>[];
    var frame = this;
    do {
      ss.add(frame._names.toString());
      frame = frame._next;
    } while (frame != null);
    return '#<' + ss.join('|') + '>';
  }
}

//----------------------------------------------------------------------

/// Operations in continuations
enum ContOp {
  THEN,
  BEGIN,
  DEFINE,
  SETQ,
  APPLY,
  APPLY_FUN,
  EVAL_ARG,
  CONS_ARGS,
  RESTORE_ENV,
  WAIT,
}

/// Scheme's step in a continuation
class Step {
  Step(this.op, this.val);
  final ContOp op;
  final Object val;
}

// Scheme's continuation as a stack of steps
class Continuation extends Iterable<Step> {
  final List<Step> _stack = [];

  @override
  bool get isEmpty => _stack.isEmpty;
  @override
  int get length => _stack.length;

  Iterable<Step> _iter() sync* {
    for (final step in _stack) {
      yield step;
    }
  }

  /// Yields each step.
  @override
  Iterator<Step> get iterator => _iter().iterator;

  /// Appends a step to the tail of the continuation.
  void push(ContOp op, Object value) => _stack.add(Step(op, value));

  /// Pops a step from the tail of the continuation.
  Step pop() => _stack.removeLast();

  /// Copies a continuation.
  void copyFrom(Continuation other) {
    _stack.clear();
    _stack.addAll(other._stack);
  }

  /// Pushes [ContOp.RESTORE_ENV] unless on a tail call.
  void pushRestoreEnv(Environment env) {
    var len = _stack.length;
    if (len == 0 || _stack[len - 1].op != ContOp.RESTORE_ENV) {
      push(ContOp.RESTORE_ENV, env);
    }
  }
}

//----------------------------------------------------------------------

/// Lambda expression with its environment
class Closure {
  Closure(this.params, this.body, this.env);
  final Cell params;
  final Cell body;
  final Environment env;
}

typedef IntrinsicBody = Object Function(Cell args);

/// Built-in function
class Intrinsic {
  Intrinsic(this.name, this.arity, this.fun);
  final String name;
  final int arity;
  final IntrinsicBody fun;

  @override
  String toString() => '#<$name:$arity>';
}

/// Exception thrown by error procedure of SRFI-23
class ErrorException implements Exception {
  ErrorException(this.reason, this.arg);
  final Object reason;
  final Object arg;

  @override
  String toString() => stringify(reason, false) + ': ' + stringify(arg);
}

//----------------------------------------------------------------------

/// Converts an expression to a string.
// ignore: avoid_positional_boolean_parameters
String stringify(Object exp, [bool quote = true]) {
  if (exp == true) return '#t';
  if (exp == false) return '#f';
  if (exp == #NONE) return '#<VOID>';
  if (exp == #EOF) return '#<EOF>';
  if (exp == #CALLCC) return '#<call/cc>';
  if (exp == #APPLY) return '#<apply>';
  if (exp == null) return '()';
  if (exp is Cell) {
    var ss = <String>[];
    try {
      for (final e in exp) {
        ss.add(stringify(e, quote));
      }
    } on ImproperListException catch (ex) {
      ss.add('.');
      ss.add(stringify(ex.tail, quote));
    }
    return '(' + ss.join(' ') + ')';
  }
  if (exp is Continuation) {
    var ss = <String>[];
    for (final step in exp) {
      ss.add('${step.op} ${stringify(step.val)}');
    }
    return '#<' + ss.join('\n\t  ') + '>';
  }
  if (exp is Closure) {
    var p = stringify(exp.params);
    var v = stringify(exp.body);
    var e = stringify(exp.env);
    return '#<$p:$v:$e>';
  }
  if ((exp is String) && quote) return '"$exp"';
  return '$exp';
}

//----------------------------------------------------------------------

/// Evaluates an expression in an environment.
Continuation evaluate(dynamic exp, Environment env, [Continuation previousK]) {
  var k = previousK ?? Continuation();
  try {
    for (;;) {
      for (;;) {
        if (exp is Cell) {
          Object kar = exp.car;
          dynamic kdr = exp.cdr;
          if (identical(kar, quoteSym)) {
            // (quote e)
            exp = kdr.car;
            break;
          } else if (identical(kar, ifSym)) {
            // (if e1 e2 e3) or (if e1 e2)
            exp = kdr.car;
            k.push(ContOp.THEN, kdr.cdr);
          } else if (identical(kar, beginSym)) {
            // (begin e...)
            exp = kdr.car;
            if (kdr.cdr != null) k.push(ContOp.BEGIN, kdr.cdr);
          } else if (identical(kar, lambdaSym)) {
            // (lambda (v...) e...)
            exp = Closure(kdr.car as Cell, kdr.cdr as Cell, env);
            break;
          } else if (identical(kar, defineSym)) {
            // (define v e)
            exp = kdr.cdr.car;
            k.push(ContOp.DEFINE, kdr.car);
          } else if (identical(kar, setqSym)) {
            // (set! v e)
            exp = kdr.cdr.car;
            k.push(ContOp.SETQ, env.lookForSetter(kdr.car as Sym));
          } else if (identical(kar, waitSym)) {
            if (kdr?.car != null) game.nextActionDelay = kdr?.car?.toDouble();
            exp = null;
            k.push(ContOp.WAIT, kdr);
          } else {
            // (fun arg...)
            exp = kar;
            k.push(ContOp.APPLY, kdr);
          }
        } else if (exp is Sym) {
          exp = env.lookForValue(exp as Sym);
          break;
        } else {
          // a number, #t, #f etc.
          break;
        }
      }
      Loop2:
      for (;;) {
        if (k.isEmpty) {
          // execution finished
          game.clearActionContinuation();
          if (!game.messageManager.active) game.resume();
          return null;
        }
        var step = k.pop();
        var op = step.op;
        dynamic x = step.val;
        switch (op) {
          case ContOp.WAIT:
            // execution paused
            if (game.nextActionDelay != 0 && game.hasAction) {
              game.continueAction();
            }
            return k;
          case ContOp.THEN: // x is (e2 e3) of (if e1 e2 e3).
            if (exp == false) {
              if (x.cdr == null) {
                exp = #NONE;
              } else {
                exp = x.cdr.car; // e3
                break Loop2;
              }
            } else {
              exp = x.car; // e2
              break Loop2;
            }
            break;
          case ContOp.BEGIN: //  x is (e...) of (begin e...).
            if (x.cdr != null) {
              k.push(ContOp.BEGIN, x.cdr); // unless on a tail call.
            }
            exp = x.car;
            break Loop2;
          case ContOp.DEFINE: // x is a Sym to be defined.
            env.defineSymbol(x as Sym, exp);
            exp = #NONE;
            break;
          case ContOp.SETQ: // x is a Setter.
            x(exp);
            exp = #NONE;
            break;
          case ContOp.APPLY: // x is a list of arguments to be eval'ed.
            if (x == null) {
              var pair = applyFunction(exp, null, k, env);
              exp = pair.result;
              env = pair.env;
            } else {
              k.push(ContOp.APPLY_FUN, exp);
              while (x.cdr != null) {
                k.push(ContOp.EVAL_ARG, x.car);
                x = x.cdr;
              }
              exp = x.car;
              k.push(ContOp.CONS_ARGS, null);
              break Loop2;
            }
            break;
          case ContOp.CONS_ARGS: // x is the evaluated arguments to be cons'ed.
            var args = Cell(exp, x);
            var step = k.pop();
            op = step.op;
            exp = step.val;
            switch (op) {
              case ContOp.EVAL_ARG: // exp is the next argument to be eval'ed.
                k.push(ContOp.CONS_ARGS, args);
                break Loop2;
              case ContOp.APPLY_FUN: // exp is the evaluated function.
                var pair = applyFunction(exp, args, k, env);
                exp = pair.result;
                env = pair.env;
                break;
              default:
                throw 'unexpected op: $op';
            }
            break;
          case ContOp.RESTORE_ENV: // x is an Environment.
            env = x as Environment;
            break;
          default:
            throw 'bad op: $op';
        }
      }
    }
  } catch (ex) {
    if (ex is ErrorException) rethrow;
    if (k.isEmpty) rethrow;
    throw '$ex\n\t${stringify(k)}';
  }
}

class REPair {
  REPair(this.result, this.env);
  final Object result;
  final Environment env;
}

/// Applies a function to arguments with a continuation.
/// [env] will be referred to push [ContOp.RESTORE_ENV] to the continuation.
REPair applyFunction(Object fun, Cell arg, Continuation k, Environment env) {
  for (;;) {
    if (fun == #CALLCC) {
      k.pushRestoreEnv(env);
      fun = arg.car;
      var cont = Continuation();
      cont.copyFrom(k);
      arg = Cell(cont, null);
    } else if (fun == #APPLY) {
      fun = arg.car;
      arg = arg.cdr.car as Cell;
    } else {
      break;
    }
  }
  if (fun is Intrinsic) {
    if (fun.arity >= 0) {
      if (arg == null ? fun.arity > 0 : arg.length != fun.arity) {
        throw 'arity not matched: $fun and ${stringify(arg)}';
      }
    }
    return REPair(fun.fun(arg), env);
  } else if (fun is Closure) {
    k.pushRestoreEnv(env);
    k.push(ContOp.BEGIN, fun.body);
    return REPair(#NONE, Environment(fun.params, arg, fun.env));
  } else if (fun is Continuation) {
    k.copyFrom(fun);
    return REPair(arg.car, env);
  } else {
    throw 'not a function: ${stringify(fun)} with ${stringify(arg)}';
  }
}

//----------------------------------------------------------------------

final _anySpaces = RegExp(r'\s+');

/// '(a 1)' => ['(', 'a', '1', ')']
List<String> splitStringIntoTokens(String source) {
  var result = <String>[];
  for (var line in source.split('\n')) {
    var x = <String>[];
    var ss = <String>[]; // to store string literals
    var i = 0;
    String doubleQuotesSymbol;
    var counter = 0;
    while (line.contains(doubleQuotesSymbol = 'DOUBLE_QUOTE_SYMBOL_$counter')) {
      ++counter;
    }
    line = line.replaceAll(r'\"', doubleQuotesSymbol);
    for (var e in line.split('"')) {
      e = e.replaceAll(doubleQuotesSymbol, '"');
      if (i % 2 == 0) {
        x.add(e);
      } else {
        ss.add('"' + e); // Stores a string literal.
        x.add('#s');
      }
      i++;
    }
    var s = x.join(' ').split(';')[0]; // Ignores ;-comment.
    s = s.replaceAll("'", " ' ").replaceAll(')', ' ) ').replaceAll('(', ' ( ');
    x = s.split(_anySpaces);
    for (final e in x) {
      if (e == '#s') {
        result.add(ss.removeAt(0));
      } else if (e != '') {
        result.add(e);
      }
    }
  }
  return result;
}

/// Reads an expression from [tokens].
/// [tokens] will be left with the rest of token strings, if any.
Object readFromTokens(List<String> tokens) {
  var token = tokens.removeAt(0);
  switch (token) {
    case '(':
      var z = Cell(null, null);
      var y = z;
      while (tokens[0] != ')') {
        if (tokens[0] == '.') {
          tokens.removeAt(0);
          y.cdr = readFromTokens(tokens);
          if (tokens[0] != ')') throw ') is expected';
          break;
        }
        var e = readFromTokens(tokens);
        var x = Cell(e, null);
        y.cdr = x;
        y = x;
      }
      tokens.removeAt(0);
      return z.cdr;
    case ')':
      throw 'unexpected )';
    case "'":
      var e = readFromTokens(tokens);
      return Cell(quoteSym, Cell(e, null)); // 'e => (quote e)
    case '#f':
      return false;
    case '#t':
      return true;
  }
  if (token[0] == '"') {
    return token.substring(1);
  }
  return tryParse(token) ?? Sym(token);
}

/// Tokens from the standard-in.
var stdInTokens = <String>[];
