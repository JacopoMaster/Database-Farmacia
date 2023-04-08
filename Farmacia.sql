############################################################################
################      Script per progetto BDSI 2019/20     #################
############################################################################    
############################################################################
#
# GRUPPO FORMATO DA:
#
# Matricola:7003888      Cognome: Manetti 	       Nome: Jacopo          
#
############################################################################

drop database if exists farmacia_schema;
create database if not exists farmacia_schema;
use farmacia_schema;


############################################################################
################   Creazione schema e vincoli database     #################
############################################################################

create table if not exists Farmacia (
	FarmaciaID int primary key auto_increment,
    Nome varchar(50) not null,
    Fax varchar(10),
    Indirizzo varchar(50) not null
);

create table if not exists Produttore_farmaci (
	CompagniaID int primary key auto_increment,
    Nome varchar(50) not null,
    Indirizzo varchar(50) not null,
    Consegna int references Farmacia(FarmaciaID),
    Contratto_inizio date,
    Contratto_fine date
);

create table if not exists Dipendente (
    DipendenteID int primary key auto_increment,
    Nome varchar(50) not null,
    FarmaciaID int not null references Farmacia(FarmaciaID),
    Lavoro_inizio date,
    Lavoro_fine date
);

create table if not exists Farmaco (
    NomeCommerciale varchar(50) primary key,
    CompagniaID int references Produttore_farmaci(CompagniaID)
 );
 
 create table if not exists Farmaci_disponibili (
    NomeCommerciale varchar(50),
    FarmaciaID int references Farmacia(FarmaciaID),
    Prezzo int not null,
    primary key(NomeCommerciale, FarmaciaID)
 );
 
 create table if not exists Paziente (
    PazienteID int primary key auto_increment,
    Nome varchar(50) not null,
    Sesso enum('M','F') not null,
    Indirizzo varchar(50),
    Telefono varchar(20) not null
 );
 
 create table if not exists Dottore (
	DottoreID int primary key auto_increment,
    Specializzazione varchar(20),
    Nome varchar(50) not null
 );
 
 create table if not exists Prescrizione (
    PrescrizioneID int primary key auto_increment,
    DottoreID int not null references Dottore(DottoreID),
    PazienteID int not null references Paziente(PazienteID),
    NomeCommerciale varchar(50) not null references Farmaco(NomeCommerciale),
    Data date not null,
    Quantità int not null
 );




############################################################################
################  Creazione istanza: popolamento database  #################
############################################################################

insert into Farmacia values
(null, 'farmacia antica guasti', '123-4567-8', 'via giuseppe mazzoni 7, prato (PO)'),
(null, 'farmacia moderna', '234-5678-9', 'via settesoldi 44, modena (MO)'),
(null, 'farmacia nera', '345-6789-1', 'via cavour 35, livorno (LI)'),
(null, 'farmacia puggelli', '456-7891-2', 'via del castagno 11, Milano (MI)'),
(null, 'farmacia Carbone', '567-8912-3', 'Via roma 39, verona (VE)');


insert into produttore_farmaci values
(null, 'cresco farma', 'livorno (LI)', 3, '2010/01/02', null),
(null, 'medibase Srl', 'milano (MI)', 4, '2011/02/03', null),
(null, 'Krufarma', 'verona (VE)', 5, '2012/03/04', null),
(null, 'Vanni farmaceutica', 'prato (PO)', 1, '2013/04/05', null),
(null, 'Vetofarma', 'Modena (MO)', 2, '2014/05/06', null);


insert into Dipendente values
(null, 'Maurizio Mannelli', 1, '2015/06/10', null),
(null, 'Arianna Sgheri', 5, '2016/07/12', null),
(null, 'Giorgio Bardazzi', 2, '2017/08/14', null),
(null, 'Sara Esposito', 4, '2018/09/16', null),
(null, 'Carolina Santi', 3, '2019/10/18', null);


insert into Farmaco values
('Xanax', 1),
('Amoxil', 2),
('Augmentin', 3),
('Eraxis', 4),
('Colazal', 5);

insert into Farmaci_disponibili values
('Xanax', 1, 45),
('Amoxil', 2, 50),
('Augmentin', 3, 100),
('Eraxis', 4, 123),
('Colazal', 5, 74);

insert into Paziente values
(null, 'Umberto Bettazzi', 'M', 'Via giacchetti 33, prato (PO)', '11223344'),
(null, 'Marta Losito', 'F', 'via resga 8, modena (MO)', '22334455'),
(null, 'Francesco Mattei', 'M', 'via cadorna 97, milano (MI)', '33445566'),
(null, 'Sara Silli', 'F', 'via pomeria 39, verona (VE)', '44556677'),
(null, 'Matteo Masone', 'M', 'via del romito 1, livorno (LI)', '55667788');


insert into Dottore values
(null, 'Psichiatra', 'Cosimo Puggelli'),
(null, 'Chirurgo', 'Alessandro Bartolini'),
(null, 'Ortopedico', 'Alex Campagna'),
(null, 'Radiologo', 'Cosimo Lunetti'),
(null, 'Oncologo', 'Gabriele Talini');

insert into Prescrizione values
(null, 5, 4, 'Xanax', '2018/02/11', 10),
(null, 4, 3, 'Amoxil', '2019/03/15', 10),
(null, 3, 2, 'Augmentin', '2018/06/18', 10),
(null, 2, 1, 'Eraxis', '2019/09/11', 10),
(null, 1, 5, 'Colazal', '2019/10/30', 10);


-- dati da file
load data local infile 'Farmaci_disponibili.csv'
into table Farmaci_disponibili
fields terminated by ','
optionally enclosed by'"'
lines terminated by '\n'
ignore 1 lines;

#importa i dati da un file .csv, perchè funzioni bisogna specificare
#il percorso in cui il file si trova


#############################################################################
################  Ulteriori vincoli tramite viste e/o trigger ###############
#############################################################################

-- View #1
create view Vista_dipendenti
as
select FarmaciaID, Farmacia.Nome as NomeFarmacia, DipendenteID, Dipendente.Nome as NomeDipendente
from Farmacia
join Dipendente using (FarmaciaID);

#Questa query crea una vista, in questa query viene utilizzato un join per evitare 
#la duplicità delle colonne.

-- View #2
create view Vista_farmaci_costosi
as
select *
from Farmaci_disponibili
where Prezzo >= 100;

#Questa query crea una vista che viene utilizzata per ottenere i farmaci che 
#hanno un prezzo maggiore o uguale a 100 euro.

-- Trigger #1
DELIMITER $$

create trigger Date_Prescrizioni
before insert
on Prescrizione
for each row
if isnull(new.Data)
then set new.Data = curdate();
end if; $$

DELIMITER ;

#Questa query crea un trigger utilizzato per generare la colonna della data 
#automaticamente nella tabella prescrizione. Prima controlla se la data inserita è nulla. 
#Dopodiché se la data è davvero null inserisce automaticamente la data corrente.

-- Trigger #2
DELIMITER $$

create trigger Prezzo_Farmaci_Negativo
before insert
on Farmaci_disponibili
for each row
if new.Prezzo < 0
then set new.Prezzo = abs(new.Prezzo);
end if; $$

DELIMITER ;

#Questa query crea un trigger sulla tabella Farmaci_disponibili. 
#Serve a validare la colonna Prezzo di questa tabella. 
#Se per caso il prezzo inserito è negativo, lo converte in valore assoluto e lo memorizza.




############################################################################
################ 				 Interrogazioni   		   #################
############################################################################

# Possibilmente di vario tipo:  selezioni, proiezioni, join, con raggruppamento, 
# annidate, con funzioni per il controllo del flusso.



-- Procedure #1 con selection
DELIMITER $$

create procedure Farmacia_con_id_o_nome(in fid int, in fnome varchar(50))
begin 
    select * from Farmacia where FarmaciaID = fid or Nome = fnome;
end; $$

DELIMITER ; 

#Questa procedura utilizza l'istruzione select per ottenrere i dati di una farmacia, 
#per selezionarla accetta due parametri, uno è il FarmaciaID e altro è 
#il nome della farmacia.   

-- Procedure #2 con proiezione, join and grouping
DELIMITER $$

create procedure Farmaci_totali_per_produttore()
begin
    select CompagniaID, Nome, count(NomeCommerciale) as FarmaciTotali
    from Produttore_farmaci
    join Farmaco using (CompagniaID)
    group by CompagniaID;
end; $$


DELIMITER ;  

#Qui la query crea una procedura che utilizza la proiezione per selezionare 
#le colonne richieste. Oltre a ciò raggruppa anche i dati per eseguire l'aggregazione.  


-- Procedure #3 con query annidate e controllo di flusso
DELIMITER $$

create procedure info_Dipendente(in nomeD varchar(25), in cognomeD varchar(25))
begin 
    declare exit handler for sqlexception select 'SQLExeption: dipendente non trovato' as NoSuchCustomer;
    
    if not exists (select DipendenteID from Dipendente where Nome = (select concat(nomeD, ' ', cognomeD)))
    then signal sqlstate '45000';
    end if; 
    
    select DipendenteID,
    (case when isnull(Lavoro_fine) then 'operativo' else 'non operativo' end) as status
    from Dipendente where Nome = (select concat(nomeD, ' ', cognomeD));
 end; $$
 
 DELIMITER ;
 
 #Questa query crea una procedura piuttosto lunga e complessa. 
 #Viene utilizzata una query nidificata e il controllo del flusso per eseguire l'esecuzione.
 #Questa procedura si occupa di fornire lo status del dipendente, quindi se quest’ultimo 
 #è ancora operativo o se ha già terminato il rapporto di lavoro, 
 #viene anche gestito il caso in cui il dipendente non esista.


############################################################################
################          Procedure e funzioni             #################
############################################################################

# sono richiesti anche handler e cursori.

-- Handler #1
DELIMITER $$

create procedure inserimento_Farmaci_disponibili(in NomeC varchar(50), in Fid int, in Prezzo int)
begin
	declare continue handler for 1062 select 'chiave duplicata inserita' as ErrorOcurred;
    
    insert into Farmaci_disponibili values (NomeC, Fid, Prezzo);
end; $$
    
 DELIMITER ;   
 


-- Handler #2
DELIMITER $$

create procedure Controllo_farmaco(in nc varchar(50))
begin
  declare exit handler for sqlexception select 'SQLException: dati non validi' as Message;
  
  if isnull(nc) or nc = ''
  then signal sqlstate '45000';
  
  select * from Farmaco where NomeCommerciale = nc;
  end if;
end; $$

DELIMITER ;

#Queste procedure utilizzano gli handlers per la gestione di eventi.
#Ad esempio SQLEXCEPTION, ERROR O EXIT.


-- Cursor #1
DELIMITER $$

create procedure crea_lista_dipendenti(inout ListaNomi varchar(4000))
begin
    declare fine integer default 0;
    declare nomeDipendente varchar(100) default "";
    
    -- dichiarazione cursore per il nome
    declare dataCursor
       cursor for
           select nome from Dipendente;
    
    -- dichiarazione NOT FOUND handler
    declare continue handler
		for not found set fine = 1;
        
    open dataCursor;
    
    getName: loop
        fetch dataCursor into nomeDipendente; 
        if fine = 1 then 
            leave getName;
        end if;
        -- costruzione lista nomi  
        set ListaNomi = concat(nomeDipendente,";",ListaNomi);
     end loop getName;
     close dataCursor;
     
end; $$

DELIMITER ;   

  
-- Cursor #2
DELIMITER $$

create procedure ottieni_Prescrizioni(in fid int)
begin 
    declare fine integer default 0;
    declare NomeCommerciale varchar(100) default "";
    
    
    -- dichiarazione cursore 
    declare dataCursor 
        cursor for
            select distinct Nome from Prescrizione;
    
	-- dichiarazione NOT FOUND handler
    declare continue handler  
        for not found set fine = 1;

	OPEN dataCursor;
    
    getNomeCommerciale : loop
		fetch dataCursor into NomeCommerciale;
        if fine = 1 then 
            leave getNomeCommerciale;
        end if;
        -- costruzione lista nomi
        select NomeCommerciale;
    end loop getNomeCommerciale;
    close dataCursor;
    
 end; $$
 
 DELIMITER ;
 
#i cursori vengono utilizzati per eseguire operazioni su diversi set di dati
#ottenuti dalle query SELECT.
  

