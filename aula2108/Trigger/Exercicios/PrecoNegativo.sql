/*
- Impedir Atualização de Preço Negativo
Em Produtos, crie um trigger AFTER UPDATE que verifique se o preço atualizado é menor que zero.
Se for, cancele a operação e exiba um erro personalizado.
*/

create trigger precoNegativo
on Produtos
after update
as begin
	declare @novoPreco money;
	select @novoPreco = ( select inserted.valor_unt from inserted );

	if @novoPreco < 0
		begin
			RAISERROR('Novo preço negativo, impossível inserir', 14, 1);
			ROLLBACK transaction;
		end
end