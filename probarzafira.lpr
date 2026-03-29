program probarzafira;
uses crt, CompoLexico, AnalizadorSintactico, ARBOL, Evaluador;

var
  Fuente: T_Archivo;
  TArbol: TArbolDerivacion;
  ArchArbol: Text;
  Estado: TEstado;  // Cambié a TEstado

begin
  ClrScr;
  Assign(Fuente, 'testzafira.txt');
  Reset(Fuente);

  // Construir árbol sintáctico
  Analizador_sintactico(Fuente, TArbol);

  // Guardar árbol opcionalmente
  Assign(ArchArbol, 'arbol.txt');
  Rewrite(ArchArbol);
  GuardarArbol(ArchArbol, TArbol, 0);
  Close(ArchArbol);

  // Inicializar estado
  inicializar_estado(Estado);  // Agregar esta línea

  // Ejecutar programa
  EvalProgram(TArbol, Estado);

  readkey;
  Close(Fuente);
end.


