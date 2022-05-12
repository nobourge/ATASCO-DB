-- requete 1

-- nombre de vol avec un avion de fret
select count(vol.id)
from vol,
     aviondefret
where vol.avionid = aviondefret.id;


select count(voL.id)
from vol
where vol.avionid in (select aviondefret.id
                      from aviondefret);


-- requete 2

-- nombre de vol avec un pilote en passager
select pilote.id
from pilote,
     réservation
where réservation.voyageurid = pilote.id;


-- requete 3

-- vol le plus fréquenté
select count(voyageurid) as nombredepassager, réservation.volid
from réservation
group by réservation.volid
order by nombredepassager desc
limit 1;

-- nombre de passager par vol décroissant
select count(voyageurid) as nombredepassager, réservation.volid
from réservation
group by réservation.volid
order by nombredepassager desc;


-- nombre de passagers par vol
select count(voyageurid) as nombredepassager, réservation.volid
from réservation
group by réservation.volid;

-- liste des vols
select distinct réservation.volid
from réservation;

-- information sur le vol le plus peuplé v.1
select vol.id, volleplusfrequenté.nombredepassager
from vol
         join (
    select count(voyageurid) as nombredepassager, réservation.volid
    from réservation
    group by réservation.volid
    order by nombredepassager desc
    --limit 1
) as volleplusfrequenté
              on vol.id = volleplusfrequenté.volid and volleplusfrequenté.nombredepassager = max(volleplusfrequenté.nombredepassager)


select vol.id, vollesplusfrequenté.nombredepassager
from vol
         join (
    select volid, nombredepassager
    from (
             select count(voyageurid) as nombredepassager, réservation.volid
             from réservation
             group by réservation.volid
             order by nombredepassager desc
         ) as volPassager
    where volPassager.nombredepassager = (select count(voyageurid) as nombredepassager
                                          from réservation
                                          group by réservation.volid
                                          order by nombredepassager desc
                                          limit 1)
) as vollesplusfrequenté
              on vol.id = vollesplusfrequenté.volid;


-- information sur le vol le plus peuplé v.2
select *
from vol
where id = (
    select volleplusfrequenté.volid
    from (
             select count(voyageurid) as nombredepassager, réservation.volid
             from réservation
             group by réservation.volid
             order by nombredepassager desc
             limit 1
         ) as volleplusfrequenté
);

-- requete 4

-- vols avec avion de ligne
select *
from vol,
     aviondeligne
where vol.avionid = aviondeligne.id;


-- liste des pilotes ayant conduits des avions de ligne
select distinct vol.piloteid
from vol,
     aviondeligne
where vol.avionid = aviondeligne.id;


-- vols avec avion de fret
select *
from vol,
     aviondefret
where vol.avionid = aviondefret.id;


-- listes des pilotes ayant conduits des avions de fret
select distinct vol.piloteid
from vol,
     aviondefret
where vol.avionid = aviondefret.id;


-- listes des pilotes n'ayant conduit que des avions de ligne
select vol.piloteid
from vol,
     aviondeligne
where vol.avionid = aviondeligne.id
except
select vol.piloteid
from vol,
     aviondefret
where vol.avionid = aviondefret.id;


select distinct vol.piloteid
from vol
where vol.avionid in (select aviondeligne.id
                      from aviondeligne)
except
select vol.piloteid
from vol
where vol.avionid in (select aviondefret.id
                      from aviondefret);

select count(distinct vol.piloteid)
from vol
where vol.avionid in (select aviondefret.id
                      from aviondefret);

select count(distinct vol.piloteid)
from vol
where vol.avionid in (select aviondeligne.id
                      from aviondeligne);



-- requete 5

-- liste des avions de ADVANCED AIR, LLC
select avion.id
from avion
where avion.compagnieid in (
    select company.id
    from company
    where nom = 'ADVANCED AIR, LLC'
);


-- liste des distance moyenne effectuées par jour par avion de AAL
select avg(distance), vol.heuredépart::date
from vol
where vol.avionid in (
    select avion.id
    from avion
    where avion.compagnieid in (
        select company.id
        from company
        where nom = 'ADVANCED AIR, LLC'
    )
)
group by vol.heuredépart::date;



-- liste des distance moyenne effectuées par jour par avion de AAI
select avg(distance), vol.heuredépart::date
from vol
where vol.avionid in (
    select avion.id
    from avion
    where avion.compagnieid in (
        select company.id
        from company
        where nom = 'ABX Air Inc'
    )
)
group by vol.heuredépart::date;


-- requete 6

-- listes des vols décollant après 7h
select vol.id
from vol
where vol.heuredépart::time >= '07:00:00';

-- liste des paires de vols décollant le même jour pas opti runtime: 8s446ms
select distinct aller.id, retour.id
from vol as aller,
     vol as retour
where aller.heuredépart::date = retour.heuredépart::date
  and aller.id <> retour.id;


-- listes des paires de vols de ligne décollant le même jour
select distinct aller.id, aller.avionid, retour.id, retour.avionid
from vol as aller,
     vol as retour,
     aviondeligne
where aller.heuredépart::date = retour.heuredépart::date
  and aller.id <> retour.id
  and aller.avionid = aviondeligne.id
  and retour.avionid = aviondeligne.id;


-- paires de vols décollant après 7am, le même jour et ayant un interval de 7h entre chaque vol

select aller.id, retour.id -- TODO truc bizarre pas de résultat ?
from vol as aller,
     vol as retour,
     aviondeligne
where aller.heuredépart::date = retour.heuredépart::date
  and aller.heuredépart::time >= '07:00:00'

  and aller.aéroportarrivéecode = retour.aéroportdépartcode
  and aller.aéroportdépartcode = retour.aéroportarrivéecode

  and aller.avionid = aviondeligne.id
  and retour.avionid = aviondeligne.id

  and retour.heuredépart >= aller.heurearrivée + interval '7 hours';

select distinct aller.id as volAller, aller.heuredépart::time, retour.id as volRetour, retour.heuredépart::time
from vol as aller,
     vol as retour
where aller.heuredépart::time > '07:00:00'
  and aller.heuredépart::date = retour.heuredépart::date
  and retour.heuredépart >= aller.heurearrivée + '07:00:00'
  and aller.aéroportarrivéecode = retour.aéroportdépartcode
  and aller.aéroportdépartcode = retour.aéroportarrivéecode
  and aller.avionid in (select aviondeligne.id from aviondeligne)
  and retour.avionid in (select aviondeligne.id from aviondeligne);

-- requete 7

select avg(companyidpassager.nombredepassager), company.nom
from company
         join(
    select avion.compagnieid, avionpassager.nombredepassager
    from avion
             join (
        select vol.avionid, passagervol.nombredepassager
        from vol
                 join (
            select count(réservation.voyageurid) as nombredepassager, réservation.volid
            from réservation
            group by réservation.volid
            having count(réservation.voyageurid) < 20
        ) as passagervol
                      on passagervol.volid = vol.id
    ) as avionpassager
                  on avion.id = avionpassager.avionid
) as companyidpassager
             on company.id = companyidpassager.compagnieid
group by company.nom;


-- requete 8
select count(vol.id) as nombredevol, vol.piloteid
from vol
group by vol.piloteid
order by nombredevol desc;

select vol.id,
       vol.piloteid,
       vol.heurearrivée,
       vol.heuredépart,
       row_number()
       over (partition by vol.piloteid order by vol.heurearrivée)
from vol;


select volspilotes.*
from (
         select vol.id,
                vol.piloteid,
                vol.heurearrivée,
                row_number()
                over (partition by vol.piloteid order by vol.heurearrivée)
         from vol) as volspilotes;


-- liste des pilotes et de leurs vols actuels + leur prochain
select vol.piloteid,
       vol.heuredépart::date,
       lead(vol.heuredépart::date)
       over (partition by vol.piloteid order by vol.heuredépart) as prochainvol
from vol;


select vol.piloteid,
       vol.heuredépart::date,
       vol.heurearrivée::date,
       lag(vol.heuredépart::date)
       over (partition by vol.piloteid order by vol.heuredépart)
from vol
where vol.piloteid = 'be7ff385-25fa-4ee1-b467-8ea77995d2b3';

-- lag -> précédant
-- lead -> suivant

-- comptage du nombre de vols consécutif par pilote
select volspilotes.piloteid, count(piloteid) + 1 as jourssconsecutifs   -- +1 pour rajouter le dernier vol
from (
         select vol.piloteid, -- listes des vols groupé par pilotes et leur dernier vol
                vol.heuredépart::date,
                vol.heurearrivée::date,
                lag(vol.heuredépart::date) -- départ du dernier vol
                over (partition by vol.piloteid order by vol.heuredépart)  as départderniervol,
                lag(vol.heurearrivée::date)
                over (partition by vol.piloteid order by vol.heurearrivée) as arrivéederniervol
         from vol) volspilotes
where volspilotes.heuredépart = volspilotes.départderniervol + interval '1 day'     -- vols consécutifs
   or volspilotes.heuredépart = volspilotes.arrivéederniervol + interval '1 day'    -- condition si le dernier vol s'étale sur deux jours
group by volspilotes.piloteid
order by jourssconsecutifs desc;


with volSuivant as (select distinct vol.piloteid,
                                    vol.heuredépart::date,
                                    row_number()
                                    over (partition by vol.piloteid order by vol.heuredépart)                as joursConsecutifNum,
                                    row_number() over (order by vol.piloteid)                                as num,
                                    (row_number() over (order by vol.piloteid) -
                                     row_number() over (partition by vol.piloteid order by vol.heuredépart)) as numDiff
                    from vol
)
select row_number() over (partition by volSuivant.piloteid order by volSuivant.heuredépart) as joursConsécutif,
       volSuivant.piloteid
from volSuivant
order by joursConsécutif desc;

select distinct vol.heuredépart::date
from vol
where vol.piloteid = 'ce5834ca-a874-4d94-a59a-97389b6eb111'
order by vol.heuredépart::date;


with vols as (select vol.piloteid,
                     row_number()
                     over (partition by vol.piloteid order by vol.heuredépart) as volsConsécutifs,
                     row_number() over (order by vol.piloteid)              as index,
                     (row_number() over (order by vol.heuredépart) - row_number() over (partition by vol.piloteid order by vol.heuredépart)) as suite
              from vol
)
select row_number() over (partition by vols.suite order by vols.piloteid) joursConsecutif, vols.piloteid
from vols
order by joursConsecutif desc;


with volsEnchainés as (
    select v.piloteid,
           v.heuredépart::date,
           dense_rank() over (order by v.heuredépart::date)                           as id,    -- utilisation de dense_rank pour éviter les gap
           row_number() over (partition by v.piloteid order by v.heuredépart)         as Idinterne,
           (dense_rank() over (order by v.heuredépart::date) -
            row_number() over (partition by v.piloteid order by v.heuredépart::date)) as diffId
    from (
             select vol.piloteid,

                    vol.heuredépart::date,
                    lag(vol.heuredépart::date)
                    over (partition by vol.piloteid order by vol.heuredépart::date) as départPrécédent
             from vol) v
    where v.départPrécédent is NULL or v.heuredépart > v.départPrécédent
    order by v.piloteid, v.heuredépart::date
)
select max(vE.jours) as joursConsécutif, vE.piloteid
from (
         select count(volsEnchainés.diffId) as jours, volsEnchainés.piloteid
         from volsEnchainés
         group by volsEnchainés.piloteid, volsEnchainés.diffId
     ) vE
group by vE.piloteid
order by joursConsécutif desc;



-- requete 9

drop table pilote_expert;

create table if not exists pilote_expert
(
    id        uuid primary key
        references pilote,
    date      date,
    estExpert boolean
);

-- drop table temp_pilote_expert;

create temp table temp_pilote_expert
(
    id_expert   varchar(128),
    date        varchar(128)
);

copy temp_pilote_expert (id_expert, date)
    from 'C:\Users\Public\csv_file.csv' -- changer plus tard pour le fichier en question
    delimiter ','
    header csv;


insert into pilote_expert(id, date, estExpert)
select split_part(temp_pilote_expert.id_expert, '--', 2)::uuid,
       temp_pilote_expert.date::timestamp,
       case -- switch comme en C++
           when split_part(temp_pilote_expert.id_expert, '--', 1) = 'existing-expert' then true
           when split_part(temp_pilote_expert.id_expert, '--', 1) = 'new-expert' then false
           else false
           end
from temp_pilote_expert
where not exists( -- vérification que l'on n'insére pas une ligne déjà présenten
        select pilote_expert.id
        from pilote_expert
        where id = split_part(temp_pilote_expert.id_expert, '--', 2)::uuid
    );





-- requete 10
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

drop table aéroportsujets;

create table if not exists aéroportsujets
(
    id           uuid default uuid_generate_v4() primary key not null,
    aéroportCode varchar(8)                                  not null
        constraint fk_aéroportCode
            references aéroport,
    sujetAbonné  text                                        not null
);

insert into aéroportsujets(id, aéroportCode, sujetAbonné)
values (default, 'AKN', 'mobilité');
insert into aéroportsujets(id, aéroportCode, sujetAbonné)
values (default, 'AKN', 'économie');
insert into aéroportsujets(id, aéroportCode, sujetAbonné)
values (default, 'AKN', 'écologie');


drop table discussion;

create table if not exists discussion
(
    id             uuid default uuid_generate_v4() primary key not null,
    message        text                                        not null,
    expéditeurCode varchar(8)                                  not null
        constraint fk_expéditeurCode
            references aéroport,
    sujet          text                                        not null
);

insert into discussion(id, message, expéditeurCode, sujet)
values (default, 'il faut aller plus vite', 'AKN', 'mobilité');





