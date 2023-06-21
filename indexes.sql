/*
 Обратил внимание, что при создании таблиц не задается первичный ключ, поэтому создал уникальные индексы по id для таблиц 
 orders и product, но это никак не повлияло на планировщика. Добавил составной индекс для order_product полей product_id, 
 order_id (для нашего запроса важен порядок), так по этим полям происходит фильтр при JOIN.
 CONCURRENTLY, чтобы создание индекса не блакировало вставку в таблицу.
Это позволила на треть ускорить запрос.


 Finalize Aggregate  (cost=272264.28..272264.29 rows=1 width=8) (actual time=2526.916..2530.165 rows=1 loops=1)
   ->  Gather  (cost=272264.07..272264.28 rows=2 width=8) (actual time=2526.896..2530.149 rows=3 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Partial Aggregate  (cost=271264.07..271264.08 rows=1 width=8) (actual time=2443.767..2443.772 rows=1 loops=3)
               ->  Hash Join  (cost=97526.83..269551.22 rows=685139 width=8) (actual time=626.855..2413.179 rows=555163 loops=3)
                     Hash Cond: (o.id = op.order_id)
                     ->  Parallel Seq Scan on orders o  (cost=0.00..105361.67 rows=4166667 width=8) (actual time=27.293..557.759 rows=3333333 loops=3)
                     ->  Hash  (cost=70548.67..70548.67 rows=1644333 width=8) (actual time=592.204..592.208 rows=1665489 loops=3)
                           Buckets: 262144  Batches: 16  Memory Usage: 6129kB
                           ->  Nested Loop  (cost=0.43..70548.67 rows=1644333 width=8) (actual time=0.259..272.090 rows=1665489 loops=3)
                                 ->  Seq Scan on product p  (cost=0.00..1.07 rows=1 width=8) (actual time=0.061..0.063 rows=1 loops=3)
                                       Filter: (id = 2)
                                       Rows Removed by Filter: 5
                                 ->  Index Only Scan using idx_order_id on order_product op  (cost=0.43..54104.26 rows=1644333 width=16) (actual time=0.189..157.203 rows=1665489 loops=3)
                                       Index Cond: (product_id = 2)
                                       Heap Fetches: 0
 Planning Time: 2.564 ms
 JIT:
   Functions: 41
   Options: Inlining false, Optimization false, Expressions true, Deforming true
   Timing: Generation 12.541 ms, Inlining 0.000 ms, Optimization 6.346 ms, Emission 74.797 ms, Total 93.684 ms
 Execution Time: 2539.645 ms
(23 rows)


Планировщик использует индекс - Index Only Scan using idx_order_id on order_product
Никак не могу придумать, можно ли вот в этом месте -  Parallel Seq Scan on orders o добиться использования индекса вместо полного сканирования. Попробовал множество вариантов индексов. Если это возможно, прошу подсказку.
 */ 
 
 
CREATE UNIQUE INDEX CONCURRENTLY idx_order_product_product_id_order_id ON order_product(product_id, order_id);
CREATE UNIQUE INDEX idx_orders ON orders(id);
CREATE  UNIQUE INDEX idx_product ON product (id);
