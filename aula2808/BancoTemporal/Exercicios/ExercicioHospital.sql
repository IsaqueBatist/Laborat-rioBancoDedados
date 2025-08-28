/*
1.	Um hospital deseja ter um controle amplo sobre seus pacientes e profissionais e exames. 
Para isso, cada paciente possui uma ficha cadastral onde armazena-se os dados cadastrais como CPF, nome, endereço, data de nascimento. 
Os médicos por sua vez também possuem as mesmas informações do paciente 
mas também tem um  CRM (número de cadastro no conselho regional de medicina), uma especialidade (ex: pediatra, traumatologista, etc), 
um cargo e seu respectivo salário.

Toda consulta neste complexo médico envolve um paciente um médico e seus respectivos exames solicitados, 
data  e horário de atendimento, 
os exames por sua vez contém informações sobre tipo de exame (exemplo: exame laboratorial: hemograma, exame de imagens: raio-x, exame, Monitorização Ambulatorial da Pressão Arterial, etc).

Este centro clínico deseja manter o registro de todas as consultas realizadas assim como de seus pacientes e um registro dos seus funcionários e a suas respectivas evoluções de cargos e salários com o passar do tempo.
*/

create database ExercicoiHospital

use ExercicoiHospital

create table Medicos (
	cpf_medico varchar(11) primary key not null,
	CRM varchar(13) not null,
	especialidade varchar(100) not null,
	cargo varchar(100) not null,
	salario money not null,
	nome varchar(255) not null,
	endereco varchar(255) not null,
	data_nascimento date not null,
	SysStartTime datetime2 generated always as row start not null,
	SysEndTime datetime2 generated always as row end not null,
	period for system_time (SysStartTime, SysEndTime),
)with(
	SYSTEM_VERSIONING = ON (history_table = dbo.EvolucaoMedicos)
)

create table Pacientes(
	cpf_paciente varchar(11) primary key not null,
	nome varchar(255) not null,
	endereco varchar(255) not null,
	data_nascimento date not null,
	SysStartTime datetime2 generated always as row start not null,
	SysEndTime datetime2 generated always as row end not null,
	period for system_time (SysStartTime, SysEndTime),
)with(
	SYSTEM_VERSIONING = ON (history_table = dbo.HistoricoPacientes)
)

create table Consultas(
	id_consulta int primary key identity,
	medico_cpf varchar(11) references Medicos(cpf_medico),
	paciente_cpf varchar(11) references Pacientes(cpf_paciente),
	data_hora_atendimento datetime default GETDATE(),
	SysStartTime datetime2 generated always as row start not null,
	SysEndTime datetime2 generated always as row end not null,
	period for system_time (SysStartTime, SysEndTime),
)with(
	SYSTEM_VERSIONING = ON (history_table = dbo.HistoricoConsultas)
)

create table Exames(
	id_exame int primary key identity,
	tipo varchar(255),
)

create table Exames_consultas(
	id_exame_consula int primary key identity,
	exame_id int references Exames(id_exame),
	consulta_id int references Consultas(id_consulta),
)

--Inserção de dados

INSERT INTO Medicos (cpf_medico, CRM, especialidade, cargo, salario, nome, endereco, data_nascimento) VALUES
('11122233344', 'SP123456', 'Cardiologia', 'Cardiologista Chefe', 18500.00, 'Dr. Carlos Andrade', 'Rua Augusta, 100, São Paulo, SP', '1975-04-12'),
('55566677788', 'RJ789012', 'Pediatria', 'Pediatra Plantonista', 12300.50, 'Dra. Ana Beatriz Costa', 'Avenida Copacabana, 250, Rio de Janeiro, RJ', '1982-11-20'),
('99988877766', 'MG456789', 'Ortopedia e Traumatologia', 'Ortopedista Cirurgião', 16750.75, 'Dr. Roberto Martins', 'Rua da Bahia, 500, Belo Horizonte, MG', '1980-07-30'),
('12345678900', 'RS987654', 'Dermatologia', 'Dermatologista Ambulatorial', 14000.00, 'Dra. Fernanda Lima', 'Avenida Ipiranga, 1200, Porto Alegre, RS', '1988-01-15');

INSERT INTO Pacientes (cpf_paciente, nome, endereco, data_nascimento) VALUES
('01020304050', 'João da Silva', 'Rua das Flores, 10, São Paulo, SP', '1990-05-21'),
('10203040506', 'Maria Oliveira', 'Avenida Brasil, 2010, Rio de Janeiro, RJ', '1965-09-03'),
('20304050607', 'Pedro Souza', 'Praça Sete, 35, Belo Horizonte, MG', '2015-02-11'),
('30405060708', 'Luiza Pereira', 'Rua dos Andradas, 800, Porto Alegre, RS', '1985-12-08');

INSERT INTO Exames (tipo) VALUES
('Exame Laboratorial: Hemograma Completo'),
('Exame Laboratorial: Colesterol Total e Frações'),
('Exame de Imagem: Raio-X do Tórax'),
('Exame de Imagem: Ultrassonografia Abdominal'),
('Monitorização Ambulatorial da Pressão Arterial (M.A.P.A.)'),
('Eletrocardiograma (ECG)');

INSERT INTO Consultas (medico_cpf, paciente_cpf, data_hora_atendimento) VALUES
('11122233344', '10203040506', '2025-08-27T10:00:00'), 
('55566677788', '20304050607', '2025-08-27T11:30:00'), 
('99988877766', '01020304050', '2025-08-28T09:15:00'), 
('11122233344', '10203040506', '2025-09-10T14:00:00'); 

INSERT INTO Exames_consultas (consulta_id, exame_id) VALUES
(2, 2), 
(2, 5), 
(2, 6); 

INSERT INTO Exames_consultas (consulta_id, exame_id) VALUES
(3, 1); 

INSERT INTO Exames_consultas (consulta_id, exame_id) VALUES
(4, 3);

--Testando
select * from dbo.EvolucaoMedicos;
select * from dbo.HistoricoPacientes;
select * from dbo.HistoricoConsultas

--Medicos
UPDATE Medicos
SET 
    cargo = 'Diretor Clínico de Cardiologia',
    salario = 22500.00
WHERE 
    cpf_medico = '11122233344';

select * from Medicos

--Pacientes
select * from Pacientes

update Pacientes set nome = 'Beatriz' where cpf_paciente = '01020304050'

--Consultas
select * from Consultas

delete from Consultas where id_consulta = 5