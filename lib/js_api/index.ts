
window['console'].log = function (arg){
    flutterLog.postMessage('js CHANNN log='+arg.toString());
}

console.log('hello js api');
window['reef'] = { 'version': 8, name: 'Reef Chain' };
