/*
-Estoque mínimo
Um sistema possui uma tabela para armazenar os registros dos PRODUTOS que comercializa, 
e tambem uma tabela de REQUISICOES que pode ser de entrada ou de saída, além da MOVIMENTACAO, 
que pode ser de entrada ou de saida - uma requisição que foi confirmada.
Faça uma trigger que gere uma nova REQUISICAO de entrada caso as requisições de saída atinjam 
mais de 70% da quantidade do item em questão em estoque.
*/


create table ProdutosComercializados (
	id_produto_comercializado int primary key identity,
	nome_produto varchar(100) not null,
	valor_unit money not null,
	quantidade_estoque int not null,
)

create table Requisicoes (
	id_requisicao int primary key identity,
	produto_id int references ProdutosComercializados(id_produto_comercializado),
	status varchar(100) check (status in ('Confirmado', 'Pendente', 'Cancelado')),
	tipo char check (tipo in ('E','S')) not null,
	quantidade int not null,
	subtotal money not null,
)

create table Movimentacao (
	id_requisicao int primary key identity,
	produto_id int references ProdutosComercializados(id_produto_comercializado),
	status varchar(100) check (status = 'Confirmado'),
	tipo char check (tipo in ('E','S')) not null,
	subtotal money not null,
)

-- Inserindo dados na tabela de Produtos
PRINT 'Inserindo produtos...';
INSERT INTO ProdutosComercializados (nome_produto, valor_unit, quantidade_estoque) VALUES
('Caneta Esferográfica Azul', 2.50, 100),
('Caderno Universitário 96fls', 15.00, 50),
('Caixa de Lápis de Cor 12un', 22.75, 30),
('Borracha Branca', 1.20, 200);
GO

-- Inserindo dados na tabela de Requisições
PRINT 'Inserindo requisições com status variados...';
-- Requisição 1: Uma venda confirmada de canetas
INSERT INTO Requisicoes (produto_id, status, tipo, quantidade, subtotal) VALUES
(1, 'Confirmado', 'S', 10, 25.00); -- 10 * 2.50

-- Requisição 2: Uma compra de cadernos que ainda está pendente
INSERT INTO Requisicoes (produto_id, status, tipo, quantidade, subtotal) VALUES
(2, 'Pendente', 'E', 20, 300.00); -- 20 * 15.00

-- Requisição 3: Uma venda de lápis que foi cancelada
INSERT INTO Requisicoes (produto_id, status, tipo, quantidade, subtotal) VALUES
(3, 'Cancelado', 'S', 5, 113.75); -- 5 * 22.75

-- Requisição 4: Uma compra confirmada de borrachas
INSERT INTO Requisicoes (produto_id, status, tipo, quantidade, subtotal) VALUES
(4, 'Confirmado', 'E', 100, 120.00); -- 100 * 1.20
GO

-- Inserindo dados na tabela de Movimentação (apenas requisições confirmadas)
PRINT 'Inserindo movimentações confirmadas...';
-- Movimentação da Requisição 1 (Venda de canetas)
INSERT INTO Movimentacao (produto_id, status, tipo, subtotal) VALUES
(1, 'Confirmado', 'S', 25.00);

-- Movimentação da Requisição 4 (Compra de borrachas)
INSERT INTO Movimentacao (produto_id, status, tipo, subtotal) VALUES
(4, 'Confirmado', 'E', 120.00);
GO

create trigger alerta70Estqoue 
on Requisicoes
after insert
as begin
	declare @produtoID int;
	select @produtoID = (
		select inserted.produto_id from inserted
	)

	declare @totalProdutoRequisicao int;
	select @totalProdutoRequisicao = (
		select SUM(r.quantidade) from Requisicoes r
		where r.tipo = 'S' and r.produto_id = @produtoID
	)

	declare @totalEstoqueProduto int;
	select @totalEstoqueProduto = (
		select pc.quantidade_estoque from ProdutosComercializados pc
		where pc.id_produto_comercializado = @produtoID
	)

	declare @valorUnit money;
	select  @valorUnit = p.valor_unit
        FROM inserted i
        JOIN ProdutosComercializados p ON i.produto_id = p.id_produto_comercializado;

	If @totalProdutoRequisicao > @totalEstoqueProduto*0.7
		begin
		insert into Requisicoes (produto_id, status, tipo, quantidade, subtotal) VALUES
		(@produtoID, 'Confirmado', 'E', 100, 100 * @valorUnit);
		end
end