unit ARBOL;
INTERFACE
USES CRT,CompoLexico;
Type
    TPunteroNodoArbol=^TNodoArbol;
    TnodoArbol=record
                     Simbolo:TSimboloGramatical;
                     Lexema:string;
                     Hijos:array[1..8] of TPunteroNodoArbol;
                     Cant:byte;
               End;
    TArbolDerivacion=TPunteroNodoArbol;
Procedure CrearNodo(Var Nodo: TPunteroNodoArbol;Simbolo:TSimbologramatical);
Procedure Agregar_NodoArbol(Var Hijo:TPunteroNodoArbol; Var CompLexH:TSimboloGramatical; Var LexemaH:string; Var NodoActual:TPunteroNodoArbol);
procedure GuardarArbol(Var ArchArbol:text;var ArbolD:TArbolDerivacion; desplazamiento:Integer);
implementation
Procedure CrearNodo(Var Nodo:TPunteroNodoArbol;Simbolo:TSimbologramatical); //cant se inicializa en 0
Begin
    New(Nodo);
    Nodo^.Cant:=0;
    Nodo^.Simbolo:=Simbolo;
    Nodo^.Lexema:='';
  end;
Procedure Agregar_NodoArbol(Var Hijo:TPunteroNodoArbol; Var CompLexH:TSimboloGramatical; Var LexemaH:string; Var NodoActual:TPunteroNodoArbol);
Begin
    inc(Nodoactual^.Cant);
    NEW (Hijo);
    Nodoactual^.hijos[Nodoactual^.cant] :=Hijo;
    Hijo^.Simbolo:=CompLexH;
    Hijo^.Lexema:=LexemaH;
    Hijo^.Cant:=0;
 end;
procedure GuardarArbol(Var ArchArbol:text;var ArbolD:TArbolDerivacion; desplazamiento:Integer);
Var i:Byte;
Begin
    Writeln(ArchArbol,'':desplazamiento,ArbolD^.Simbolo,' - ', ArbolD^.Lexema);
    For i:=1 to ArbolD^.Cant do
    GuardarArbol(ArchArbol,ArbolD^.Hijos[i],desplazamiento+2);
end;

end.


