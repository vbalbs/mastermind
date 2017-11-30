#!/usr/bin/swipl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    NOME: Vinicius Balbino de Souza                         %
%                              RA: 178183                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             REGRAS INICIAIS                                %
%                                                                            %
% Aqui foram colocadas as regras para as combinacoes possiveis de quatro     %
% cores e para possiveis resultados, alem de dizer quantas cores existem     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cor(Cor) :- member(Cor,[1,2,3,4,5,6]).
possiveis(Pos) :- member(Pos, [0,1,2,3,4]).

possivelResultado([Bons,Regular]) :-
  possiveis(Bons),
  possiveis(Regular),
  Bons + Regular >= 2,
  4 >= Bons + Regular.

possivelCodigo([C1,C2,C3,C4]) :-
  cor(C1),
  cor(C2),
  cor(C3),
  cor(C4),
  C1 \= C2,
  C1 \= C3,
  C1 \= C4,
  C2 \= C3,
  C2 \= C4,
  C3 \= C4.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FUNTORES DE CALCULO                              %
%                                                                            %
% aqui sao feitos os proximos chutes, baseados em resultados recebidos pelo  %
% avaliador, verificando o numero de bons e regulares, e reduzindo a quanti_ %
% dade de elementos em nossa lista de possiveis solucoes, gracas ao livro    %
% the Art of Prolog, como conversado com o                                   %
% professor em sala de aula, alem disso, a pergunta "o avaliador esta mentin_%
% do?" ocorre aqui                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


calculaPossibilidade(CodigoChutado, PossivelProximo, Resultado) :-
  possivelCodigo(PossivelProximo),
  possivelCodigo(CodigoChutado),
  calculaResultado(CodigoChutado, PossivelProximo, Resultado).

calculaResultado(Chute, Proximo, Resultado) :-
  calculaBons(Chute, Proximo, Bons, ChuteSemBons, ProximoSemBons),
  calculaRegular(ChuteSemBons, ProximoSemBons, Regular),
  Resultado = [Bons, Regular].

calculaBons([], [], 0, [], []).
calculaBons([H_Chute|T_Chute], [H_Proximo|T_Proximo], Bons, ChuteSemBons, ProximoSemBons) :-
  (
      H_Chute = H_Proximo,!,
      calculaBons(T_Chute, T_Proximo, BonsCalda, ChuteSemBons, ProximoSemBons),
      Bons is 1 + BonsCalda
  ;
      calculaBons(T_Chute, T_Proximo, Bons, CaldaChuteSemBons, CaldaProximoSemBons),
      ProximoSemBons = [H_Proximo|CaldaProximoSemBons],
      ChuteSemBons = [H_Chute|CaldaChuteSemBons]
  ).

calculaRegular([], _, 0).
calculaRegular([H_Chute|T_Chute], Proximo, Regular) :-
  (
      member(H_Chute, Proximo),!,
      select(H_Chute, Proximo, NovoProximo),!,
      calculaRegular(T_Chute, NovoProximo, RegularCalda),
      Regular is 1 + RegularCalda
  ;
      calculaRegular(T_Chute, Proximo, Regular)
  ).

calculaChuteValor(Codigo, ArvoreDePossibilidades, ChuteValor) :-
    findall(Resultado, possivelResultado(Resultado), Resultados),
    length(ArvoreDePossibilidades, InitialLength),
    Goal = (
            member(PossivelResultado, Resultados),
                Goal2 = (
                    calculaPossibilidade(Codigo, Possibilidade, PossivelResultado),
                    member(Possibilidade, ArvoreDePossibilidades )
                  ),
              findall(Possibilidade, Goal2, NovoPossibilities),
              length(NovoPossibilities, NovoLength),
              PossivelResultadoValor is InitialLength - NovoLength
             ),
      findall(PossivelResultadoValor, Goal, TodasPossibilidades),
      findSmallest(TodasPossibilidades, ChuteValor).

calculaMentira(0) :-
  write('erro'),
  nl.
calculaMentira(_) :-
  true.

julgamento([4,0]) :-
  write('ganhei'),
  nl.
julgamento(_) :-
  write('erro'),
  nl, !.

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            JOGANDO O JOGO                                  %
%                                                                            %
% implementacao do jogo em si. Gera uma arvore de possibilidades com todas   %
% as possiveis e as coloca em Codigos, retirando-as sempre que encontrarmos  %
% resultados que nao batem. Escrevemos 'erro' quando nao ha solucao e retorn_%
% amos a solucao caso exista.                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

play :-
  findall(Codigo, possivelCodigo(Codigo), Codigos),
  playGame(Codigos, 1, [0,0]).

playGame(_, _, [4,0]) :-
  write('ganhei'),
  nl, !.
playGame([Solucao], _, _) :-
  write(Solucao),
  nl,
  read(UserResultado),
  julgamento(UserResultado), !.

playGame(Codigos, Turno, _) :-
(
  Turno = 1,!,
  write('[1,2,3,4]'),
  nl,
  read(UserResultado),
  findall(Codigo, calculaPossibilidade([1,2,3,4], Codigo, UserResultado), NovoCodigos),
  playGame(NovoCodigos, 2, UserResultado)
;
  Goal =
  (
      member(Chute, Codigos),
      calculaChuteValor(Chute, Codigos, ChuteValor)
  ),
  findall(ChuteValor-Chute, Goal, TodasPossibilidades),
  findLargestKey(TodasPossibilidades, _-Move ),
  write(Move), nl,
  read(UserResultado),
  Goal2 =
  (
      member(Codigo, Codigos),
      calculaPossibilidade(Move, Codigo, UserResultado)
  ),
  findall(Codigo, Goal2, NovoCodigos),
  length(NovoCodigos,L),
  calculaMentira(L),
  NovoTurn is Turno + 1,
  playGame(NovoCodigos, NovoTurn, UserResultado)
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FUNTORES AUXILIARES                              %
%                                                                            %
% funtores utilizados para encontrar maior/menor elementos em listas adaptada%
% ao nosso problema, alem de um funtor que retira elementos 0 de uma lista,  %
% grande parte foi copiada do livro The Art of Prolog.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

findSmallest([H|T], Smallest) :-
  findSmallest(T, H, Smallest).
findSmallest([], Smallest, Smallest).
findSmallest([H|T], Running, Smallest) :-
  (
      H < Running,!,
      findSmallest(T, H, Smallest)
  ;
      findSmallest(T, Running, Smallest)
  ).

findLargestKey( [V-H|T], Largest ) :-
  findLargestKey( T, V-H, Largest ).
findLargestKey( [], Largest, Largest ).
findLargestKey( [V-H|T], VR-HR, Largest ) :-
  (
      V > VR,!,
      findLargestKey(T, V-H, Largest )
  ;
      findLargestKey(T, VR-HR, Largest)
  ).

removeZeros([],[]).
removeZeros([Head|Tail],ListWithoutZeros) :-
(
	Head = 0,!,
	removeZeros(Tail,ListWithoutZeros)
;
	removeZeros(Tail,TailWithoutZeros),
	ListWithoutZeros = [Head|TailWithoutZeros]
).

% COMECA O JOGUINHO
:- play, halt.
