/* Controle de Estoque
Crie tabelas Produtos (com Estoque) e Vendas.
Faça um trigger em Vendas que diminua a quantidade em Produtos.
*/

create table Produtos (
	id_produto int primary key identity,
	nome_produto varchar(150) not null,
	valor_unt money not null,
	estoque int not null check (estoque > 0),
)

create table Vendas (
	id_venda int primary key identity,
	produto_id int references Produtos(id_produto) not null,
	quantidade int not null,
	subtotal money,
	data_venda datetime default GETDATE()
)

create trigger adicionarVendas
on Vendas
after insert
as begin
	declare @VendaIdInserido int;
	select @VendaIdInserido = ( select inserted.id_venda from inserted )

	declare @quantidadeVendida int;
	select @quantidadeVendida = (select inserted.quantidade from inserted)

	declare @quantidadeAtual int;
	select @quantidadeAtual = (
			select estoque from Produtos
			join inserted on Produtos.id_produto = inserted.produto_id
	)

	IF(@quantidadeAtual < @quantidadeVendida)
		begin
			RAISERROR('Quantidade insuficiente para venda', 14, 1);
			Rollback transaction;
		end
	ELSE
		begin
			update Vendas set subtotal = @quantidadeVendida * ( 
				select valor_unt from Produtos 
				join inserted on inserted.produto_id = Produtos.id_produto
			) where Vendas.id_venda = @VendaIdInserido

			update Produtos set estoque = @quantidadeAtual - @quantidadeVendida 
			where id_produto = @VendaIdInserido
		end
end