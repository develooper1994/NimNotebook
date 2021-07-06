# compile w/ nim c -r --threads:on --threadanalysis:off nimnotebook.nim

import neelmodified, osproc, os, threadpool, streams, strutils

var p = startProcess(command="nim", args=["secret"], options = {poUsePath}) #can't use stderror option wtf
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

  proc resetKernal() =
        p.terminate()
        p.close()
        echo "Kernal killed"
        p = startProcess(command="nim", args=["secret"], options = {poUsePath})
        inp = inputStream(p)
        outp = outputStream(p)
        echo "New kernal started"
        callJs("logMe","kernal was killed, then reset")


startApp(appMode=false)