% ----------- Autores -----------
% ERICK M. L. PACHECO
% CARLOS H. V. MARQUES

% --- Base de dados ---

% Sao Paulo
voo(sao_paulo, mexico, sp1, 8:25, (mesmo, 20:25), 0, gol, [dom, qua, sex]).
voo(sao_paulo, mexico, sp2, 19:25, (mesmo, 23:25), 0, azul, [sex, sab]).
voo(sao_paulo, mexico, sp3, 9:25, (mesmo, 19:00), 1, latam, [seg, ter, qui, sab]).
voo(sao_paulo, nova_york, sp4, 9:25, (mesmo, 19:00), 0, tam, [dom, qua, sex]).
voo(sao_paulo, lisboa, sp5, 10:25, (seguinte, 22:30), 1, latam, [seg, sex, sab]).
voo(sao_paulo, madrid, sp6, 00:13, (seguinte, 9:27), 0, gol, [dom, qua, sex]).
voo(sao_paulo, londres, sp7, 15:30, (mesmo, 23:00), 1, latam, [seg, qui, sex]).
voo(sao_paulo, paris, sp8, 1:25, (mesmo, 19:53), 0, gol, [dom, seg, ter, qua, sab]).

% Mexico
voo(mexico, nova_york, me1, 7:00, (mesmo, 20:00), 0, gol, [qui, sex, sab]).
voo(mexico, madrid, me2, 8:00, (mesmo, 22:58), 1, latam, [seg, qua, sex]).

% Nova York
voo(nova_york, londres, ny1, 23:00, (seguinte, 10:00), 1, latam, [ter, qua, qui, sex]).

% Londres
voo(londres, lisboa, lo1, 17:10, (seguinte, 12:00), 0, latam, [seg, ter, qui]).
voo(londres, paris, lo2, 18:20, (seguinte, 12:00), 0, latam, [qua, qui, sab]).
voo(londres, estocolmo, lo3, 19:30, (seguinte, 12:00), 1, latam, [dom, ter, qua, qui]).

% Madrid
voo(madrid, paris, ma1, 13:22, (mesmo, 17:23), 0, latam, [qui, sex, sab]).
voo(madrid, roma, ma2, 00:00, (mesmo, 10:00), 0, latam, [ter, qua, qui]).
voo(madrid, frankfurt, ma3, 21:00, (seguinte, 1:00), 1, latam, [seg, ter, qua, qui]).

% Frankfurt
voo(frankfurt, estocolmo, fr1, 16:45, (mesmo, 17:23), 0, latam, [qui, sex, sab]).
voo(frankfurt, roma, fr2, 14:35, (mesmo, 17:23), 0, latam, [qui, sex, sab]).

% --------- PREDICADOS ---------

% - Auxiliares gerais -

pertence(X,[X|Cauda]).
pertence(X,[Cabeca|Cauda]) :- pertence(X, Cauda).

min_para_hora(Min, H:M) :- divmod(Min, 60, H, M).
% divmod(Dividendo, divisor, quociente, resto).

% 1. Verificar se existe voo direto:
voo_direto(Origem, Destino, Companhia, Dias, Horario) :-
    voo(Origem, Destino, _, Horario, (_,_), Escalas, Companhia, Lista_Dias),
    pertence(Dias, Lista_Dias),
    Escalas =:= 0.

% 2. Filtrar voo por dia:
filtra_voo_dia_semana(Origem, Destino, Dia_Semana, Horario_Saida, Horario_Chegada, Companhia) :-
    voo(Origem, Destino, _, Horario_Saida, (_, Horario_Chegada), _, Companhia, Lista_Dias),
    pertence(Dia_Semana, Lista_Dias).

% 3. Roteiro de viagem:
roteiro(A, X, [Lista_Voos]) :-
    voo(A, X, Lista_Voos,_,_,_,_,_), !. % Cut para impedir infinitas combinacoes
    roteiro(A, X, [Cod|T]) :- voo(A, B, Cod,_,_,_,_,_), roteiro(B, X, T).

% 4. Menor tempo de viagem:

% --- Auxilares ---
menor_Viagem([Cabeca,Cauda],[Cabeca_V,Cauda_V], Menor, Cod_Menor) :-
    Cabeca < Cauda, Menor is Cabeca, Cod_Menor = Cabeca_V, !;
    Menor is Cauda, Cod_Menor = Cauda_V.
menor_Viagem([Cabeca|Cauda],[Cabeca_V|Cauda_V], Menor, Cod_Menor) :-
    menor_Viagem(Cauda, Cauda_V, Menor_2, Cod_Menor_2),
    (Cabeca < Menor_2, Menor is Cabeca, Cod_Menor = Cabeca_V, !;
    Menor is Menor_2, Cod_Menor = Cod_Menor_2).

duracao_Voo(Origem, Destino, Codigo, Duracao) :-
    % Se
    voo(Origem, Destino, Codigo, Hr_Saida:Min_Saida, (Dia_Chegada, Hr_Chegada:Min_Chegada),_,_,_),
    (Dia_Chegada = seguinte,
    Saida is Hr_Saida*60+Min_Saida,
    Chegada is (Hr_Chegada*60+Min_Chegada)+1440,
    Duracao is Chegada - Saida);
    % Senao
    voo(Origem, Destino,Codigo, Hr_Saida:Min_Saida, (Dia_Chegada, Hr_Chegada:Min_Chegada),_,_,_),
    (Dia_Chegada = mesmo,
    Saida is Hr_Saida*60+Min_Saida,
    Chegada is Hr_Chegada*60+Min_Chegada,
    Duracao is Chegada - Saida).

% --- Principal ---
menorDuracao(Origem, Destino, Dia, Horario_Saida, Horario_Chegada, Companhia) :-
    findall(Tempo, duracao_Voo(Origem, Destino, Codigo, Tempo), Duracoes),
    findall(Voo, voo(Origem, Destino, Voo, _, (_,_),_,_,Dias), Voos),
    menor_Viagem(Duracoes, Voos, Menor, Cod_Menor),
    voo(_,_, Cod_Menor, Horario_Saida, (_, Horario_Chegada),_, Companhia, Dias),
    pertence(Dia, Dias).

% ------------------------------

% 5. Duracao total de uma viagem de X para Y
roteiro(Origem, Destino, DiaSaida, HorSaida, Duracao):-
    roteiro(Origem, Destino, [X|Y]),
    calculatempo([X|Y], Dura),
    voo(_,_, X, HorSaida,(_,_),_,_, [DiaSaida|_]),
    min_para_hora(Dura, Duracao).

calculatempo([],0).
calculatempo([Codigo|Lista],Tempo):-
    duracao_Voo(_, _, Codigo, T1),
    calculatempo(Lista,T2),
    Tempo is T1 + T2.

% --------------------------------------------------------------
