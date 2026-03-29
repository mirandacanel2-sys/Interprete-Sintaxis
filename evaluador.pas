unit Evaluador;

{$mode objfpc}{$H+}{$codepage UTF8}

interface

uses
  crt, ARBOL, Listas, math, CompoLexico, sysutils;

type
  TipoElemento = record
    lexemaId: string;
    tipo: TSimboloGramatical;
    valorReal: real;
    valorStr: string;
  end;

  TEstado = record
    elementos: array[1..100] of TipoElemento;
    cant: 0..100;
  end;

procedure inicializar_estado(var E: TEstado);
procedure AsignarValor(var E: TEstado; var lexemaId: string; var valorReal: real; var valorStr: string; var tipo: TSimboloGramatical);
procedure AgregarVariable(var E: TEstado; var lexemaId: string; var tipo: TSimboloGramatical);
function obtenerValorReal(var E: TEstado; var lex: string): real;
function obtenerValorStr(var E: TEstado; var lex: string): string;
procedure EvalProgram(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalDesc(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalDes(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalA(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalType(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: TSimboloGramatical);
procedure evalBlock(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalBody(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalC(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalSent(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalAsig(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalXGeneral(var arbol: TArbolDerivacion; var estado: TEstado;
                       var tipo: TSimboloGramatical; var resultadoReal: real;
                       var resultadoStr: string);
procedure evalTerm(var arbol: TArbolDerivacion; var estado: TEstado;
                   var tipo: TSimboloGramatical; var resultadoReal: real;
                   var resultadoStr: string);
procedure evalAddTerm(var arbol: TArbolDerivacion; var estado: TEstado;
                      var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalAddFactor(var arbol: TArbolDerivacion; var estado: TEstado;
                        var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalFactor(var arbol: TArbolDerivacion; var estado: TEstado;
                     var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalPowPart(var arbol: TArbolDerivacion; var estado: TEstado;
                      var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalBase(var arbol: TArbolDerivacion; var estado: TEstado;
                   var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalVal(var arbol: TArbolDerivacion; var estado: TEstado;
                  var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalConst(var arbol: TArbolDerivacion; var estado: TEstado;
                    var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
procedure evalOpSum(var arbol: TArbolDerivacion; var operador: TSimboloGramatical);
procedure evalOpMult(var arbol: TArbolDerivacion; var operador: TSimboloGramatical);
procedure evalOpRel(var arbol: TArbolDerivacion; var operador: TSimboloGramatical);
procedure evalReading(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalWriting(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalWriteItemList(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalLoop(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalConditional(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalYesOrNoElse(var arbol: TArbolDerivacion; var estado: TEstado);
procedure evalCond(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
procedure evalCond1(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
procedure evalCond2(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
procedure evalCond3(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
procedure evalP(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
procedure evalB(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);

implementation

// Inicializar estado
procedure inicializar_estado(var E: TEstado);
begin
   E.cant := 0;
end;

// Asignar valor a variable existente
procedure AsignarValor(var E: TEstado; var lexemaId: string; var valorReal: real; var valorStr: string; var tipo: TSimboloGramatical);
var
  i: integer;
  encontrado: boolean;
begin
  i := 1;
  encontrado := false;
  while (i <= E.cant) and (not encontrado) do
  begin
    if UpCase(E.elementos[i].lexemaId) = UpCase(lexemaId) then
      encontrado := true
    else
      i := i + 1;
  end;

  if encontrado then
  begin
    E.elementos[i].tipo := tipo;
    if (tipo = Ttreal) or (tipo = Tcreal) then
      E.elementos[i].valorReal := valorReal
    else
      E.elementos[i].valorStr := valorStr;
  end;
  // Si no existe, no hace nada: la validación ya se hizo en evalAsig
end;

// Agregar nueva variable
procedure AgregarVariable(var E: TEstado; var lexemaId: string; var tipo: TSimboloGramatical);
begin
  if E.cant < 100 then
  begin
    E.cant := E.cant + 1;
    E.elementos[E.cant].lexemaId := lexemaId;
    E.elementos[E.cant].tipo := tipo;
    E.elementos[E.cant].valorReal := 0;
    E.elementos[E.cant].valorStr := '';
  end;
end;

// Obtener valor real
function obtenerValorReal(var E: TEstado; var lex: string): real;
var
  i: integer;
  encontrado: boolean;
begin
  obtenerValorReal := 0;
  i := 1;
  encontrado := false;
  while (i <= E.cant) and (not encontrado) do
  begin
    if UpCase(E.elementos[i].lexemaId) = UpCase(lex) then
    begin
      obtenerValorReal := E.elementos[i].valorReal;
      encontrado := true;
    end
    else
      i := i + 1;
  end;
end;

function obtenerValorStr(var E: TEstado; var lex: string): string;
var
  i: integer;
  encontrado: boolean;
begin
  obtenerValorStr := '';
  i := 1;
  encontrado := false;
  while (i <= E.cant) and (not encontrado) do
  begin
    if UpCase(E.elementos[i].lexemaId) = UpCase(lex) then
    begin
      obtenerValorStr := E.elementos[i].valorStr;
      encontrado := true;
    end
    else
      i := i + 1;
  end;
end;

///////////////////////////////
// EVALUADOR PRINCIPAL
///////////////////////////////

// programa → zafira desc block
procedure EvalProgram(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant >= 3) then
  begin
    evalDesc(arbol^.hijos[2], estado);
    evalBlock(arbol^.hijos[3], estado);
  end;
end;

// desc → des A
procedure evalDesc(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalDes(arbol^.hijos[1], estado);
    evalA(arbol^.hijos[2], estado);
  end;
end;

// des → id type
procedure evalDes(var arbol: TArbolDerivacion; var estado: TEstado);
var
  resultado: TSimboloGramatical;
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalType(arbol^.hijos[2], estado, resultado);
    AgregarVariable(estado, arbol^.hijos[1]^.lexema, resultado);
  end;
end;

// A → ; desc A | eps
procedure evalA(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalDesc(arbol^.hijos[2], estado);
    evalA(arbol^.hijos[3], estado);
  end;
end;

// type → t_real | t_string
procedure evalType(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: TSimboloGramatical);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    if arbol^.hijos[1]^.simbolo = Ttreal then
       resultado := Ttreal
    else if arbol^.hijos[1]^.simbolo = Ttstring then
       resultado := Ttstring
    else
       resultado := Error;
  end;
end;

// block → start body end
procedure evalBlock(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant >= 3) then
  begin
    evalBody(arbol^.hijos[2], estado);
  end;
end;

// body → sent C
procedure evalBody(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalSent(arbol^.hijos[1], estado);
    evalC(arbol^.hijos[2], estado);
  end;
end;

// C → sent C | eps
procedure evalC(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalSent(arbol^.hijos[1], estado);
    evalC(arbol^.hijos[2], estado);
  end;
end;

// sent → asig ; | reading ; | writing ; | conditional ; | loop ;
procedure evalSent(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    case arbol^.hijos[1]^.simbolo of
       Vasig:        evalAsig(arbol^.hijos[1], estado);
       Vreading:     evalReading(arbol^.hijos[1], estado);
       Vwriting:     evalWriting(arbol^.hijos[1], estado);
       Vconditional: evalConditional(arbol^.hijos[1], estado);
       Vloop:        evalLoop(arbol^.hijos[1], estado);
    end;
  end;
end;

// asig → id -) xgeneral
procedure evalAsig(var arbol: TArbolDerivacion; var estado: TEstado);
var
  tipo: TSimboloGramatical;
  resultadoReal: real;
  resultadoStr: string;
  lexema: string;
  i: integer;
  encontrado: boolean;
  tipoOk: boolean;
begin
  if (arbol <> nil) and (arbol^.cant >= 3) then
  begin
    lexema := arbol^.hijos[1]^.lexema;

    // Buscar la variable
    i := 1;
    encontrado := false;
    while (i <= estado.cant) and (not encontrado) do
    begin
      if UpCase(estado.elementos[i].lexemaId) = UpCase(lexema) then
        encontrado := true
      else
        i := i + 1;
    end;

    if not encontrado then
      writeln('ERROR Semantico: Variable "', lexema, '" no fue declarada.')
    else
    begin
      evalXGeneral(arbol^.hijos[3], estado, tipo, resultadoReal, resultadoStr);

     // Verificar compatibilidad de tipos
      tipoOk := false;

      if ((estado.elementos[i].tipo = Ttreal) or (estado.elementos[i].tipo = Tcreal)) and
         ((tipo = Ttreal) or (tipo = Tcreal)) then
        tipoOk := true;

      if ((estado.elementos[i].tipo = Ttstring) or (estado.elementos[i].tipo = Tcstring)) and
         ((tipo = Ttstring) or (tipo = Tcstring)) then
        tipoOk := true;

      if not tipoOk then
        writeln('ERROR Semantico: Tipo incompatible al asignar a "', lexema, '".')
      else
        AsignarValor(estado, lexema, resultadoReal, resultadoStr, tipo);
    end;
  end;
end;

// xgeneral → term AddTerm
procedure evalXGeneral(var arbol: TArbolDerivacion; var estado: TEstado;
                       var tipo: TSimboloGramatical; var resultadoReal: real;
                       var resultadoStr: string);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalTerm(arbol^.hijos[1], estado, tipo, resultadoReal, resultadoStr);
    evalAddTerm(arbol^.hijos[2], estado, tipo, resultadoReal, resultadoStr);
  end;
end;

// term → factor addfactor
procedure evalTerm(var arbol: TArbolDerivacion; var estado: TEstado;
                   var tipo: TSimboloGramatical; var resultadoReal: real;
                   var resultadoStr: string);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalFactor(arbol^.hijos[1], estado, tipo, resultadoReal, resultadoStr);
    evalAddFactor(arbol^.hijos[2], estado, tipo, resultadoReal, resultadoStr);
  end;
end;

// AddTerm → OpSum term AddTerm | eps
procedure evalAddTerm(var arbol: TArbolDerivacion; var estado: TEstado;
                      var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
var
  tipo2: TSimboloGramatical;
  r2: real;
  s2: string;
  operador: TSimboloGramatical;
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalOpSum(arbol^.hijos[1], operador);
    evalTerm(arbol^.hijos[2], estado, tipo2, r2, s2);

    if (tipo = Ttreal) or (tipo = Tcreal) then
    begin
      if operador = Tmas then
         resultadoReal := resultadoReal + r2
      else if operador = Tmenos then
         resultadoReal := resultadoReal - r2;
    end
    else if (tipo = Ttstring) or (tipo = Tcstring) then
    begin
      if operador = Tmas then
         resultadoStr := resultadoStr + s2;
    end;

    evalAddTerm(arbol^.hijos[3], estado, tipo, resultadoReal, resultadoStr);
  end;
end;

// AddFactor → OpMult factor Addfactor | eps
procedure evalAddFactor(var arbol: TArbolDerivacion; var estado: TEstado;
                        var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
var
  tipo2: TSimboloGramatical;
  r2: real;
  s2: string;
  operador: TSimboloGramatical;
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalOpMult(arbol^.hijos[1], operador);
    evalFactor(arbol^.hijos[2], estado, tipo2, r2, s2);

    if (tipo = Ttreal) or (tipo = Tcreal) then
    begin
      if operador = Tproducto then
         resultadoReal := resultadoReal * r2
      else if operador = Tdivision then
      begin
        if r2 <> 0 then
           resultadoReal := resultadoReal / r2
        else
           resultadoReal := 0; // Evitar división por cero
      end;
    end;

    evalAddFactor(arbol^.hijos[3], estado, tipo, resultadoReal, resultadoStr);
  end;
end;

// factor → Base PowPart
procedure evalFactor(var arbol: TArbolDerivacion; var estado: TEstado;
                     var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalBase(arbol^.hijos[1], estado, tipo, resultadoReal, resultadoStr);
    evalPowPart(arbol^.hijos[2], estado, tipo, resultadoReal, resultadoStr);
  end;
end;

// PowPart → ^ factor | eps
procedure evalPowPart(var arbol: TArbolDerivacion; var estado: TEstado;
                      var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
var
  tipo2: TSimboloGramatical;
  r2: real;
  s2: string;
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalFactor(arbol^.hijos[2], estado, tipo2, r2, s2);
    if (tipo = Ttreal) or (tipo = Tcreal) then
      resultadoReal := Power(resultadoReal, r2);
  end;
end;

///////////////////////////////
// BASE, VALORES Y FUNCIONES
///////////////////////////////

// Base → sqrt(xgeneral) | - val | val
procedure evalBase(var arbol: TArbolDerivacion; var estado: TEstado;
                   var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
var
  resReal: real;
  resStr: string;
  t: TSimboloGramatical;
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    case arbol^.hijos[1]^.simbolo of
      Tsqrt:
      begin
        if arbol^.cant >= 4 then
        begin
          evalXGeneral(arbol^.hijos[3], estado, t, resReal, resStr);
          if resReal >= 0 then
            resultadoReal := sqrt(resReal)
          else
            resultadoReal := 0;
          tipo := Ttreal;
          resultadoStr := '';
        end;
      end;

      Tmenos:
      begin
        if arbol^.cant >= 2 then
        begin
          evalVal(arbol^.hijos[2], estado, t, resReal, resStr);
          resultadoReal := -resReal;
          tipo := Ttreal;
          resultadoStr := '';
        end;
      end;

      Vval:
      begin
        evalVal(arbol^.hijos[1], estado, tipo, resultadoReal, resultadoStr);
      end;
    end;
  end;
end;

// val → id | const | (xgeneral) | subcad(...) | search(...) | length(...)
procedure evalVal(var arbol: TArbolDerivacion; var estado: TEstado;
                  var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
var
  aux1, aux2, aux3: string;
  r1, r2, r3: real;
  t1, t2, t3: TSimboloGramatical;
  i: integer;
  posicion: integer;
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    case arbol^.hijos[1]^.simbolo of
      Tid:
      begin
        i := 1;
        while (i <= estado.cant) and (UpCase(estado.elementos[i].lexemaId) <> UpCase(arbol^.hijos[1]^.lexema)) do
          i := i + 1;

        if i <= estado.cant then
        begin
          tipo := estado.elementos[i].tipo;
          if (tipo = Ttreal) or (tipo = Tcreal) then
             resultadoReal := estado.elementos[i].valorReal
          else
             resultadoStr := estado.elementos[i].valorStr;
        end
        else
        begin
          writeln('ERROR: Variable "', arbol^.hijos[1]^.lexema, '" no declarada.');
          tipo := Error;
        end;
      end;

      Vconst:
      begin
        evalConst(arbol^.hijos[1], estado, tipo, resultadoReal, resultadoStr);
      end;

      Taparentesis:
      begin
        if arbol^.cant >= 3 then
          evalXGeneral(arbol^.hijos[2], estado, tipo, resultadoReal, resultadoStr);
      end;

      Tsubcad:
      begin
        if arbol^.cant >= 8 then
        begin
          evalXGeneral(arbol^.hijos[3], estado, t1, r1, aux1);
          evalXGeneral(arbol^.hijos[5], estado, t2, r2, aux2);
          evalXGeneral(arbol^.hijos[7], estado, t3, r3, aux3);
          tipo := Ttstring;
          resultadoStr := copy(aux1, round(r2), round(r3));
          resultadoReal := 0;
        end;
      end;

      Tsearch:
      begin
        if arbol^.cant >= 6 then
        begin
          evalXGeneral(arbol^.hijos[3], estado, t1, r1, aux1);
          evalXGeneral(arbol^.hijos[5], estado, t2, r2, aux2);
          tipo := Ttreal;
          posicion := pos(aux1, aux2);
          if posicion > 0 then
            resultadoReal := posicion
          else
            resultadoReal := 0;
          resultadoStr := '';
        end;
      end;

      Tlength:
      begin
        if arbol^.cant >= 4 then
        begin
          evalXGeneral(arbol^.hijos[3], estado, t1, r1, aux1);
          tipo := Ttreal;
          resultadoReal := length(aux1);
          resultadoStr := '';
        end;
      end;
    end;
  end;
end;

procedure evalConst(var arbol: TArbolDerivacion; var estado: TEstado;
                    var tipo: TSimboloGramatical; var resultadoReal: real; var resultadoStr: string);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    case arbol^.hijos[1]^.simbolo of
      Tcreal:
      begin
        tipo := Tcreal;
        resultadoReal := StrToFloat(arbol^.hijos[1]^.lexema);
        resultadoStr := '';
      end;

      Tcstring:
      begin
        tipo := Tcstring;
        // Remover comillas del string
        resultadoStr := Copy(arbol^.hijos[1]^.lexema, 2, Length(arbol^.hijos[1]^.lexema) - 2);
        resultadoReal := 0;
      end;
    end;
  end;
end;

///////////////////////////////
// OPERADORES
///////////////////////////////

procedure evalOpSum(var arbol: TArbolDerivacion; var operador: TSimboloGramatical);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    case arbol^.hijos[1]^.simbolo of
      Tmas: operador := Tmas;
      Tmenos: operador := Tmenos;
    else
      operador := Error;
    end;
  end;
end;

procedure evalOpMult(var arbol: TArbolDerivacion; var operador: TSimboloGramatical);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    case arbol^.hijos[1]^.simbolo of
      Tproducto: operador := Tproducto;
      Tdivision: operador := Tdivision;
    else
      operador := Error;
    end;
  end;
end;

procedure evalOpRel(var arbol: TArbolDerivacion; var operador: TSimboloGramatical);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    operador := arbol^.hijos[1]^.simbolo;
  end;
end;

///////////////////////////////
// READING Y WRITING
///////////////////////////////

procedure evalReading(var arbol: TArbolDerivacion; var estado: TEstado);
var
  prompt, lexemaid, entradaString: string;
  i: integer;
  entradaReal: real;
begin
  if (arbol <> nil) and (arbol^.cant >= 6) then
  begin
    // Remover comillas del prompt
    prompt := Copy(arbol^.hijos[3]^.lexema, 2, Length(arbol^.hijos[3]^.lexema) - 2);
    lexemaid := arbol^.hijos[5]^.lexema;

    i := 1;
    while (i <= estado.cant) and (UpCase(estado.elementos[i].lexemaId) <> UpCase(lexemaid)) do
      i := i + 1;

    if i <= estado.cant then
    begin
      write(prompt, ': ');
     if (estado.elementos[i].tipo = Ttreal) or (estado.elementos[i].tipo = Tcreal) then
      begin
        readln(entradaReal);
        estado.elementos[i].valorReal := entradaReal;
        estado.elementos[i].tipo := Ttreal;  // ← agregar
      end
      else if (estado.elementos[i].tipo = Ttstring) or (estado.elementos[i].tipo = Tcstring) then
      begin
        readln(entradaString);
        estado.elementos[i].valorStr := entradaString;
        estado.elementos[i].tipo := Ttstring;  // ← agregar
      end;
    end
    else
      writeln('ERROR: Variable "', lexemaid, '" no declarada.');
  end;
end;

procedure evalWriting(var arbol: TArbolDerivacion; var estado: TEstado);
var
  t: TSimboloGramatical;
  r: real;
  s: string;
begin
  if (arbol <> nil) and (arbol^.cant >= 5) then
  begin
    evalXGeneral(arbol^.hijos[3], estado, t, r, s);
    if (t = Ttreal) or (t = Tcreal) then
      write(r:0:2)
    else if (t = Ttstring) or (t = Tcstring) then
      write(s);

    evalWriteItemList(arbol^.hijos[4], estado);
    writeln;
  end;
end;

procedure evalWriteItemList(var arbol: TArbolDerivacion; var estado: TEstado);
var
  t: TSimboloGramatical;
  r: real;
  s: string;
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalXGeneral(arbol^.hijos[2], estado, t, r, s);
    if (t = Ttreal) or (t = Tcreal) then
      write(r:0:2)
    else if (t = Ttstring) or (t = Tcstring) then
      write(s);

    evalWriteItemList(arbol^.hijos[3], estado);
  end;
end;

///////////////////////////////
// CONDICIONALES Y BUCLES
///////////////////////////////

procedure evalLoop(var arbol: TArbolDerivacion; var estado: TEstado);
var
  r: boolean;
begin
  if (arbol <> nil) and (arbol^.cant >= 4) then
  begin
    evalCond(arbol^.hijos[2], estado, r);
    while r do
    begin
      evalBlock(arbol^.hijos[4], estado);
      evalCond(arbol^.hijos[2], estado, r);
    end;
  end;
end;

procedure evalConditional(var arbol: TArbolDerivacion; var estado: TEstado);
var
  r: boolean;
begin
  if (arbol <> nil) and (arbol^.cant >= 5) then
  begin
    evalCond(arbol^.hijos[2], estado, r);
    if r then
      evalBlock(arbol^.hijos[4], estado)
    else
      evalYesOrNoElse(arbol^.hijos[5], estado);
  end;
end;

procedure evalYesOrNoElse(var arbol: TArbolDerivacion; var estado: TEstado);
begin
  if (arbol <> nil) and (arbol^.cant > 0) then
    evalBlock(arbol^.hijos[2], estado);
end;

///////////////////////////////
// EVALUACIÓN DE CONDICIONES
///////////////////////////////
 // Evalúa el nodo P (maneja los OR encadenados)
procedure evalP(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
var
  tempResult: boolean;
begin
  // P → or cond1 P
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalCond1(arbol^.hijos[2], estado, tempResult);
    resultado := resultado or tempResult;
    // Procesar el P recursivo (hijo 3)
    evalP(arbol^.hijos[3], estado, resultado);
  end;
  // Si cant = 0, es epsilon, no hace nada (resultado queda como está)
end;

// Evalúa el nodo B (maneja los AND encadenados)
procedure evalB(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
var
  tempResult: boolean;
begin
  // B → and cond2 B
  if (arbol <> nil) and (arbol^.cant > 0) then
  begin
    evalCond2(arbol^.hijos[2], estado, tempResult);
    resultado := resultado and tempResult;
    // Procesar el B recursivo (hijo 3)
    evalB(arbol^.hijos[3], estado, resultado);
  end;
end;
// cond → cond1 P
procedure evalCond(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalCond1(arbol^.hijos[1], estado, resultado);
    evalP(arbol^.hijos[2], estado, resultado);  // ← delega en evalP
  end
  else
    resultado := false;
end;

procedure evalCond1(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
begin
  if (arbol <> nil) and (arbol^.cant >= 2) then
  begin
    evalCond2(arbol^.hijos[1], estado, resultado);
    evalB(arbol^.hijos[2], estado, resultado);  // ← delega en evalB
  end
  else
    resultado := false;
end;

// cond2 → not cond2 | cond3
procedure evalCond2(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    if arbol^.hijos[1]^.simbolo = Tnot then
    begin
      evalCond2(arbol^.hijos[2], estado, resultado);
      resultado := not resultado;
    end
    else
    begin
      evalCond3(arbol^.hijos[1], estado, resultado);
    end;
  end
  else
    resultado := false;
end;

// cond3 → xgeneral oprel xgeneral | [cond]
// CORRECTO:
procedure evalCond3(var arbol: TArbolDerivacion; var estado: TEstado; var resultado: boolean);
var
  t1, t2: TSimboloGramatical;
  r1, r2: real;
  s1, s2: string;
  lexOp: string;
begin
  if (arbol <> nil) and (arbol^.cant >= 1) then
  begin
    if arbol^.hijos[1]^.simbolo = Tacorchete then
    begin
      if arbol^.cant >= 3 then
        evalCond(arbol^.hijos[2], estado, resultado);
    end
    else
    begin
      if arbol^.cant >= 3 then
      begin
        evalXGeneral(arbol^.hijos[1], estado, t1, r1, s1);
        lexOp := arbol^.hijos[2]^.lexema;
        evalXGeneral(arbol^.hijos[3], estado, t2, r2, s2);

        if (t1 = Ttreal) or (t1 = Tcreal) then
        begin
          if lexOp = '='  then resultado := (r1 = r2)
          else if lexOp = '<>' then resultado := (r1 <> r2)
          else if lexOp = '<'  then resultado := (r1 < r2)
          else if lexOp = '>'  then resultado := (r1 > r2)
          else if lexOp = '<=' then resultado := (r1 <= r2)
          else if lexOp = '>=' then resultado := (r1 >= r2)
          else resultado := false;
        end
        else
        begin
          if lexOp = '='  then resultado := (s1 = s2)
          else if lexOp = '<>' then resultado := (s1 <> s2)
          else if lexOp = '<'  then resultado := (s1 < s2)
          else if lexOp = '>'  then resultado := (s1 > s2)
          else if lexOp = '<=' then resultado := (s1 <= s2)
          else if lexOp = '>=' then resultado := (s1 >= s2)
          else resultado := false;
        end;
      end;
    end;   // ← cierra el else
  end      // ← cierra el if (arbol <> nil)
  else
    resultado := false;
end;

end.


