import std/[macros, sequtils, sugar, tables]

type
  ClassInternal = tuple
    id: NimNode
    mro: seq[NimNode]
    attrs, methods: NimNode

let
  BaseInternal {.compile_time.}: ClassInternal = (
    id: ident"BaseClass",
    mro: @[ident"BaseClass"],
    attrs: newStmtList(),
    methods: newStmtList(),
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

proc method_resolution(name: NimNode, bases: seq[NimNode]): seq[NimNode] =
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

proc parse_class_body(class_id: NimNode, mro: seq[NimNode], body: NimNode): tuple[attrs: NimNode, methods: NimNode]=
  # Will likely change attrs and methods into tables for easier dispatch using chainmaps.
  # All attrs will be replaced with property-like objects that allow binding (so updating a widget property can be observed by other widgets)
  result.attrs = newStmtList()
  result.methods = newStmtList()

  for node in body:
    case node.kind
    of nnkVarSection:
      for variable in node:
        variable.set_node_type
        result.attrs.add variable
    of nnkConstSection:
      for constant in node:
        constant.set_node_type
        result.methods.add class_id.class_const constant
    of nnkProcDef, nnkMethodDef, nnkFuncDef, nnkIteratorDef, nnkConverterDef, nnkTemplateDef:
      # Insert self
      # Replace super
      #result.methods.add node
      discard
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
  else: error "bad class syntax"

  let
    mro = id.method_resolution bases
    (attrs, methods) = id.parse_class_body(mro, body)
    mro_repr = mro.mapit($it)
    name = $id

  class_lookup[name] = (
    id: id,
    mro: mro,
    attrs: attrs,
    methods: methods,
  )

  let self = quote do:
    type(`id`) or `id`

  result = quote do:
    type `id`* = ref object

    proc clsname*(cls: `self`): string =
      `name`

    proc mro*(cls: `self`): seq[string] =
      @`mro_repr`

  for m in methods:
    result.add m

when is_main_module:
  class A
  class B
  class C
  class D
  class E
  class K1(C, B, A)
  class K2(B, D, E)
  class K3(A, D)

  # Full class specialization:
  class Z(K1, K3, K2):
    const
      version = (1, 2)

    var
      a: int
      b: string

    method do_something =
      super().do_something
      echo "something done"

  echo K1.mro
  echo K2.mro
  echo K3.mro
  echo Z.mro
  echo Z.version
