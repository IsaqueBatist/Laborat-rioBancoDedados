
/*
-Trigger Dinossauros
Faça uma trigger para garantir que o cadastro de um novo dinossauro esteja correto.
Cada dinossauro possui um ano de inicio e de fim (existencia), e esta vincilado a uma era.
Verifique se o tempo de existencia do dinossauro é coerente com a era informada.
*/

create table Grupos (
	id_grupo int identity primary key,
	nome_grupo varchar(100),
)
create table Paises (
	id_pais int identity primary key,
	nome_pais varchar(100),
)
create table Descobridores (
	id_descobridor int identity primary key,
	nome_descobridor varchar(100),
)

create table Eras (
	id_era int identity primary key,
	nome_era varchar(100),
	inicio_era int,
	fim_era int
)


create table Dinossauros (
	id_dinossauro int identity primary key,
	nome_dinossauro varchar(255),
	grupo_id int references Grupos(id_grupo),
	toneladas int,
	ano_descoberta int,
	descobridor_id int references Descobridores(id_descobridor),
	era int references Eras(id_era),
	inicio int,
	fim int,
	pais_id int references Paises(id_pais)
)

create trigger eraDinossauro
on Dinossauros
after insert
as begin
	declare @inicioEraDinossauro int;
	select @inicioEraDinossauro = (
		select Eras.inicio_era from Eras
		join inserted on inserted.era = Eras.id_era
	)

	declare @fimEraDinossauro int;
	select @fimEraDinossauro = (
		select Eras.fim_era from Eras
		join inserted on inserted.era = Eras.id_era
	)

	declare @inicioDinossauro int;
	select @inicioDinossauro = (
		select inserted.inicio from inserted
	)

	declare @fimDinossauro int;
	select @fimDinossauro = (
		select inserted.fim from inserted
	)


	if @fimDinossauro > @fimEraDinossauro or @inicioDinossauro < @inicioEraDinossauro
		begin
			RAISERROR('Ano de inicio e fim do dinossauro não coreespondem a sua era', 14, 1);
			ROLLBACK;
		end
end