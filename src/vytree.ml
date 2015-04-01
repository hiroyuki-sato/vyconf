type 'a	vyconf_tree = {
    name: string;
    data: 'a;
    children: 'a vyconf_tree list
}

type 'a t = 'a vyconf_tree

type node_type = Tag | Leaf | Other

type position = Before of string | After of string | Default

exception Empty_path
exception Duplicate_child
exception Nonexistent_path

let make name data = { name = name; data = data; children = [] }

let make_full name data children = { name = name; data = data; children = children }

let name_of_node node = node.name
let data_of_node node = node.data
let children_of_node node = node.children

let insert_immediate node name data =
    let new_node = make name data in
    let children' = new_node :: node.children in
    { node with children = children' }

let delete_immediate node name =
    let children' = Vylist.remove (fun x -> x.name = name) node.children in
    { node with children = children' }

let adopt node child =
    { node with children = child :: node.children }

let replace node child =
    let children = node.children in
    let name = child.name in
    let children' = Vylist.replace (fun x -> x.name = name) child children in
    { node with children = children' }

let find node name =
    Vylist.find (fun x -> x.name = name) node.children

let find_or_fail node name =
    let child = find node name in
    match child with
    | None -> raise Nonexistent_path
    | Some child' -> child'

let list_children node =
    List.map (fun x -> x.name) node.children

let rec do_with_child fn node path =
    match path with
    | [] -> raise Empty_path
    | [name] -> fn node name
    | name :: names ->
        let next_child = find_or_fail node name in
        let new_node = do_with_child fn next_child names in
        replace node new_node

let rec insert default_data node path data =
    match path with
    | [] -> raise Empty_path
    | [name] ->
        begin
            (* Check for duplicate item *)
            let last_child = find node name in
            match last_child with
            | None -> insert_immediate node name data
            | (Some _) -> raise Duplicate_child
        end
    | name :: names ->
        let next_child = find node name in
        match next_child with
        | Some next_child' ->
            let new_node = insert default_data next_child' names data in
            replace node new_node
        | None ->
            let next_child' = make name default_data in
            let new_node = insert default_data next_child' names data in
            adopt node new_node

let delete node path =
    do_with_child delete_immediate node path

let update node path data =
    let update_data data' node' dummy =
        {node' with data=data'}
    in do_with_child (update_data data) node path

let rec get node path =
    match path with
    | [] -> raise Empty_path
    | [name] -> find_or_fail node name
    | name :: names -> get (find_or_fail node name) names
