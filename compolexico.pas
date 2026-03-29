unit CompoLexico;
{$mode objfpc}{$H+} {$codepage UTF8}
interface
uses
  crt;
Const
       FinArchivo=#0;
       maxid=100;
Type
  TSimboloGramatical=(  Pesos, Error, Tid, Tdospuntos, Topasig, Tcreal, Tcstring, Ttstring, Toprel,
    Tmas, Tmenos, Tproducto, Tdivision, Tacorchete, Tccorchete, Taparentesis, Tcparentesis,
    Tpotencia, Tsqrt, TEnd, Tcoma, Tpunto, Tpunycoma, Tdo, Tthen, Telse, Tand, Tor,
    Tnot, Ttreal, Tzafira, Tduring, Twhen, Tstart, Tinput, Tprint, Tsubcad,
    Tsearch, Tlength,VProgram, VDes, VDesc, VA, VType, VBody, VC, VSent, VAsig,
    VXgeneral, VAddterm,VTerm, VAddfactor, VFactor, VPowpart, VBase, VVal, VLoop,
    VBlock, VCond, VP, VCond1, VB, VCond2, VCond3, VReading, VWriting, VWriteitemlist,
    VConditional, VYesOrNoElse, VConst, Vopsum, Vopmult );

    TElementoTS=Record
                      Lexema:String[20];
                      CompLex:TSimboloGramatical;
                      end;
    T_Archivo=File of Char;
    TTS=Record
              Elementos:Array[1..maxid]of TElementoTS ;
              Cant: Integer;
               end;
Var
   TS:TTS;
Procedure InicializarTS(VAR TS:TTS);
Procedure AgregarTS(Var TS:TTS; Lexema:String; CompLex:TSimboloGramatical);
Procedure InstalarEnTS(Var TS:TTS; Lexema:String; Var CompLex:TSimboloGramatical);
Function EsSimboloGramatical(Var Fuente:T_Archivo; Var Control:Longint;Var Lexema:String; Var CompLex:TSimboloGramatical):Boolean;
Procedure LeerCar(Var Fuente:T_Archivo;Var Control:Longint;Var Car:Char);
Function EsIdentificador(Var Fuente:T_Archivo; Var Control:Longint; Var Lexema:String):Boolean;
Function EsConstante(Var Fuente:T_Archivo; Var Control:Longint; Var Lexema:String):Boolean;
Function EsCadena(Var Fuente:T_Archivo; Var Control:Longint; Var Lexema:String):boolean;
Procedure ObtenerSiguienteCompLex(Var Fuente:T_Archivo;Var Control:Longint; Var CompLex:TSimboloGramatical;Var Lexema:String;Var TS:TTS);

implementation
Procedure InicializarTS(VAR TS:TTS);     //deja la tabla de símbolos vacía (pone la cantidad en 0).
Begin
     TS.Cant:=0;
  end;
Procedure AgregarTS(Var TS:TTS; Lexema:String; CompLex:TSimboloGramatical);  //agrega un nuevo par (lexema, componente léxico) a la tabla.
begin
     inc(TS.Cant);
     TS.Elementos[TS.Cant].Lexema:=Lexema;
     TS.Elementos[TS.Cant].CompLex:=CompLex;
     end;
Procedure InstalarEnTS(Var TS:TTS; Lexema:String; Var CompLex:TSimboloGramatical);   //busca un lexema en la tabla, si ya existe, devuelve su componente léxico, si no existe
                                                                                    //lo guarda como un identificador nuevo (Tid) y lo agrega a la tabla.

Var
   salida:Boolean;
   q:Integer;
Begin
//Buscar lexema entre los elementos de la tabla
  q:=1;
  salida:=False;
  While (NOT(salida)) and (q<=TS.Cant)do
  Begin
   If  (TS.Elementos[q].Lexema)= UpCase(Lexema) then
      Begin
      salida:=TRUE;
      end
  else
      inc(q);
  end;
  If salida=TRUE then
                  CompLex:=TS.Elementos[q].CompLex   //Si existe, devolver el CompLex correspondiente a ese elemento
  else
      Begin
      CompLex:=Tid;
      AgregarTS(TS,Lexema,CompLex);//Sino asigna al CompLex=id y lo agrega a la TS
      end;
end;
Function EsSimboloGramatical(Var Fuente:T_Archivo; Var Control:Longint;Var Lexema:String; Var CompLex:TSimboloGramatical):Boolean;
Var Caracter:Char;
Begin
    EsSimboloGramatical:=False;
    LeerCar(Fuente,Control,Caracter);
    Case Caracter of
         ';':Begin
                  Lexema:=';';
                  CompLex:=Tpunycoma;
                  inc(control);
                  EsSimboloGramatical:=True;
                   end;
         '.': Begin
                  Lexema:='.';
                  CompLex:=Tpunto;
                  inc(control);
                  EsSimboloGramatical:=True;
                   end;
         ',': Begin
                  Lexema:=',';
                  CompLex:=Tcoma;
                  inc(control);
                  EsSimboloGramatical:=True;
                   end;
         '+': Begin
                   Lexema:='+';
                   CompLex:= Tmas;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;
               '-': Begin
             inc(Control);
             LeerCar(Fuente, Control, Caracter);
             If Caracter=')' then
               Begin
                 Lexema:= '-)';
                 CompLex:= Topasig;
                 inc(control);
                 EsSimboloGramatical:=True;
               end
             else
               begin
                 Lexema:='-';
                 CompLex:= Tmenos;
                 // NO hacer inc(control) acá: el carácter que leímos
                 // (el que no era ')') todavía no fue consumido
                 EsSimboloGramatical:=True;
               end;
           end;

         '*': Begin
                   Lexema:='*';
                   CompLex:= Tproducto;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;

         '/': Begin
                   Lexema:='/';
                   CompLex:= Tdivision;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;

         '^': Begin
                   Lexema:='^';
                   CompLex:= Tpotencia;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;
         '<':Begin
                  inc(Control);
                  LeerCar(Fuente,Control,caracter);
                  Case caracter of
                       '>':Begin
                                  Lexema:='<>';
                                  CompLex:=TOprel;
                                  inc(control);
                                  EsSimboloGramatical:=True;
                                  end;
                       '=':Begin
                                Lexema:='<=';
                                CompLex:=TOprel;
                                inc(control);
                                EsSimboloGramatical:=True;
                                end;
                       else
                           Begin
                           Lexema:='<';
                           CompLex:=TOprel;
                           EsSimboloGramatical:=True;
                           end;
                       end;
                       end;


         '>':Begin
                  inc(Control);
                  LeerCar(Fuente,Control,caracter);
                  Case caracter of
                       '=':Begin
                                Lexema:='>=';
                                CompLex:=TOprel;
                                inc(control);
                                EsSimboloGramatical:=True;
                                end;
                       else
                           Begin
                           Lexema:='>';
                           CompLex:=TOprel;
                           EsSimboloGramatical:=True;
                           end;
                       end;
                       end;

         '=':Begin
                   Lexema:='=';
                   CompLex:=TOprel;
                   inc(Control);
                   EsSimboloGramatical:=True;
                   end;

         '(':Begin
                   Lexema:='(';
                   CompLex:= Taparentesis;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;

         ')':Begin
                   Lexema:=')';
                   CompLex:= Tcparentesis;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;
         '[':Begin
                   Lexema:='[';
                   CompLex:= Tacorchete;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;
         ']':Begin
                   Lexema:=']';
                   CompLex:= Tccorchete;
                   inc(control);
                   EsSimboloGramatical:=True;
                   end;

end;
end;

Procedure LeerCar(Var Fuente:T_Archivo;Var Control:Longint;Var Car:Char);
Begin
     If Control<FileSize(Fuente)then
        Begin
        Seek(Fuente,Control);
        Read(Fuente,Car);
        end
     Else
         Car:=FinArchivo;
end;
Function EsIdentificador(Var Fuente:T_Archivo; Var Control:Longint; Var Lexema:String):Boolean;
Const
  q0=0;
  F=[3];
Type
  Q=0..3;
  Sigma=(C, O ,D );
  TipoDelta=Array[Q,Sigma] of Q;
Var
  EstadoActual:Q;
  Delta:TipoDelta;
  P:Longint;
  Car:Char;
Function CarASimb(Car:Char):Sigma;
Begin
  Case Car of
    'a'..'z', 'A'..'Z', '_':CarASimb:=C;
    '0'..'9'          :CarASimb:=D;
  else
   CarASimb:=O;
  End;
End;
Begin
  P:=Control;
  Delta[0,C]:=1;
  Delta[0,O]:=2;
  Delta[0,D]:=2;
  Delta[1,C]:=1;
  Delta[1,O]:=3;
  Delta[1,D]:=1;
  EstadoActual:=q0;
  Lexema:='';
  While EstadoActual in [0,1] do
  Begin
     LeerCar(Fuente,P,Car);
     EstadoActual:=Delta[EstadoActual,CarASimb(Car)];
     If EstadoActual=1 then
        Lexema:=Lexema+Car;
     inc(P);
  end;
  If EstadoActual in F then
                  Control:=P-1;
  EsIdentificador:=EstadoActual in F;
End;
Function EsConstante(Var Fuente:T_Archivo; Var Control:Longint; Var Lexema:String):Boolean;
Const
  q0=0;
  F=[1,5];
Type
  Q=0..5;
  Sigma=(Punto, Digito, Otro);
  TipoDelta=Array[Q,Sigma] of Q;
Var
  EstadoActual:Q;
  P:longint;
  Delta:TipoDelta;
  Car:Char;
Function CarASimb(Car:Char):Sigma;
Begin
  Case Car of
    '.'              :CarASimb:=Punto;
    '0'..'9'	     :CarASimb:=Digito;
  else
   CarASimb:=Otro
  End;
End;
Begin
  P:=Control;
  {Cargar la tabla de transiciones}
  Delta[0,Digito]:=1;
  Delta[0,Punto]:=3;
  Delta[0,Otro]:=3;
  Delta[1,Digito]:=1;
  Delta[1,Punto]:=2;
  Delta[1,Otro]:=5;
  Delta[2,Digito]:=4;
  Delta[2,Punto]:=3;
  Delta[2,Otro]:=3;
  Delta[4,Digito]:=4;
  Delta[4,Punto]:=5;
  Delta[4,Otro]:=5;
  Lexema:='';
  {Recorrer la cadena de entrada y cambiar estados}
  EstadoActual:=q0;
  While EstadoActual in [0,1,2,4] do
    Begin
       LeerCar(Fuente,P,Car);
       EstadoActual:=Delta[EstadoActual,CarASimb(Car)];
       If EstadoActual in [0,1,2,4] then
          Lexema:=Lexema+Car;
       inc(P);
    end;
    If EstadoActual in F then
                    Control:=P-1;
    EsConstante:=EstadoActual in F;
End;

Function EsCadena(Var Fuente:T_Archivo; Var Control:Longint; Var Lexema:String):boolean;
Const
     q0=0;
     F=[3];
Type
    Q=0..3;
    Sigma=(Comillas, Otro);
    TipoDelta=Array[Q,Sigma] of Q;
    Var
      EstadoActual:Q;
      Delta:TipoDelta;
      P:Longint;
      Car:Char;
Function CarASimb(Car:Char):Sigma;
Begin
  If Car='"' then
                 Begin
                 CarASimb:=Comillas;
                 end
  else
   CarASimb:=Otro;
  End;
Begin
  P:=Control;
  {Cargar la tabla de transiciones}
  Delta[0,Comillas]:=1;
  Delta[0,Otro]:=2;
  Delta[1,Comillas]:=3;
  Delta[1,Otro]:=1;
  {Recorrer la cadena de entrada y cambiar estados}
  EstadoActual:=q0;
  Lexema:='';
  While EstadoActual in [0,1] do
  Begin
     LeerCar(Fuente,P,Car);
     EstadoActual:=Delta[EstadoActual,CarASimb(Car)];
     If EstadoActual in [1,3] then
                              Begin
                              Lexema:=Lexema+Car;
                              end;
     inc(P);
  end;
  If EstadoActual in F then
                  Control:=P;
  EsCadena:=EstadoActual in F;
End;

Procedure ObtenerSiguienteCompLex(Var Fuente:T_Archivo;Var Control:Longint; Var CompLex:TSimboloGramatical;Var Lexema:String;Var TS:TTS);
Var
   caracter:char;
Begin {La TS ya ingresa cargada con las Palabras Reservadas (EL lexema y el complex de la palabra reservada)}
  {Avanzar el Control salteando todos los caracteres de control y espacios, hasta el primer carácter significativo}
  LeerCar(Fuente,Control,Caracter);
  While Caracter in [#1..#32] do
  Begin
       inc(Control);
       LeerCar(Fuente,Control,Caracter);
  end;
  if Caracter=FinArchivo then
         Complex:=Pesos
  else
      begin
           If EsIdentificador(Fuente,Control,Lexema) then
		InstalarEnTS(TS,Lexema,CompLex)
                 else If EsConstante(Fuente,Control,Lexema) then
		      CompLex:=Tcreal
                       else If EsCadena(Fuente,Control,Lexema) then
		              CompLex:=Tcstring
                              else If  NOT(EsSimboloGramatical(Fuente, Control, Lexema,CompLex)) then
                                   CompLex:=Error;
      End;
end;
end.



