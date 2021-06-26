import neel, osproc, os, threadpool, streams, strutils


exposeProcs:
  proc kernal(id,script: string) =

    let cmd =  "./embed " & "'" & script & "'"

    let p = startProcess(
     cmd,
      options={
        poStdErrToStdOut,
        poEvalCommand})

    let o = p.outputStream
    var output: string
    while p.running and (not o.atEnd):
      output.add("\n" & o.readLine())

    callJs("kernalOutput",id, output)
    p.close()


startApp(appMode=false)