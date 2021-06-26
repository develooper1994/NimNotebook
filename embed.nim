import compiler/nimeval, compiler/llstream, compiler/renderer, os, osproc, strutils, algorithm


proc executeScript*(script: string) =
  var
    nimdump = execProcess("nim dump")
    nimlibs = nimdump[nimdump.find("-- end of list --")+18..^2].split
  
  nimlibs.sort

  let intr = createInterpreter("script.nims",nimlibs)

  intr.evalScript(llStreamOpen(script))
  intr.destroyInterpreter()
  

  
when isMainModule:
  let script = paramStr(1)
  executeScript(script)


# compile this w/ 'nim c -d:release embed.nim