#!/usr/bin/python3
# NOME: Vinícius Balbino de Souza
# RA: 178183

# Gera uma lista S com todas as possiveis solucoes para o jogo
def criaCodigos():
	lista = []
	for i in [1,2,3,4,5,6]:
		for j in [1,2,3,4,5,6]:
			for k in [1,2,3,4,5,6]:
				for l in [1,2,3,4,5,6]:
					lista.append([i,j,k,l])
	lista.insert(0, [6,5,4,3])
	return lista

# Verifica se um chute existe, utilizando as regras aprendidas no trabalho passado
def verificaValidade(score):
	return ((int(score/10) + score%10) <= 4)

# Calcula a tupla (Bons, Regulares) para um chute.
def verificaChute(chute, candidato):
	bons = acertos(chute, candidato)
	regulares = coincidencias(chute, candidato)
	return bons*10 + (regulares - bons)

# Calcula a quantidade de Bons no meu chute comparado ao elemento analisado da lista de possiveis solucoes
def acertos(chute, candidato):
	num_acertos = 0
	for i in [0,1,2,3]:
		if chute[i] == candidato[i]:
			num_acertos += 1
	return num_acertos

# Calcula a quantidade de Regulares no meu chute comparado ao elemento analisado da lista de possiveis solucoes
def coincidencias(chute, candidato):
	num_coincidencias = 0
	for elem1 in chute:
		if elem1 in candidato:
			num_coincidencias += 1
	return num_coincidencias

# Gerador da nova lista de possibilidades levando em consideracao o chute e o score passados
def verificaExistencia(lista_de_chutes, chute, score):
	nova_lista = []
	for candidato in lista_de_chutes:
		if (verificaChute(chute,candidato) == int(score)):
			nova_lista.append(candidato)
	return nova_lista

# Argumentos de play: vetor de soluções.
# Ele sempre chutara o primeiro elemento do vetor de solucoes,
#e realizara a verificacao para eliminar possiveis proximos chutes incoerentes
# Foi adicionado ao comeco da lista o elemento [6,5,4,3] (que ocorre repetido),
# para que o numero de chutes diminua.
def play(lista):
	chute = lista[0]
	print (''.join(str(x) for x in chute)) # imprime o primeiro chute transformado em uma string
	resp = input() # recebe valor
	if (int(resp) == 40):
	 	print("ganhei") # caso de vitoria
	elif (not verificaValidade(int(resp))):
		print("erro")  # caso o jogador tenha colocado uma resposta do tipo 50, ele dara erro nessa linha
	else:
		nova_lista = verificaExistencia(lista, chute, resp) # gera nova lista de chutes
		if (len(nova_lista) == 0): #  compara com 0 pois pode ser que o usuario tenha mentido
			print("erro") # caso tenha mentido
		else:
			play(nova_lista)

# Comeca o jogo com a lista de solucoes para o jogo com 4 posicoes
def main():
	s = criaCodigos()
	play(s)

main()
