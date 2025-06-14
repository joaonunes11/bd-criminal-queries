
-- BD 2019/20 - ETAPA E2 - bd011 - TP01

-- Afonso Ramalho, nº 53344 - TP01 - 25%
-- João Nunes, nº 53745 - TP01 - 25%
-- Gonçalo Figueiredo, nº 53338 - TP01 - 25%
-- Rodrigo Correia, nº 53345 - TP01 - 25%


----- EXERCÍCIO 1 -----
-- Ccid e nome dos arguidos de furto e desacato, o seu género e nível de
-- credibilidade. O resultado deve vir ordenado pela credibilidade de forma
-- descendente, e pelo nome de forma ascendente. Nota: pretende-se uma
-- interrogação com apenas um SELECT, ou seja, sem sub-interrogações.

SELECT p.nome, arg.pessoa, p.genero, p.cred, c.tipo
FROM pessoa p, arguido arg, crime c
WHERE p.ccid = arg.pessoa AND
        arg.crime = c.id AND
        c.tipo = "furto" OR c.tipo = "desacato"
GROUP BY p.nome
ORDER BY p.cred DESC, p.nome ASC;


----- EXERCÍCIO 2 -----
-- Ccid e nome dos arguidos de pelo menos um tipo de crime: difamação e plágio,
-- ou que tenham um nome de 5 letras, terminado pela letra ‘o’ e tenham nascido
-- depois do ano associado à Liberdade (1974). Nota: pode usar construtores de
-- conjuntos.

SELECT p.nome, arg.pessoa
FROM pessoa p, arguido arg
WHERE p.ccid = arg.pessoa AND
        EXISTS (SELECT c.tipo
                FROM crime c
                WHERE c.tipo = "difamação" OR c.tipo = "plágio"
                )
        OR (LENGTH(p.nome) = 5 AND
            p.nome LIKE "%o" AND
            p.ano > 1974)
GROUP BY p.nome;


----- EXERCÍCIO 3 -----
-- Número da cédula profissional e nome dos advogados nascidos antes do início
-- da queda do muro de Berlim (1989) que defenderam em ‘oficioso’, pelo menos,
-- um arguido com credibilidade abaixo de 25% e nome contendo a letra ‘z’.

SELECT adv.cedula, p.nome
FROM advogado adv, pessoa p
WHERE p.ccid = adv.ccid AND
        p.ano < 1989 AND
        adv.ccid IN (SELECT d.advogado
                    FROM defende d
                    WHERE d.tipo = 'O' AND
                          d.arguido IN (SELECT arg.pessoa
                                        FROM arguido arg, pessoa p2
                                        WHERE p2.ccid = arg.pessoa AND
                                                p2.cred < 25 AND
                                                p2.nome LIKE '%z%'
                                        )
                     );


----- EXERCÍCIO 4 -----
-- Número da cédula profissional e ano de actividade dos advogados que iniciaram
-- actividade depois do ano do 25 de abril (1974), e nunca defenderam arguidos de
-- crimes de desacato que tenham dado origem a penas de prisão de mais de 30 dias.

SELECT adv.cedula, adv.ano
FROM advogado adv
WHERE adv.ano > 1974 AND
        adv.ccid NOT IN (SELECT c.tipo
			FROM crime c
			WHERE c.tipo = "desacato" AND
                                c.id IN (SELECT arg.prisao
					FROM arguido arg
					WHERE arg.prisao > 30
                                        )
                        );


----- EXERCÍCIO 5 -----
-- Total das multas e valor acrescido da taxa de tribunal correspondente, a 10%,
-- por cada arguido, indicando ccid, nome e ano do crime, em cada tipo de crime.
-- Nota: o resultado deve vir ordenado pelo ccid e nome do arguido de forma
-- ascendente, e pelo ano de forma descendente.

SELECT SUM(a.multa) + SUM(a.multa) * 0.10, 
        p.ccid, p.nome, c.ano, c.tipo 
FROM arguido a, pessoa p, crime c 
WHERE a.pessoa = p.ccid AND
        a.crime = c.id
GROUP BY a.pessoa 
ORDER BY p.ccid ASC, p.nome ASC, c.ano DESC;


----- EXERCÍCIO 6 -----
-- Cédula e ano de início de actividade dos advogados que tenham defendido todos
-- os arguidos de Leiria acusados de crimes de plágio realizados no ano em que
-- iniciou a sua actividade, com multas superiores a 1000 euros. Nota: o resultado
-- deve vir ordenado pelo ano e pela cédula de forma ascendente.

SELECT adv.cedula, adv.ano
FROM advogado adv, defende d
WHERE adv.ccid = d.advogado AND
        d.arguido IN (SELECT arg.pessoa
                     FROM arguido arg, pessoa p
                     WHERE p.ccid = arg.pessoa AND
                            p.municipio = 'Leiria' AND
                            arg.multa > 1000
                    )
ORDER BY adv.ano ASC, adv.cedula ASC;


----- EXERCÍCIO 7 -----
-- Ccid e nome dos arguidos com mais acusações em cada ano, separados por
-- género (mais acusações no seu género). Notas: em caso de empate, devem ser
-- mostrados todos os arguidos em causa. Os resultados devem vir ordenados por
-- ano de forma descendente, e pelo género, ccid e nome de forma ascendente.

SELECT p.ano, p.ccid, p.nome, p.genero, COUNT(a.pessoa)
FROM arguido a, pessoa p
WHERE a.pessoa = p.ccid
GROUP BY p.genero, a.pessoa
ORDER BY p.ano DESC, p.ccid ASC, p.nome ASC, p.genero ASC;


----- EXERCÍCIO 8 -----
-- Ccid, nome e credibilidade das pessoas nascidas depois do ano 2000 que foram
-- arguidas de menos de dois crimes, mesmo que não tenham sido arguidos de
-- nenhum. Esta interrogação deve usar apenas um SELECT, ou seja sem subinterrogações.

SELECT DISTINCT p.ccid, p.nome, p.cred
FROM arguido a RIGHT OUTER JOIN pessoa p ON (p.ccid = a.pessoa)
WHERE p.ano > 2000
GROUP BY p.ccid
HAVING IFNULL(COUNT(a.pessoa), 0) < 2;


----- EXERCÍCIO 9 -----
-- Para cada município, o ccid e nome do arguido de mais crimes, indicando o número
-- de crimes, e a maior e menor pena de prisão obtida relativamente a esses crimes.
-- Nota: devem ser mostrados todos os arguidos se empatarem no total de crimes.

SELECT p.municipio, p.nome, p.ccid, COUNT(*), MAX(a.prisao), MIN(a.prisao)
FROM arguido a, pessoa p
WHERE a.pessoa = p.ccid
GROUP BY p.ccid;