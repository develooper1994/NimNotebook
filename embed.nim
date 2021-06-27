import compiler/nimeval, compiler/ast, compiler/llstream, compiler/renderer, os, osproc, strutils, algorithm


proc executeScript*(script: string) =
  var
    nimdump = execProcess("nim dump")
    nimlibs = nimdump[nimdump.find("-- end of list --")+18..^2].split

  # adding .nimble packages here
  for kind, path in walkDir(getHomeDir() / ".nimble" / "pkgs"):
    if kind == pcDir:
        nimlibs.add path
  
  nimlibs.sort

  let intr = createInterpreter("script.nims",nimlibs)

  # perhaps i need a 'global script' that will contain values/variables/etc from past cell script runs

  intr.evalScript(llStreamOpen(script))

  #testing for adding global variables/procs/types/etc for subsequent scripts (cells)
  for sym in intr.exportedSymbols:
    echo "---"
    echo sym #the symbol aka PSym
    echo renderTree(astDef(sym)) #this is how to get the string, outputs the body
    echo sym.name.s #gets name of sym
    echo "-"
    echo sym.typ.kind
    echo "-"
    echo sym.typ.n
    echo "-"
    echo sym.typ.callConv
    echo "---\n"

  intr.destroyInterpreter()
  

  
when isMainModule:
  let script = paramStr(1)
  executeScript(script)
# compile this w/ 'nim c -d:release embed.nim