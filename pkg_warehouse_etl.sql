create or replace package pkg_warehouse_etl as 
type type_material is record (
id_material integer,
quantity integer,
last_date DATE,
agency varchar2(30)
);

g_max_date date;

type tab_material is table of type_material index by pls_integer;


procedure pr_start_etl;
procedure pr_load_contractors;
function fn_load_goodsflow return tab_material;
function fn_load_goodsflow_update(v_tab_material_in tab_material ) return tab_material;
function fn_load_goodsflow_delete(v_tab_material_in tab_material ) return tab_material;
function fn_load_loss(v_tab_material_in tab_material ) return tab_material;
function fn_load_loss_update(v_tab_material_in tab_material ) return tab_material;
function fn_load_loss_delete(v_tab_material_in tab_material ) return tab_material;
procedure fn_calculate_storageState(v_tab_material_in tab_material);

procedure pr_load_error_goodsflow;
procedure pr_load_error_loss;

end pkg_warehouse_etl;

/

create or replace PACKAGE BODY PKG_WAREHOUSE_ETL AS

  procedure pr_start_etl AS
  v_tab_material tab_material;
  BEGIN
   select max(date_key) into g_max_date from target.date_dimension;
   pr_load_error_loss;
   pr_load_error_goodsflow;

    v_tab_material:=fn_load_goodsflow;
    v_tab_material:=fn_load_goodsflow_update(v_tab_material);
    v_tab_material:=fn_load_goodsflow_delete(v_tab_material);
    v_tab_material:=fn_load_loss(v_tab_material);
    v_tab_material:=fn_load_loss_update(v_tab_material);
    v_tab_material:=fn_load_loss_delete(v_tab_material);
    fn_calculate_storageState(v_tab_material);
	pr_load_contractors;
  END pr_start_etl;

  procedure pr_load_contractors AS
  BEGIN
    for i in (select * from stage.contractor where is_synchronized = 0) loop
        insert into target.contractor (id_contractor,name,city,nip_number) values(i.id_contractor,i.name,i.city,i.nip_number);
        update stage.contractor set is_synchronized = 1 where id_contractor = i.id_contractor;
        commit;
    end loop;
  END pr_load_contractors;

  function fn_load_goodsflow return tab_material AS
  v_tab_material tab_material;
  v_material type_material;
  v_material_exist boolean default FALSE;
  v_date date;
  v_index_flow integer;
  v_contractor_exist boolean default false;
  v_material_exist_in_hd boolean default false;
  v_quantity_eq_zero boolean default false;
  v_error_exist boolean default false;
  BEGIN
        for FLOW in(select * from stage.GOODSFLOW) loop
            ---BLEDY W NAGLOWKU---
                for i in (select * from target.contractor where id_contractor=flow.id_contractor) loop
                    v_contractor_exist:=TRUE;
                end loop;
                if v_contractor_exist=FALSE then
                    insert into goodsflow_errors values (flow.id_flow,flow.agency,flow.operation_type,flow.operation_date,flow.id_employee,flow.id_contractor);
                    insert into flowdetails_errors select FLOW_POSITION,QUANTITY,ID_MATERIAL,ID_FLOW,AGENCY,1 from flowdetails where id_flow=flow.id_flow and agency=flow.agency;
                    delete flowdetails where id_flow=flow.id_flow and agency=flow.agency;
                    delete goodsflow where id_flow=flow.id_flow and agency=flow.agency;
                    commit;
                    v_contractor_exist:=FALSE;
                    continue;
                end if;
                v_error_exist:=false;
            ---------
            for DETAIL in(select * from stage.FLOWDETAILS where id_flow=flow.id_flow and agency=flow.agency) loop
            --TO_DO BLEDY --
            v_material_exist_in_hd:=false;
            v_quantity_eq_zero:=false;
                for i in (select * from target.material where id_material=detail.id_material) loop
                    v_material_exist_in_hd:=true;
                end loop;
                if detail.quantity = 0 then
                    v_quantity_eq_zero:=true;
                end if;
                if v_quantity_eq_zero=true then
                    if v_error_exist = false then
                        insert into goodsflow_errors values (flow.id_flow,flow.agency,flow.operation_type,flow.operation_date,flow.id_employee,flow.id_contractor);
                        v_error_exist:=true;
                    end if;
                    insert into flowdetails_errors values( detail.FLOW_POSITION,detail.QUANTITY,detail.ID_MATERIAL,detail.ID_FLOW,detail.AGENCY,3);
                    delete flowdetails where flow_position=detail.flow_position and id_flow=detail.id_flow and agency=detail.agency;
                else
                    if v_material_exist_in_hd = false then
                        if v_error_exist = false then
                        insert into goodsflow_errors values (flow.id_flow,flow.agency,flow.operation_type,flow.operation_date,flow.id_employee,flow.id_contractor);
                        v_error_exist:=true;
                        end if;
                        insert into flowdetails_errors values( detail.FLOW_POSITION,detail.QUANTITY,detail.ID_MATERIAL,detail.ID_FLOW,detail.AGENCY,2);
                        delete flowdetails where flow_position=detail.flow_position and id_flow=detail.id_flow and agency=detail.agency;
                    end if;
                end if;
                commit;
            if v_material_exist_in_hd =false OR  v_quantity_eq_zero=true then
                continue;
            end if;

            --------------
                v_index_flow:=seq_goodsflow.nextval;
                insert into target.goods_flow_keys values(v_index_flow,detail.agency,detail.id_flow,detail.flow_position);
                select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=flow.operation_date and DATE_KEY>flow.operation_date-1;
                insert into target.goodsflow values(v_index_flow,detail.agency,flow.operation_type,detail.quantity,detail.id_material,flow.id_contractor,v_date,g_max_date);

                if(v_tab_material.count !=0) then
                for i in  v_tab_material.first .. v_tab_material.last loop
                    if v_tab_material(i).id_material = detail.id_material AND v_tab_material(i).agency = detail.agency then
                    v_material_exist:=true;
                        if flow.operation_type='PZ' then
                        v_tab_material(i).quantity := v_tab_material(i).quantity + detail.quantity;
                        elsif flow.operation_type='WZ' then
                         v_tab_material(i).quantity := v_tab_material(i).quantity - detail.quantity;
                        end if;
                        if v_tab_material(i).last_date < flow.operation_date then
                            v_tab_material(i).last_date :=flow.operation_date;
                        end if;
                    end if;    
                end loop;
                end if;

                if v_material_exist=false then
                    v_material.id_material:= detail.id_material;
                     if flow.operation_type='PZ' then
                         v_material.quantity:= detail.quantity;
                        elsif flow.operation_type='WZ' then
                          v_material.quantity:= -detail.quantity;
                        end if;

                    v_material.last_date:=flow.operation_date;
                    v_material.agency:=detail.agency;
                    if v_tab_material.count !=0 then
                         v_tab_material(v_tab_material.last +1):=v_material;
                    else
                        v_tab_material(1):=v_material;
                    end if;
                end if;
                v_material_exist:=false;
                delete stage.FLOWDETAILS where id_flow=flow.id_flow and agency=flow.agency and FLOW_POSITION=detail.flow_position;
                commit;
            end loop;    
           delete stage.goodsflow where id_flow= flow.id_flow and agency=flow.agency;
        end LOOP;
        commit;
    RETURN v_tab_material;
  END fn_load_goodsflow;

function fn_load_goodsflow_update(v_tab_material_in tab_material ) return tab_material AS
V_INDEX_FLOW INTEGER;
V_DATE DATE;
v_row_detail target.goodsflow%rowtype;
v_tab_material tab_material;
 v_material type_material;
 v_material_exist boolean default FALSE;
begin
v_tab_material:=v_tab_material_in;
    for DETAIL in (select * from FLOWDETAILS_UPDATE) loop
        SELECT INDEX_FLOW INTO V_INDEX_FLOW FROM TARGET.Goods_flow_keys WHERE ID_FLOW=DETAIL.ID_FLOW AND AGENCY=DETAIL.AGENCY AND FLOW_POSITION=DETAIL.FLOW_POSITION;
        select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=DETAIL.DATE_UPDATED and DATE_KEY>DETAIL.DATE_UPDATED-1;
        select * into v_row_detail from target.goodsflow where index_flow = v_index_flow and date_end= g_max_date;
        --TO DO BLEDY--

        -------------
        update target.goodsflow set date_end = v_date where index_flow=v_index_flow and date_end = g_max_date;
        insert into target.goodsflow values(V_INDEX_FLOW,detail.agency,v_row_detail.operation_type,detail.quantity,detail.id_material,v_row_detail.id_contractor,v_date,g_max_date);


                if(v_tab_material.count !=0) then
                for i in  v_tab_material.first .. v_tab_material.last loop
                    if v_tab_material(i).id_material = detail.id_material AND v_tab_material(i).agency = detail.agency then
                    v_material_exist:=true;
                        if v_row_detail.operation_type='PZ' then
                        v_tab_material(i).quantity := v_tab_material(i).quantity - (v_row_detail.quantity - detail.quantity);
                        elsif v_row_detail.operation_type='WZ' then
                         v_tab_material(i).quantity := v_tab_material(i).quantity + (v_row_detail.quantity -detail.quantity);
                        end if;
                        if v_tab_material(i).last_date < detail.DATE_UPDATED then
                            v_tab_material(i).last_date :=detail.DATE_UPDATED;
                        end if;
                    end if;    
                end loop;
                end if;

                if v_material_exist=false then
                    v_material.id_material:= detail.id_material;

                     if v_row_detail.operation_type='PZ' then
                        v_material.quantity:= -(v_row_detail.quantity-detail.quantity);
                        elsif v_row_detail.operation_type='WZ' then
                         v_material.quantity:= (v_row_detail.quantity-detail.quantity);
                        end if;

                    v_material.last_date:=detail.date_updated;
                    v_material.agency:=detail.agency;
                    if v_tab_material.count !=0 then
                         v_tab_material(v_tab_material.last +1):=v_material;
                    else
                        v_tab_material(1):=v_material;
                    end if;
                end if;
                v_material_exist:=false;

            delete stage.flowdetails_update where id_flow= detail.id_flow and date_updated=detail.date_updated and flow_position=detail.flow_position;


    end loop;
    return v_tab_material;
end fn_load_goodsflow_update;



function fn_load_goodsflow_delete(v_tab_material_in tab_material ) return tab_material AS
V_INDEX_FLOW INTEGER;
V_DATE DATE;
v_row_detail target.goodsflow%rowtype;
v_tab_material tab_material;
 v_material type_material;
 v_material_exist boolean default FALSE;
begin
    v_tab_material:=v_tab_material_in;
    for DETAIL in (select * from FLOWDETAILS_DELETED) loop
        SELECT INDEX_FLOW INTO V_INDEX_FLOW FROM TARGET.Goods_flow_keys WHERE ID_FLOW=DETAIL.ID_FLOW AND AGENCY=DETAIL.AGENCY AND FLOW_POSITION=DETAIL.FLOW_POSITION;
        select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=DETAIL.DATE_DELETED and DATE_KEY>DETAIL.DATE_DELETED-1;
        select * into v_row_detail from target.goodsflow where index_flow = v_index_flow and date_end= g_max_date;
        --TO DO BLEDY--

        -------------
        update target.goodsflow set date_end = v_date where index_flow=v_index_flow and date_end = g_max_date;          

                if(v_tab_material.count !=0) then
                for i in  v_tab_material.first .. v_tab_material.last loop
                    if v_tab_material(i).id_material = detail.id_material AND v_tab_material(i).agency = detail.agency then
                    v_material_exist:=true;
                        if v_row_detail.operation_type='PZ' then
                        v_tab_material(i).quantity := v_tab_material(i).quantity - (detail.quantity);
                        elsif v_row_detail.operation_type='WZ' then
                         v_tab_material(i).quantity := v_tab_material(i).quantity + (detail.quantity);
                        end if;
                        if v_tab_material(i).last_date < detail.DATE_DELETED then
                            v_tab_material(i).last_date :=detail.DATE_DELETED;
                        end if;
                    end if;    
                end loop;
                end if;

                if v_material_exist=false then
                    v_material.id_material:= detail.id_material;

                     if v_row_detail.operation_type='PZ' then
                        v_material.quantity:= -(detail.quantity);
                        elsif v_row_detail.operation_type='WZ' then
                         v_material.quantity:= (detail.quantity);
                        end if;

                    v_material.last_date:=detail.date_deleted;
                    v_material.agency:=detail.agency;
                    if v_tab_material.count !=0 then
                         v_tab_material(v_tab_material.last +1):=v_material;
                    else
                        v_tab_material(1):=v_material;
                    end if;
                end if;
                v_material_exist:=false;

            delete stage.flowdetails_deleted where id_flow= detail.id_flow and date_deleted=detail.date_deleted and flow_position=detail.flow_position;


    end loop;
    return v_tab_material;

end fn_load_goodsflow_delete;


  function fn_load_loss(v_tab_material_in tab_material) return tab_material AS
    v_tab_material tab_material;
    v_material type_material;
    v_material_exist boolean default FALSE;
    v_date date;
    v_material_exist_in_hd boolean default false;
    v_quantity_is_zero boolean default false;
  BEGIN
  v_tab_material:=v_tab_material_in;
    for loss in (select * from stage.loss) loop
      -------------------BLEDY----------------
      v_quantity_is_zero:=false;
      v_material_exist_in_hd:=false;
        for i in(select null from target.material where id_material=loss.id_material) loop
            v_material_exist_in_hd:=true;
        end loop;
        if loss.quantity = 0 then
            v_quantity_is_zero:=true;
        end if;

        if v_quantity_is_zero= true then
           insert into Loss_errors values (LOSS.ID_LOSS,LOSS.AGENCY,Loss.quantity,loss.event_date,loss.id_material,2);
           delete loss where id_loss=loss.id_loss and agency=loss.agency;
        else
            if v_material_exist_in_hd = false then
                insert into Loss_errors values (LOSS.ID_LOSS,LOSS.AGENCY,Loss.quantity,loss.event_date,loss.id_material,1);
           delete loss where id_loss=loss.id_loss and agency=loss.agency;
            end if;
        end if;
        commit;
        if v_quantity_is_zero = true or v_material_exist_in_hd= false then
            continue;
        end if;

    -------------------------------------------

        select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=loss.event_date and DATE_KEY>loss.event_date-1;
        insert into target.loss values(loss.id_loss,loss.agency,loss.quantity,loss.id_material,v_date,g_max_date);

         if(v_tab_material.count !=0) then
                for i in  v_tab_material.first .. v_tab_material.last loop
                    if v_tab_material(i).id_material = loss.id_material AND v_tab_material(i).agency = loss.agency then
                    v_material_exist:=true;
                    v_tab_material(i).quantity := v_tab_material(i).quantity - loss.quantity;
                        if v_tab_material(i).last_date < loss.event_date then
                          v_tab_material(i).last_date :=loss.event_date;
                        end if;
                    end if;    
                end loop;

        end if;

         if v_material_exist=false then
             v_material.id_material:= loss.id_material;
            v_material.quantity:=- loss.quantity;
             v_material.last_date:=loss.event_date;
             v_material.agency:=loss.agency;
            if v_tab_material.count !=0 then
                   v_tab_material(v_tab_material.last +1):=v_material;
             else
                     v_tab_material(1):=v_material;
             end if;
         end if;
                v_material_exist:=false;
        delete stage.loss where id_loss=loss.id_loss and agency = loss.agency;
    end loop;
    commit;
    RETURN v_tab_material;
  END fn_load_loss;

function fn_load_loss_update(v_tab_material_in tab_material ) return tab_material AS
v_tab_material tab_material;
    v_material type_material;
    v_material_exist boolean default FALSE;
    v_date date;
    v_row_loss target.loss%rowType;
    v_id_loss integer;
    v_agency varchar2(40);
begin
 v_tab_material:=v_tab_material_in;
    for loss in (select id_loss,agency,date_updated,id_material,quantity from LOSS_UPDATE) loop
        DBMS_OUTPUT.PUT_LINE(loss.id_loss);
        v_id_loss:=loss.id_loss;
        v_agency:=loss.agency;
        select * into v_row_loss from target.LOSS where date_end=g_max_date and id_loss=v_id_loss and agency=v_agency;
        select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=loss.date_updated and DATE_KEY>loss.date_updated-1;
        update target.loss set date_end = v_date where id_loss=loss.id_loss and date_end=g_max_date and agency=loss.agency;
        insert into target.loss values(loss.id_loss,loss.agency,loss.quantity,loss.id_material,v_date,g_max_date);

         if(v_tab_material.count !=0) then
                for i in  v_tab_material.first .. v_tab_material.last loop
                    if v_tab_material(i).id_material = loss.id_material AND v_tab_material(i).agency = loss.agency then
                    v_material_exist:=true;
                    v_tab_material(i).quantity := v_tab_material(i).quantity +(v_row_loss.quantity- loss.quantity);
                        if v_tab_material(i).last_date < loss.date_updated then
                          v_tab_material(i).last_date :=loss.date_updated;
                        end if;
                    end if;    
                end loop;

        end if;

         if v_material_exist=false then
             v_material.id_material:= loss.id_material;
            v_material.quantity:= (v_row_loss.quantity -loss.quantity);
             v_material.last_date:=loss.date_updated;
             v_material.agency:=loss.agency;
            if v_tab_material.count !=0 then
                   v_tab_material(v_tab_material.last +1):=v_material;
             else
                     v_tab_material(1):=v_material;
             end if;
         end if;
                v_material_exist:=false;
        delete stage.loss_update where id_loss=loss.id_loss and agency = loss.agency and date_updated=loss.date_updated;
    end loop;
    commit;
    RETURN v_tab_material;
end fn_load_loss_update;

function fn_load_loss_delete(v_tab_material_in tab_material ) return tab_material AS
v_tab_material tab_material;
    v_material type_material;
    v_material_exist boolean default FALSE;
    v_date date;
    v_row_loss target.loss%rowType;
    v_id_loss integer;
    v_agency varchar2(40);
begin
 v_tab_material:=v_tab_material_in;
    for loss in (select id_loss,agency,date_DELETED,quantity,id_material from LOSS_DELETED) loop
        v_id_loss:=loss.id_loss;
        v_agency:=loss.agency;
        select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=loss.date_DELETED and DATE_KEY>loss.date_DELETED-1;
        update target.loss set date_end = v_date where id_loss=v_id_loss and date_end=g_max_date and agency=v_agency;

         if(v_tab_material.count !=0) then
                for i in  v_tab_material.first .. v_tab_material.last loop
                    if v_tab_material(i).id_material = loss.id_material AND v_tab_material(i).agency = loss.agency then
                    v_material_exist:=true;
                    v_tab_material(i).quantity := v_tab_material(i).quantity +( loss.quantity);
                        if v_tab_material(i).last_date < loss.date_DELETED then
                          v_tab_material(i).last_date :=loss.date_DELETED;
                        end if;
                    end if;    
                end loop;

        end if;

         if v_material_exist=false then
             v_material.id_material:= loss.id_material;
            v_material.quantity:=  loss.quantity;
             v_material.last_date:=loss.date_DELETED;
             v_material.agency:=loss.agency;
            if v_tab_material.count !=0 then
                   v_tab_material(v_tab_material.last +1):=v_material;
             else
                     v_tab_material(1):=v_material;
             end if;
         end if;
                v_material_exist:=false;
        delete stage.loss_DELETED where id_loss=loss.id_loss and agency = loss.agency and date_DELETED=loss.date_DELETED;
    end loop;
    commit;
    RETURN v_tab_material;
end fn_load_loss_delete;

  procedure fn_calculate_storageState(v_tab_material_in tab_material) AS
  v_date date;
  v_material_exsist boolean default false;
  BEGIN
   select max(date_key) into v_date from target.date_dimension;
    if(v_tab_material_in.count != 0) then
        for i in v_tab_material_in.first .. v_tab_material_in.last loop
            select DATE_KEY into v_date from target.date_dimension  where DATE_KEY<=v_tab_material_in(i).last_date and DATE_KEY>v_tab_material_in(i).last_date-1;
            for storagState_row in( select * from( select * from target.storagestate where AGENCY= v_tab_material_in(i).agency and ID_MATERIAL = v_tab_material_in(i).id_material order by DATE_START desc) where rownum =1) loop
                v_material_exsist:=true;
                update target.storagestate set target.storagestate.DATE_END =  v_date where agency=v_tab_material_in(i).agency and target.storagestate.ID_MATERIAL=v_tab_material_in(i).Id_material and target.storagestate.date_start=storagState_row.date_start;
                insert into target.storagestate values(v_tab_material_in(i).agency,storagState_row.quantity+v_tab_material_in(i).quantity,v_tab_material_in(i).id_material,v_date,g_max_date);
            end loop;
            if v_material_exsist = false then
                insert into target.storagestate values(v_tab_material_in(i).agency,v_tab_material_in(i).quantity,v_tab_material_in(i).id_material,v_date,g_max_date);
            end if;
            v_material_exsist := false;
            commit;
        end loop;
    end if;
  END fn_calculate_storageState;

  procedure pr_load_error_goodsflow as
  v_flow_exist boolean default false;
  v_detail_exist boolean default false;
  begin
  for flow in( select * from GOODSFLOW_ERRORS) loop
    for detail in (select * from FLOWDETAILS_ERRORS where ID_FLOW=flow.id_flow and agency=flow.agency) loop
        if detail.CODE_ERROR<3 then
            if v_flow_exist = false then
                insert into GOODSFLOW select * from GOODSFLOW_ERRORS where id_flow=flow.id_flow and agency=flow.agency;
                commit;
                v_flow_exist:=true;
            end if;
            insert into FLOWDETAILS values(detail.flow_position,detail.quantity,detail.id_material,detail.id_flow,detail.agency);
            delete FLOWDETAILS_ERRORS where FLOW_POSITION=detail.flow_position and ID_FLOW=detail.id_flow and AGENCY=detail.agency;
            commit;
        end if;
    end loop;
    v_flow_exist := false;
    for detail in (select * from FLOWDETAILS_ERRORS where ID_FLOW=flow.id_flow and agency=flow.agency) loop
        v_detail_exist:=TRUE;
    end loop;
    if v_detail_exist = false then
        delete GOODSFLOW_ERRORS where ID_FLOW=flow.id_flow and agency=flow.agency;
        commit;
    end if;
    v_detail_exist:=false;
  end loop;
  end pr_load_error_goodsflow;


  procedure pr_load_error_loss as 

  begin
    for loss in (select * from Loss_errors where code_error<2) loop
        insert into loss values(loss.id_loss,loss.agency,loss.quantity,loss.event_date,loss.id_material);
        delete Loss_errors where id_loss=loss.id_loss and agency=loss.agency;
        commit;
    end loop;
  end pr_load_error_loss;

END PKG_WAREHOUSE_ETL;