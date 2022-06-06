(() => {
  // index.ts
  console.log("hello js api");
  window["reef"] = { "version": 8, name: "Reef Chain" };
  window.console.log = function (arg){
    flutterLog.postMessage('js CHANNN log='+arg.toString());
  }
  window['getErr'] = function (val){
    console.log('js loggg');
    return 'finished'+val;
  }
})();
