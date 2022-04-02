## For inheritable widget behaviors, full OO will need to be implemented.
## Notes
## -----
## * Attributes and methods are not yet implemented.
## * Attributes will likely be descriptors for dispatches.
## * `all_classes` can be removed if we figure out how to bind idents at compile time.
import std/[macros, sequtils, strformat, sugar, tables]

type
  ClassInfo = ref object
    name: string
    bases, mro: seq[string]
    attrs, methods: seq[NimNode]  # attrs and methods will probably be replaced by chainmaps

# TODO: default `init`/`$`
let
  BaseClass {.compileTime.} = ClassInfo(name: "BaseClass", mro: @["BaseClass"])

var
  all_classes {.compileTime.}: Table[string, ClassInfo] = {BaseClass.name: BaseClass}.to_table

proc linearize(bases: seq[seq[string]]): seq[string] =
  if bases.len == 0:
    return

  var candidate: string

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

proc method_resolution(name: string, bases: seq[string]): seq[string] =
  ## Deterministic method resolution order using C3 linearization
  @[name] & bases.mapit(all_classes[it].mro).linearize

macro class*(head, body: untyped): untyped =
  var
    name: string
    bases: seq[string]
    attrs: seq[NimNode]
    methods: seq[NimNode]

  case head.kind:
  of nnkIdent:
    name = $head
    if name != BaseClass.name:
      bases.add BaseClass.name
  of nnkCall:
    name = $head[0]
    for base in head[1..^1].mapit $it:
      if base notin all_classes:
        error fmt"{base} not defined"
      bases.add base
  else: error "bad class syntax"

  if name in all_classes:
    error "class redefinition not allowed"

  var classinfo = ClassInfo(
    name: name,
    bases: bases,
    mro: method_resolution(name, bases),
    attrs: attrs,
    methods: methods
  )
  all_classes[name] = classinfo

  result = newNimNode(nnkVarSection).add(newIdentDefs(name.ident, newEmptyNode(), newLit(classinfo)))

macro class*(head: untyped): untyped =
  ## Empty class definition
  quote do: class `head`: discard

when is_main_module:
  class A
  class B
  class C
  class D
  class E
  class K1(C, B, A)
  class K2(B, D, E)
  class K3(A, D)
  class Z(K1, K3, K2)

  echo A.mro
  echo B.mro
  echo C.mro
  echo D.mro
  echo E.mro
  echo K1.mro
  echo K2.mro
  echo K3.mro
  echo Z.mro

  # @["A", "BaseClass"]
  # @["B", "BaseClass"]
  # @["C", "BaseClass"]
  # @["D", "BaseClass"]
  # @["E", "BaseClass"]
  # @["K1", "C", "B", "A", "BaseClass"]
  # @["K2", "B", "D", "E", "BaseClass"]
  # @["K3", "A", "D", "BaseClass"]
  # @["Z", "K1", "C", "K3", "K2", "B", "A", "D", "E", "BaseClass"]
