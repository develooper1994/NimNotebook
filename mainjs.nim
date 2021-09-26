import dom, jsconsole

type
    MessageEvent = object of Event
        data: cstring
    ReadyState = enum
        Connecting = 0, Open = 1, Closing = 2, Closed = 3
    WebSocket = ref object of EventTarget
        onmessage: proc (e: MessageEvent)
        readyState: ReadyState

proc newWebSocket(address: cstring): WebSocket {.importc:"new WebSocket"}
#proc send(socket: WebSocket, data: cstring) {.importcpp.}

var ws {.exportc.} = newWebSocket("ws://localhost:5000/ws")
ws.onmessage = proc (e: MessageEvent) =
        console.log(e.data)
        # quick prototypes
        {.emit:["let data = JSON.parse(", e.data ,")"].}
        {.emit:"""if (Object.keys(data).length > 1) {
            window[data["func"]](data["outputId"], data["output"]);
        } else {
            console.log([data["message"]]);
        }""".}
        

proc kernalCall(procedure: cstring ; cell: int ; script: cstring) {.exportc.} =
    if ws.readyState == ReadyState.Open:
        {.emit:["ws.send(", "JSON.stringify({ 'procedure':",
        procedure, ",'cell':", cell, ",'script':", script, "}))"].} # quick prototype
    else:
        kernalCall(procedure, cell, script) # probably should use interval/timeout or something but ¯\_(ツ)_/¯

proc kernalReset() {.exportc.} =
    if ws.readyState == ReadyState.Open:
        {.emit:"""ws.send(JSON.stringify({ "procedure": "resetKernal" }))""".} # quick prototype
    else:
        kernalReset() # probably should use interval/timeout or something but ¯\_(ツ)_/¯