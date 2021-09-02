import
    jester, threadpool, browsers, ws, osproc, streams,
    ws/jester_extra, os, options, json, strutils

{.warning[GcUnsafe2]: off.} # turned threadAnalysis off, no need for the warning & it's GC safe... i think 

discard execShellCmd("nim js -o:assets/main.js -d:danger mainjs.nim")
spawn openDefaultBrowser("http://localhost:5000")

# logic for nimnotebook & frontend/backend communication
#var p = startProcess(command="nim", args=["secret"], options = {poUsePath}) #can't use stderror option wtf
var p = startProcess(command="inim", options = {poUsePath, poStdErrToStdOut})
var inp = inputStream(p)
var outp = outputStream(p)

proc callKernal(procedure: string, cell: string = "", script: string = ""): Option[JsonNode] =
    # cell should be int, ok for now

    case procedure
    # TESTING INIM
    of "runKernal":
        var fullScript = script & "\necho(\"ENDOFSCRIPT\")"
        for line in fullScript.splitLines():
            inp.write(fullScript)
            inp.flush()
        var output: string
        if p.running:
            while true:
                let line = outp.readLine()
                echo line
                if line == "ENDOFSCRIPT": break
                else:
                    output.add(line & "\n")
        return some(%*{"func":"kernalOutput", "outputId":cell, "output": output})

    # of "runKernal":
    #     inp.write(script & "\necho(\"ENDOFSCRIPT\")\n")
    #     inp.flush()
    #     var output: string
    #     if p.running:
    #         while true:
    #             let line = outp.readLine()
    #             echo line
    #             if line == "ENDOFSCRIPT": break
    #             else:
    #                 output.add(line & "\n")
    #     return some(%*{"func":"kernalOutput", "outputId":cell, "output": output})

    of "resetKernal":
        # close all streams and process
        #inp.write("quit()\n")
        inp.write("exit")#IDK IF THIS WORKS # TESTING INIM
        inp.flush()
        inp.close()
        outp.close()
        p.terminate()
        let exitcode = p.waitForExit()
        p.close()
        echo "kernal process terminated with exit code: " & $exitcode
        # restart process and streams
        p = startProcess(command="nim", args=["secret"], options = {poUsePath})
        inp = inputStream(p)
        outp = outputStream(p)
        echo "new kernal process started"
        return some(%*{"message":"Nim Notebook kernal reset"})


routes:
    get "/":
        resp(Http200, readFile("assets/index.html"))
    get "/ws":
        try:
            var websocket = await newWebSocket(request)
            while websocket.readyState == Open:
                let packet = await websocket.receiveStrPacket()
                let nimData = packet.parseJson() # 'cell' param needs to be int later, ok for now
                echo nimdata
                let returnData = if nimData.fields.len > 1:
                    callKernal(nimData["procedure"].getStr, nimData["cell"].getStr, nimData["script"].getStr)
                    else: callKernal(nimData["procedure"].getStr)

                await websocket.send($returnData.get())
                
        except:
            echo "closing Nim Notebook"
            #inp.write("quit()\n")
            inp.write("exit")
            inp.flush()
            inp.close()
            outp.close()
            p.terminate()
            let exitcode = p.waitForExit()
            p.close()
            echo "kernal process terminated with exit code: " & $exitcode
            quit()
        
    get "/style.css":
        resp(Http200, readFile("assets/style.css"), "text/css")
    get "/main.js":
        resp(Http200, readFile("assets/main.js"), "text/javascript")
    get "/codemirror/dracula.css":
        resp(Http200, readFile("assets/codemirror/dracula.css"), "text/css")
    get "/codemirror/lib/codemirror.css":
        resp(Http200, readFile("assets/codemirror/lib/codemirror.css"), "text/css")
    get "/codemirror/lib/codemirror.js":
        resp(Http200, readFile("assets/codemirror/lib/codemirror.js"), "text/javascript")
    get "/codemirror/mode/nim/nim.js":
        resp(Http200, readFile("assets/codemirror/mode/nim/nim.js"), "text/javascript")