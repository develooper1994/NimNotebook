# compile w/ nim c -r --threads:on --threadanalysis:off nimnotebook.nim

import neelmodified, osproc, os, threadpool, streams, strutils

var p = startProcess(command="nim",args=["secret"], options = {poUsePath})
var inp = inputStream(p)
var outp = outputStream(p)

exposeProcs:
  proc kernal(id,script: string) =

      inp.write(script & "\necho(\"ENDOFSCRIPT\")\n")
      inp.flush()

      var output: string
      if p.running:
          while true:
              let line = outp.readLine()
              if line == "ENDOFSCRIPT": break
              else:
                  output.add(line & "\n")

      callJs("kernalOutput",id, output)

startApp(appMode=false)