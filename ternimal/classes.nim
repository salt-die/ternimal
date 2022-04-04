import std/[macros, sequtils, sugar, tables]

type
  ClassInternal = tuple
    id: NimNode
    mro, attrs, methods: seq[NimNode]

let
  BaseInternal {.compile_time.}: ClassInternal = (
    id: ident"BaseClass",
    mro: @[ident"BaseClass"],
    attrs: @[],
    methods: @[],
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
  @[name] & bases.mapit(class_lookup[$it].mro).linearize

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
    mro_repr = mro.mapit($it)
    name = $id
    # parse and resolve attributes through mro
    # parse and resolve methods through mro

  class_lookup[name] = (
    id: id,
    mro: mro,
    attrs: @[],
    methods: @[],
  )

  # add procs for each attr and method
  quote do:
    type `id`* = ref object

    proc clsname*(cls: type(`id`) or `id`): string =
      `name`

    proc mro*(cls: type(`id`) or `id`): seq[string] =
      @`mro_repr`

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
