unit AnalizadorSintactico;
{$mode objfpc}{$H+}{$codepage UTF8}
interface
uses crt,PILA_DIM,CompoLexico,ARBOL,matrices;
Type
    FileofChar=File of Char;

Procedure Analizador_Sintactico(Var Fuente:FileofChar; Var Raiz:TArbolDerivacion);

implementation
Procedure Analizador_Sintactico(Var Fuente:FileofChar; Var Raiz:TArbolDerivacion);
Var
   TAS:T_TAS;
   TS:TTS;
   Pila,Pila2,Pila3:T_Pila;
   estado:(EnProceso,ErrorSintactico,Exito);
   Control:Longint;
   CompLex,CompLexH,X:TSimboloGramatical;
   Lexema,LexemaH:String;
   Nodoactual:TArbolDerivacion;
   i:byte;
   Hijo:TPunteroNodoArbol;
Begin
   CREARPILA(Pila);
   inicializar_matriz(TAS);
   InicializarTS(TS);
  AgregarTS(TS,'ZAFIRA',Tzafira);
  AgregarTS(TS,'DURING',Tduring);
  AgregarTS(TS,'WHEN',Twhen);
  AgregarTS(TS,'START',Tstart);
  AgregarTS(TS,'T_STRING',Ttstring);
  AgregarTS(TS,'ELSE',TElse);
  AgregarTS(TS,'END',TEnd);
  AgregarTS(TS,'DO',TDo);
  AgregarTS(TS,'THEN',TThen);
  AgregarTS(TS,'T_REAL',TtReal);
  AgregarTS(TS,'AND',Tand);
  AgregarTS(TS,'OR',Tor);
  AgregarTS(TS,'NOT',Tnot);
  AgregarTS(TS,'SQRT',Tsqrt);
  AgregarTS(TS,'INPUT',Tinput);
  AgregarTS(TS,'PRINT',Tprint);
  AgregarTS(TS,'SUBCAD',Tsubcad);
  AgregarTS(TS,'SEARCH',Tsearch);
  AgregarTS(TS,'LENGTH',Tlength);
   Control:=0;
   CrearNodo(Raiz,VProgram);
   Apilar(Pila,Pesos,nil);
   Apilar(Pila,VProgram,Raiz);
   estado := EnProceso;
   ObtenerSiguienteCompLex(Fuente,Control,CompLex,Lexema,TS);
   Writeln('Comienzo del Analisis Sintactico');
   Writeln(CompLex, '-', Lexema);
   While estado=EnProceso do
    Begin
       Desapilar(Pila,X,Nodoactual);
       If X in [Tid..Tlength] then
          Begin
            If X=CompLex then
            Begin
                  Nodoactual^.lexema:=Lexema;
                  ObtenerSiguienteCompLex(Fuente,Control,CompLex,Lexema,TS);
                  Writeln(CompLex, '-', Lexema);
            end
            else
                Begin
                estado:=ErrorSintactico;
                Writeln('Error Sintactico: Se esperaba ', X, ' y se encontro ', CompLex, ' - ', Lexema);
                end;
          end
       Else
           If X in [VProgram..Vopmult] then
           begin
              If TAS[X,CompLex]=nil then
                 Begin
                 estado:=ErrorSintactico;
                 Writeln('Error Sintactico: Desde la variable ', X, ' no se puede derivar ', CompLex, ' - ', Lexema);
                 end
              else
                  Begin
                   For  i:=1 to TAS[X,CompLex]^.Tam do
                   begin
                      CompLexH:=TAS[X,CompLex]^.elementos[i];
                      LexemaH:='';
                      Agregar_NodoArbol(Hijo,CompLexH,LexemaH,Nodoactual);
                   end;
                   Apilar_Todos(Nodoactual,Pila);
                   end;
           end
       else
           //X=Pesos
           If CompLex=Pesos then
              estado:=Exito
           else
               estado:=ErrorSintactico;
    end;


  end;
{Funcionamiento: algoritmo de reconocimiento
Al inicio, apilar $ y luego el símbolo inicial de la gramática
Repetir hasta Éxito o Error
Sea X el símbolo al tope de la pila, y a el símbolo en la entrada
Desapilar X
Si X es Terminal
Si X=CompLex, avanzar el control al siguiente símbolo de entrada
Sino, Error
Si X es Variable
Si TAS [X, a] =vacía, Error
Sino, sea TAS [X, a] =A1A2...An
apilar An An-1 ... A1           (A1 queda al tope)
agregar los hijos A1 A2 ... An al nodo X en el árbol de derivación
Si X=a=$, Éxito}

{//Se debe derivar la prod en el arbol y apilarla
//Primero crear los nodos del arbol con c/u de los Simbolos Gramaticales
//de la produccion de la TAS, de uno en adelante.
//Apilar los elementos de la produccion del ultimo al primero
// y con el nodo del arbol asociado

//Se agregan los simbolos de la produccion al árbol y luego se apilan,
//desde el ultimo al primero,
//cada uno junto al puntero del nodo del arbol en el cual se encuentran   }
end.



