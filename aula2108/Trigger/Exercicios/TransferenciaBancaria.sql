/*
-Transferência bancária
Crie um trigger em TransferenciasBancarias que verifique se a conta de origem tem saldo suficiente 
antes de permitir a transferência.
*/

create table ContasBancarias (
	id_contaBancaria int primary key identity,
	saldo money not null,
	criada_em datetime default GETDATE(),
)

create table TransferenciasBancarias (
	id_transferencia int primary key identity,
	conta_origem int references ContasBancarias(id_contaBancaria),
	conta_destino int references ContasBancarias(id_contaBancaria),
	valor money,
	data_transferecia date default GETDATE(),
)


create trigger verificarSaldoOrigem
on TransferenciasBancarias
after insert
as begin
	
	declare @saldoConta money;
	select @saldoConta = (
		select saldo from ContasBancarias
		join inserted on inserted.conta_origem = ContasBancarias.id_contaBancaria
	);

	declare @valorTransferido money
	select @valorTransferido = (
		select inserted.valor from inserted
	)
	
	If (@saldoConta < @valorTransferido)
		begin
			RAISERROR('Saldo da conta insuficnete, transição cancelada', 14, 1);
			ROLLBACK;
		end
end