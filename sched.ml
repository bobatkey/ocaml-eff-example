open Printexc

effect Fork  : (unit -> unit) -> unit
effect Yield : unit

let fork f = perform (Fork f)
let yield () = perform Yield

let run main =
  let run_q = Queue.create () in
  let enqueue k = Queue.push k run_q in
  let rec dequeue () =
    if Queue.is_empty run_q then ()
    else continue (Queue.pop run_q) ()
  in
  let rec spawn f =
    match f () with
    | () -> dequeue ()
    | exception e ->
        print_string (to_string e);
        dequeue ()
    | effect Yield k ->
        enqueue k; dequeue ()
    | effect (Fork f) k ->
        enqueue k; spawn f
  in
  spawn main
