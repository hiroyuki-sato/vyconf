let max = 9999

(* Path length *)
let max_depth = 100

(* Number of children *)
let max_children = 1000

(* Number of paths *)
let max_paths = 1000

let val_of x =
    match x with
    | Some x -> x
    | None -> failwith "No value here"

let insert_full tree path data =
    let rec aux tree path basepath data =
        match path with
        | [] -> tree
        | p :: ps ->
            let basepath = basepath @ [p] in
            let tree = Vytree.insert tree basepath data in
            aux tree ps basepath data
    in
    let existent_path = Vytree.get_existent_path tree path in
    let rest = val_of @@ Vylist.complement path existent_path in
    aux tree rest existent_path ()

let rec add_many_children t n basepath data =
    if n >= 0 then 
       let t = Vytree.insert t (basepath @ [(string_of_int n)]) () in
       add_many_children t (n - 1) basepath data
    else t

let rec random_path n xs = 
    if n >= 0 then (string_of_int (Random.int max)) :: (random_path (n-1) xs)
    else xs

let rec do_inserts tree child n =
    if n >= 0 then
        let p = random_path max_depth [] in
        let tree = insert_full tree (child :: p) () in
        do_inserts tree child (n - 1)
    else tree

let tree = Vytree.make () "root"

(* Add a hundred children *)
let tree = add_many_children tree max_children [] ()

(* Use the last child to ensure that the child list is traversed
   to the end every time *)
let name = List.nth (Vytree.list_children tree) (max_children - 1)

let _ = do_inserts tree name max_paths
