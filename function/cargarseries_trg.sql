-- Function: cargarseries_trg()

-- DROP FUNCTION cargarseries_trg();

CREATE OR REPLACE FUNCTION cargarseries_trg()
  RETURNS trigger AS
$BODY$ DECLARE 
v_tmplid integer;
v_producto  integer;
v_lote integer;
v_location integer;
v_RECORD RECORD;
cont integer;
v_productoname character varying(100);
v_stockoperation integer;
v_cont integer;
v_total integer;
v_total2 integer;
v_contpr integer;
v_locationid integer;
v_qtydone numeric;
v_qty double precision;
v_origin character varying(67);
v_order integer;
v_price numeric;
--cantidad double;
BEGIN

IF upper(NEW.PRODUCTO) != 'PRODUCTO' OR upper(new.producto) != 'PRODUCTOS' then
	v_productoname:=new.producto;
	SELECT count(id) into v_contpr FROM PRODUCT_TEMPLATE where name=new.producto;
	IF v_contpr = 0 then
		RAISE EXCEPTION '%','El producto '|| new.producto || ' no esta registrado, favor de revisar el nombre de este.';
	ELSE 
		SELECT id into v_tmplid FROM PRODUCT_TEMPLATE where name=new.producto;
		select id into v_producto from product_product where product_tmpl_id=v_tmplid;
		select count(id) into v_cont from stock_pack_operation where picking_id=new.stockpicking_id and product_id=v_producto;
		IF v_cont = 0 then
			RAISE EXCEPTION '%','En las lineas de tu registro no esta el producto a cargar en excel';
		ELSE 
		
			select id,location_id,product_qty into v_stockoperation,v_locationid,v_qtydone 
			from stock_pack_operation where picking_id=new.stockpicking_id and product_id=v_producto;
			--select * from stock_production_lot limit 1
			--select * from load_series limit 1
			INSERT INTO stock_production_lot(
				     product_id,  name,load, create_date, create_uid, write_uid, write_date)
			    VALUES (v_producto, new.serie,'t', new.create_date, new.create_uid, new.write_uid,new.write_date);
			    
			SELECT id into v_lote from stock_production_lot where  product_id=v_producto and name=new.serie;
			v_qty := v_qtydone::double precision;
	
			select origin into v_origin from stock_picking where id=new.stockpicking_id;
			SELECT id into v_order FROM purchase_order where name=v_origin;
			select price_unit into v_price from purchase_order_line where order_id=v_order and product_id=v_producto;
			
			INSERT INTO stock_quant(
				     lot_id, location_id, company_id,qty, product_id, in_date,create_date,create_uid,write_uid,write_date
				     ,cost)
			    VALUES (v_lote, v_locationid, 1,1, v_producto, now(),NOW(),1,1,NOW(),v_price);
			
			  
				INSERT INTO stock_pack_operation_lot(
					    lot_name, qty_todo, qty, 
					    lot_id, operation_id,create_date,create_uid,write_uid,write_date)
				    VALUES (new.serie, 0, 1, v_lote,v_stockoperation,NOW(),1,1,NOW());

				
			
			Select count(*) into v_total from stock_pack_operation_lot  where operation_id=v_stockoperation;
			Update stock_pack_operation set qty_done=v_total::numeric  where id=v_stockoperation;

		END IF;
	END IF;
END IF;

 RETURN NEW;
END 

; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cargarseries_trg()
  OWNER TO postgres;




  


CREATE TRIGGER  cargarseries_trg
  BEFORE INSERT OR UPDATE 
  ON  load_series
  FOR EACH ROW
  EXECUTE PROCEDURE  cargarseries_trg();
  ------ODOOO 11




CREATE OR REPLACE FUNCTION cargarseries_trg()
  RETURNS trigger AS
$BODY$ DECLARE
v_tmplid integer;
v_producto  integer;
v_lote integer;
v_location integer;
v_RECORD RECORD;
cont integer;
v_productoname character varying(100);
v_stockoperation integer;
v_cont integer;
v_total integer;
v_total2 integer;
v_contpr integer;
v_locationid integer;
v_qtydone numeric;
v_qty double precision;
v_origin character varying(67);
v_order integer;
v_price numeric;
v_tracking  character varying(67);
v_moveline integer;
--cantidad double;
BEGIN

IF upper(NEW.PRODUCTO) != 'PRODUCTO' OR upper(new.producto) != 'PRODUCTOS' then
	v_productoname:=new.producto;
	SELECT count(id) into v_contpr FROM PRODUCT_TEMPLATE where name=new.producto;
	IF v_contpr = 0 then
		RAISE EXCEPTION '%','El producto '|| new.producto || ' no esta registrado, favor de revisar el nombre de este.';
	ELSE
		SELECT id into v_tmplid FROM PRODUCT_TEMPLATE where name=new.producto;
		--SELECT id FROM PRODUCT_TEMPLATE where name='VARIOS MODELOS FANCY DIARI CARTERA';
		select id into v_producto from product_product where product_tmpl_id=v_tmplid;
		--RAISE EXCEPTION '%','Entre1'|| new.stockpicking_id  ;
		if v_producto =1 then
		--RAISE EXCEPTION '%','Entre3' ;
			select count(id) into v_cont from stock_move where picking_id=new.stockpicking_id and product_id=v_producto;
			--RAISE EXCEPTION '%','Entre1' ;
			IF v_cont = 0 then
				RAISE EXCEPTION '%','En las lineas de tu registro no esta el producto a cargar en excel';
			end if;
		else

			select count(id) into v_cont from stock_move where picking_id=new.stockpicking_id and name=new.producto;

			IF v_cont = 0 then
				RAISE EXCEPTION '%','En las lineas de tu registro no esta el producto a cargar en excel';
			else
				select product_id into v_producto from stock_move where picking_id=new.stockpicking_id and name=new.producto;

			end if;
		end if;
		--select id  from product_product where product_tmpl_id=17315;
		--delete from  product_product where id =16895
		--RAISE EXCEPTION '%','El producto '|| new.stockpicking_id  ;
		--select * from stock_move where picking_id=169 and product_id=19914;
		--select product_tmpl_id from product_product where id=19914
		--select * from stock_move_line where move_id=171
		--select * from stock_move where picking_id=171
		--select * from stock_move_line where move_id=15525
		select tracking into v_tracking from product_template where id=v_tmplid;

		if v_tracking = 'serial' then
		--RAISE EXCEPTION '%','Entre '|| new.stockpicking_id  ;
			select id,location_id,product_qty into v_stockoperation,v_locationid,v_qtydone
			from stock_move where picking_id=new.stockpicking_id and product_id=v_producto;
			--select * from stock_production_lot limit 1
			--select * from load_series limit 1
			INSERT INTO stock_production_lot(
				     product_id,  name,load, create_date, create_uid, write_uid, write_date)
			    VALUES (v_producto, new.serie,'t', new.create_date, new.create_uid, new.write_uid,new.write_date);

			SELECT id into v_lote from stock_production_lot where  product_id=v_producto and name=new.serie;
			v_qty := v_qtydone::double precision;

			select origin into v_origin from stock_picking where id=new.stockpicking_id;
			SELECT id into v_order FROM purchase_order where name=v_origin;
			select price_unit into v_price from purchase_order_line where order_id=v_order and product_id=v_producto;

			select ID into v_moveline from stock_move_line where move_id=v_stockoperation;
			UPDATE STOCK_MOVE_LINE SET LOT_ID = v_lote, LOT_NAME=new.serie, QTY_DONE=1 WHERE ID=v_moveline;


			--Select count(*) into v_total from stock_move_line  where id=v_moveline;
			--Update stock_move set quantity_done=v_total::numeric  where id=v_stockoperation;

		END IF;
	END IF;
END IF;

 RETURN NEW;
END

; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cargarseries_trg()
  OWNER TO odoo;
