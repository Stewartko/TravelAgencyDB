# TravelAgencyDB – PostgreSQL databáza pre cestovnú kanceláriu

## Popis projektu
Tento projekt predstavuje relačný databázový model pre potreby cestovnej kancelárie. Obsahuje návrh schémy, dátové typy, spúšťacie mechanizmy (triggery), pohľady (views), uložené procedúry a testovacie dáta.

## Použité technológie
- **SRBD:** PostgreSQL
- **Jazyk:** SQL (PL/pgSQL)
- **IDE:** JetBrains DataGrip

## Hlavné entity databázy
- `client` – zákazníci
- `destination` – destinácie
- `trip` – zájazdy
- `reservation` – rezervácie
- `payment` – platby
- `transport` – doprava
- `accommodation` – ubytovanie
- `review` – recenzie

## Enum typy
- `trip_status` – stav zájazdu
- `reservation_status` – stav rezervácie
- `payment_status` – stav platby
- `payment_method` – spôsob platby
- `transport_type` – typ dopravy
- `accommodation_type` – typ ubytovania

## Funkcie a triggery
- Automatické generovanie ID pomocou sekvencií pre každú tabuľku
- Trigger `set_total_price_for_reservation` vypočíta cenu rezervácie
- Trigger `trg_insert_into_client_view` umožňuje insert do pohľadu (INSTEAD OF)
- Uložená procedúra `make_reservation` pre vloženie rezervácie
- Funkcia `get_avg_rating_for_trip(trip_id)` vráti priemerné hodnotenie zájazdu

## Pohľady (views)
- `client_list` – klienti s konkrétnym menom/priezviskom
- `transport_list` – cestujúci vlakom
- `payment_pending` – nevybavené platby
- `happy_customers` – spokojní klienti (hodnotenie 4 a viac)
- `top_spenders` – klienti, ktorí minuli najviac peňazí
- `best_rated_trips` – top 5 najlepšie hodnotených zájazdov
- `revenue_per_destination` – tržby podľa destinácie
- `clients_with_reservation_or_review` – klienti s aktivitou
- `clients_without_reservation` – klienti bez rezervácie
- `most_expensive_trip_per_destination` – najdrahší zájazd pre každú destináciu

## Testovanie
V dolnej časti SQL súboru sú zahrnuté testy:
- Test auto-increment sekvencií
- Test výpočtu `total_price` pomocou triggera
- Test INSTEAD OF triggera cez insert do pohľadu
- Test volania procedúry `make_reservation`
- Test funkcie `get_avg_rating_for_trip`
- 
## Autor
- **Meno:** Adam Timko
- **Rok:** 2025
- **Projekt/Škola:** DBS/TUKE Košice

