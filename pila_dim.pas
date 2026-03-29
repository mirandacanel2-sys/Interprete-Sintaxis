UNIT PILA_DIM;
INTERFACE
Uses ARBOL,crt,CompoLexico;
TYPE
T_datoP= Record
         X:TSimboloGramatical;
         PArbol:TArbolDerivacion;
         end;
T_PUNT=^T_NODO;
T_NODO=RECORD
	INFO:T_datoP;
	SIG:T_PUNT;
	END;
T_PILA= RECORD
	TOPE: T_PUNT;
	TAM: WORD;
	END;
PROCEDURE CREARPILA(VAR P:T_PILA);
PROCEDURE APILAR (VAR P:T_PILA;X:TSimboloGRamatical;Nodo:TArbolDerivacion);
PROCEDURE DESAPILAR(VAR P:T_PILA;Var X:TSimboloGramatical;Var Nodo:TArbolDerivacion);
Procedure Apilar_Todos(VAR padre:TPunteroNodoArbol;VAR Pila:T_PILA);

IMPLEMENTATION
PROCEDURE CREARPILA(VAR P:T_PILA);
BEGIN
   P.TAM:=0;
   P.TOPE:=NIL;
END;
PROCEDURE APILAR (VAR P:T_PILA;X:TSimboloGRamatical;Nodo:TArbolDerivacion);
VAR DIR:T_PUNT;
    elemento:T_datoP;
BEGIN
elemento.X:=X;
elemento.PArbol:=Nodo;
NEW (DIR);
DIR^.INFO:= elemento;
DIR^.SIG:= P.TOPE;
P. TOPE:=DIR;
INC(P.TAM);
END;

PROCEDURE DESAPILAR(VAR P:T_PILA;Var X:TSimboloGramatical;Var Nodo:TArbolDerivacion);
VAR DIR:T_PUNT;
BEGIN
   Nodo:=P.TOPE^.INFO.PARBOL;
   X:= P.TOPE^.INFO.X;
   DIR:=P.TOPE;
   P.TOPE:=P.TOPE^.SIG;
   DISPOSE (DIR);
   DEC(P.TAM);
END;

Procedure Apilar_Todos(VAR padre:TPunteroNodoArbol;VAR Pila:T_PILA); VAR DIR:T_PUNT; i:Byte;
Begin
   For i:=padre^.Cant downto 1 do
   Begin
     Apilar(Pila,padre^.hijos[i]^.Simbolo,padre^.hijos[i]);
   end;
end;
END.



