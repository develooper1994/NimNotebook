/* Generated by the Nim Compiler v1.4.8 */
var framePtr = null;
var excHandler = 0;
var lastJSError = null;
if (!Math.trunc) {
  Math.trunc = function(v) {
    v = +v;
    if (!isFinite(v)) return v;
    return (v - v % 1) || (v < 0 ? -0 : v === 0 ? v : 0);
  };
}

function HEX3Aanonymous_1902036(e_1902038) {
    console.log(e_1902038.data);
    let data = JSON.parse(e_1902038.data)
    if (Object.keys(data).length > 1) {
            window[data["func"]](data["outputId"], data["output"]);
        } else {
            console.log([data["message"]]);
        }

  
}
var ws = new WebSocket("ws://localhost:5000/ws");
ws.onmessage = HEX3Aanonymous_1902036;
function kernalCall(procedure_1902112, cell_1902113, script_1902114) {
    if ((ws.readyState == 1)) {
    ws.send(JSON.stringify({ 'procedure':procedure_1902112,'cell':cell_1902113,'script':script_1902114}))
    }
    else {
    kernalCall(procedure_1902112, cell_1902113, script_1902114);
    }
    

  
}
function kernalReset() {
    if ((ws.readyState == 1)) {
    ws.send(JSON.stringify({ "procedure": "resetKernal" }))
    }
    else {
    kernalReset();
    }
    

  
}
