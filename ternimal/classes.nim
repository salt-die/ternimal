import std/[macros, sequtils, sugar, tables]

type
  VTable = Table[string, NimNode]

  ClassInternal = tuple
    id: NimNode
    mro: seq[NimNode]
    attrs, methods: VTable

let
  BaseInternal {.compile_time.}: ClassInternal = (
    id: ident"BaseClass",
    mro: @[ident"BaseClass"],
    attrs: VTable(),
    methods: VTable(),
  )

var
  class_lookup {.compile_time.}: Table[string, ClassInternal] = {
    $BaseInternal.id: BaseInternal,
  }.to_table

proc linearize(bases: seq[seq[NimNode]]): seq[NimNode] =
  if bases.len == 0:
    return

  var candidate: NimNode

  for base in bases:
    candidate = base[0]
    if bases.allit(candidate notin it[1..^1]):
      return @[candidate] & collect(
        for base in bases:
          if base[0] != candidate:
            base
          elif base.len > 1:
            base[1..^1]
      ).linearize

  error "can't resolve bases"

proc method_resolution(bases: seq[NimNode], name: NimNode): seq[NimNode] =
  ## Deterministic method resolution order using C3 linearization
  ## See: https://en.wikipedia.org/wiki/C3_linearization
  @[name] & bases.mapit(class_lookup[$it].mro).linearize

proc set_node_type(node: NimNode) =
  ## Replace empty annotations for vars and consts.
  node.expectKind {nnkIdentDefs, nnkConstDef}
  if node[^2].kind == nnkEmpty:
    node[^2] = newCall(ident"typeof", node[^1])

proc class_const(class_id, constant: NimNode): NimNode =
  ## Constant lookups for classes.
  let
    id = constant[0]
    kind = constant[1]
    val = constant[2]

  quote do:
    proc `id`*(cls: type(`class_id`) or `class_id`): `kind` = `val`

proc parse_class_body(body, class_id: NimNode, mro: seq[NimNode]): tuple[attrs: VTable, methods: VTable]=
  result.attrs = VTable()
  result.methods = VTable()

  for node in body:
    case node.kind
    of nnkVarSection:
      for variable in node:
        variable.set_node_type
        result.attrs[$variable[0]] = variable
    of nnkConstSection:
      for constant in node:
        constant.set_node_type
        result.methods[$constant[0]] = class_const(class_id, constant)
    of nnkProcDef, nnkFuncDef, nnkIteratorDef, nnkConverterDef:  # nnkMethodDef, nnkTemplateDef not handled.
      # Add `self` to arguments of callable
      node[3].insert 1, nnkIdentDefs.newTree(ident"self", class_id, newEmptyNode())

      # Replace `super()` with parent's method.
      for i, statement in node[6]:
        if statement.kind == nnkCall and statement[0] == ident"super":
          block find_super:
            for parent in mro[1..^1]:
              if $node[0] in class_lookup[$parent].methods:
                node[6][i] = class_lookup[$parent].methods[$node[0]][6]
                break find_super

            # Corresponding parent method doesn't exist. Should we error?
            node[6][i] = quote do: discard

      result.methods[$node[0]] = node
    else:
      discard

macro class*(head: untyped, body: untyped = nnkEmpty.newNimNode): untyped =
  var
    id: NimNode
    bases: seq[NimNode]

  case head.kind:
  of nnkIdent:  # class MyClass
    id = head
    bases.add BaseInternal.id
  of nnkCall:  # class MyClass(ParentA, ParentB)
    id = head[0]
    bases.add head[1..^1]
  else: error "class syntax error"

  let
    mro = bases.method_resolution id
    (attrs, methods) = body.parse_class_body(id, mro)
    mro_repr = mro.mapit($it)
    name = $id
    vars = nnkRecList.newNimNode

  class_lookup[name] = (
    id: id,
    mro: mro,
    attrs: attrs,
    methods: methods,
  )

  result = nnkStmtList.newNimNode
  result.add quote do:
    type `id`* = ref object

  result.last()[0][2][0][2] = vars

  for attr in attrs.values:
    vars.add nnkIdentDefs.newTree(
      nnkPostfix.newTree(ident"*", attr[0]),
      attr[1],
      newEmptyNode(),
    )

  result.add quote do:
    proc clsname*(cls: type(`id`) or `id`): string =
      `name`

  result.add quote do:
    proc mro*(cls: type(`id`) or `id`): seq[string] =
      @`mro_repr`

  for m in methods.values:
    result.add m

when is_main_module:
  class A
  class B
  class C:
    proc meow =
      echo "meow"

  class D
  class E
  class K1(C, B, A)
  class K2(B, D, E)
  class K3(A, D)

  # Full class specification:
  class Z(K1, K3, K2):
    const
      version = (1, 2)

    var
      a: int
      b: string

    proc set_a(a: int) =
      self.a = a

    proc meow =
      super()

  echo K1.mro
  echo K2.mro
  echo K3.mro
  echo Z.mro
  echo Z.version
  var z = Z(a: 1, b: "hi")
  z.set_a(10)
  echo z.a
  z.meow()