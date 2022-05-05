-- requete 1

-- nombre de vol avec un avion de fret
select count(vol.id)
from vol,
     aviondefret
where vol.avionid = aviondefret.id;


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
select *
from vol
         join (
    select count(voyageurid) as nombredepassager, réservation.volid
    from réservation
    group by réservation.volid
    order by nombredepassager desc
    limit 1
) as volleplusfrequenté
              on vol.id = volleplusfrequenté.volid;


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
select distinct vol.piloteid
from vol,
     aviondeligne
where vol.avionid = aviondeligne.id
except
select distinct vol.piloteid
from vol,
     aviondefret
where vol.avionid = aviondefret.id;


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


-- requete 7

-- liste des vols
select distinct réservation.volid
from réservation;

-- nombre de passagers par vol
select count(voyageurid) as nombredepassager, réservation.volid
from réservation
group by réservation.volid;

-- liste des vols avec < 20 passagers
select count(réservation.voyageurid) as nombredepassager,  réservation.volid
from réservation
group by réservation.volid
having count(réservation.voyageurid)<20;

-- listes des avions comptant < 20 passagers
select vol.avionid
from vol
join (
    select count(réservation.voyageurid) as nombredepassager,  réservation.volid
    from réservation
    group by réservation.volid
    having count(réservation.voyageurid)<20
    ) as passagersvol
on vol.id = passagersvol.volid;

-- listes des compagnies proposant des vols < 20
select avion.compagnieid
from avion
where avion.id in (
    select vol.avionid
    from vol
    join (
        select count(réservation.voyageurid) as nombredepassager, réservation.volid
        from réservation
        group by réservation.volid
        having count(réservation.voyageurid)<20
        ) as passagervol
    on vol.id = passagervol.volid
    );

-- nombre moyen de sièges libres par vol de < 20 par id de compagnie
select avion.compagnieid, avionpassager.nombredepassager
from avion
join (
    select vol.avionid, passagervol.nombredepassager
    from vol
    join (
        select count(réservation.voyageurid) as nombredepassager, réservation.volid
        from réservation
        group by réservation.volid
        having count(réservation.voyageurid)<20
        ) as passagervol
    on passagervol.volid = vol.id
    ) as avionpassager
on avion.id = avionpassager.avionid;


-- nombre moyen de sièges libres par vol de < 20 par nom de compagnie
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
            having count(réservation.voyageurid)<20
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
       lag(vol.heuredépart::date)
       over (partition by vol.piloteid order by vol.heuredépart)
from vol;

-- lag -> précédant
-- lead -> suivant

-- comptage du nombre de vols consécutif par pilote
select volspilotes.piloteid, count(piloteid) as jourssconsecutifs
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


-- requete 9

drop table pilote_expert;

create table if not exists pilote_expert
(
    id        uuid primary key,
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

create table if not exists aéroportsujets
(
    id    uuid primary key,
    code  varchar(8),
    sujet text
);



insert into aéroportsujets(id, code, sujet)
    (
        select uuid_generate_v1(), 'AKN', 'mobilité'
    );


drop table aéroportsujets;

create table if not exists discussion
(
    id         uuid primary key,
    message    text,
    expéditeur varchar(8)
);
