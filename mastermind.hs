-- Projeto Haskell - Mastermind
-- Vinícius Balbino de Souza
-- RA 178183
import System.IO
import Data.Char

-- Suas funções aqui, com comentários

-- Gera uma lista S com todas as possiveis solucoes para o jogo recursivamente.
createAllCodes :: Int -> [[Int]]
createAllCodes 0 = [[]]
createAllCodes length = [ c:r | c <- [1,2,3,4,5,6],  r <- createAllCodes (length-1), notElem c r ]

-- Verifica se um chute existe, utilizando as regras aprendidas no trabalho passado
verificaValidade :: [Int] -> Bool
verificaValidade [a,b] = ((a + b) < 2 || (a + b) > 4)

-- Calcula a tupla (Bons, Regulares) para um chute.
verificaChute :: [Int] -> [Int] -> [Int]
verificaChute xs ys = [length (acertos xs ys),length (coincidencias xs ys)]

-- Calcula a quantidade de Bons no meu chute comparado ao elemento analisado da lista de possiveis solucoes
acertos :: Eq a => [a] -> [a] -> [a]
acertos xs ys = [x | (x,y) <- zip xs ys, x == y]

-- Calcula a quantidade de Regulares no meu chute comparado ao elemento analisado da lista de possiveis solucoes
coincidencias :: Eq a => [a] -> [a] -> [a]
coincidencias xs ys = [x | x <- xs, x `elem` ys, x `notElem` zs] where zs = acertos xs ys

-- Gerador da nova lista de possibilidades levando em consideracao o chute e o score passados
verificaExistencia :: [[Int]] -> [Int] -> [Int] -> [[Int]]
verificaExistencia listadechutes chute score = filter (valido) listadechutes
  where valido x = (verificaChute chute x) == score

-- Argumentos de play: vetor de soluções.
-- Ele sempre chutara o primeiro elemento do vetor de solucoes, e realizara a verificacao para eliminar possiveis proximos chutes incoerentes
play :: [[Int]] -> IO(String)
play listadechutes = do
  putStrLn (map (intToDigit) (head listadechutes))  -- imprime o primeiro chute transformado em uma string
  answer <- getLine -- recebe valor
  if answer == "40" then return "ganhei" -- caso de vitoria
    else do
      let ansmodif = map (digitToInt) answer -- como vamos utilizar a resposta mapeada para um vetor de inteiros varias vezes, salvamos em ansmodif
      if not (verificaValidade ansmodif) then do
        let newlistadechutes = (verificaExistencia listadechutes (head listadechutes) ansmodif) -- gera nova lista de chutes
        if length newlistadechutes == 0 -- compara com 0 pois pode ser que o usuario tenha mentido
          then return "erro" -- caso tenha mentido
          else play newlistadechutes -- caso contrario, continua o jogo
      else return "erro" -- caso o jogador tenha colocado uma resposta do tipo 01 ou 50, ele dara erro nessa linha

-- Programa principal
main = do
    hSetBuffering stdout LineBuffering
    -- Comeca o jogo com a lista de solucoes para o jogo com 4 posicoes
    answer <- (play (createAllCodes 4))
    putStrLn answer
