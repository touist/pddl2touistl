class node_common =
  object (self)
  end
class fluent atom =
  object (self)
    inherit node_common
    inherit [action] Node.fluent atom
  end
and action name params duration quality prec nprec add del =
  object (self)
    inherit node_common
    inherit [fluent] Node.action name params duration quality prec nprec add del
  end
class plan succes =
  object
    inherit [fluent, action] SequentialPlan.t succes
  end

class ['fluent, 'action, 'plan] tsp_common =
  object
    method create_fluent = new fluent
    method create_action = new action
    val plan_succes = new plan true
    val plan_fail = new plan false
    method plan_succes = plan_succes
    method plan_fail = plan_fail
  end


let positive_print_int i node = Utils.print "%i " (node#n i)
let positive_print_string i node = Utils.print "%s(%i) " node#to_string i
let negative_print_int i node = Utils.print "-%i " (node#n i)
let negative_print_string i node = Utils.print "-%s(%i) " node#to_string i
let endl_int () = Utils.print "0\n"
let endl_string () = Utils.print "\n"


(* [time_allowed] is in seconds. The same amount of time before timeout is
   given to finding the existence (i.e., increase the depth until the QBF is
   true) and to extracting the plan.
   [verbose] 0 -> not verbose, 1 -> more verbose, 2 -> even more verbose *)
class t (problem:string) (domain:string) (depth : int) =
  object (self)
    inherit [fluent, action, plan] PlanningData.t problem domain "" as pdata
    inherit [fluent, action, plan] tsp_common

    method print_statistics = ()
    method run = self#plan_fail
    method virtual create_action : string -> Symb.constant array -> float -> int -> ('fluent*Timedata.t) array -> ('fluent*Timedata.t) array -> ('fluent*Timedata.t) array -> ('fluent*Timedata.t) array -> 'action

    method search =
      let k = 1 in
      let cte_open_bc = (* branch constraints *)
        Array.length pdata#goal (* |G|  (1.2) *)
        + k * Array.fold_left (fun acc fl -> if Array.mem fl pdata#init_state then acc else acc+1) 0 pdata#fluents (* k |F-I| (2.1) *)
        + 2*k * Array.length pdata#fluents (* 2k |F| (2.2) *)
        + 2*k * Array.fold_left (fun acc a -> acc + Array.length a#del) 0 pdata#actions (* 2k * sum_a^A |Del(a)| (3.1) *)
      and cte_open_nc = (* node constraints *)
        (k+1) * Array.fold_left (fun acc a -> acc + Array.length a#prec) 0 pdata#actions (* (k+1) * sum_a^A |Pre(a)| *)
        (*+ (k+1) *
          List.fold_left (
            fun acc1 a1 ->
            acc1 + List.fold_left (
              fun acc2 a2 ->
                acc2 +
                  let add_or_prec1 = Array.concat [a1#add; a1#prec] in
                  let add_or_prec2 = Array.concat [a2#add; a2#prec] in
                  if  Array.fold_left (fun del acc -> acc || Array.mem del add_or_prec1) false a2#del
                   || Array.fold_left (fun del acc -> acc || Array.mem del add_or_prec2) false a1#del
                then 1 else 0
              ) acc1 pdata#actions
            ) 0 pdata#actions
          )
          Array.fold_left (fun acc a -> acc + Array.length a#prec) 0 pdata#actions
          *)
      in
      Utils.print "CTE-OPEN\nBranch constraints: %d\nNode constraints: %d" 0 0;
  end