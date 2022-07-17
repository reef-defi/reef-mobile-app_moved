(() => {
  var __create = Object.create;
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getProtoOf = Object.getPrototypeOf;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target, mod));

  // src/polyfill.ts
  var require_polyfill = __commonJS({
    "src/polyfill.ts"() {
      window.global = window;
    }
  });

  // src/index.ts
  var import_polyfill = __toESM(require_polyfill());

  // ../../node_modules/@babel/runtime/helpers/esm/defineProperty.js
  function _defineProperty(obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, {
        value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    } else {
      obj[key] = value;
    }
    return obj;
  }

  // ../../node_modules/@reef-defi/extension-dapp/util.js
  function documentReadyPromise(creator) {
    return new Promise((resolve) => {
      if (document.readyState === "complete") {
        resolve(creator());
      } else {
        window.addEventListener("load", () => resolve(creator()));
      }
    });
  }

  // ../../node_modules/@reef-defi/extension-dapp/index.js
  function ownKeys(object, enumerableOnly) {
    var keys = Object.keys(object);
    if (Object.getOwnPropertySymbols) {
      var symbols = Object.getOwnPropertySymbols(object);
      if (enumerableOnly) {
        symbols = symbols.filter(function(sym) {
          return Object.getOwnPropertyDescriptor(object, sym).enumerable;
        });
      }
      keys.push.apply(keys, symbols);
    }
    return keys;
  }
  function _objectSpread(target) {
    for (var i = 1; i < arguments.length; i++) {
      var source = arguments[i] != null ? arguments[i] : {};
      if (i % 2) {
        ownKeys(Object(source), true).forEach(function(key) {
          _defineProperty(target, key, source[key]);
        });
      } else if (Object.getOwnPropertyDescriptors) {
        Object.defineProperties(target, Object.getOwnPropertyDescriptors(source));
      } else {
        ownKeys(Object(source)).forEach(function(key) {
          Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key));
        });
      }
    }
    return target;
  }
  var win = window;
  win.injectedWeb3 = win.injectedWeb3 || {};
  function web3IsInjected() {
    return Object.keys(win.injectedWeb3).length !== 0;
  }
  var isWeb3Injected = web3IsInjected();
  var web3EnablePromise = null;
  function getWindowExtensions(originName) {
    return Promise.all(Object.entries(win.injectedWeb3).map(([name, {
      enable,
      version
    }]) => Promise.all([Promise.resolve({
      name,
      version
    }), enable(originName).catch((error) => {
      console.error(`Error initializing ${name}: ${error.message}`);
    })])));
  }
  function web3Enable(originName, compatInits = []) {
    if (!originName) {
      throw new Error("You must pass a name for your app to the web3Enable function");
    }
    const initCompat = compatInits.length ? Promise.all(compatInits.map((c) => c().catch(() => false))) : Promise.resolve([true]);
    web3EnablePromise = documentReadyPromise(() => initCompat.then(() => getWindowExtensions(originName).then((values) => values.filter((value) => !!value[1]).map(([info, ext]) => {
      if (!ext.accounts.subscribe) {
        ext.accounts.subscribe = (cb) => {
          ext.accounts.get().then(cb).catch(console.error);
          return () => {
          };
        };
      }
      return _objectSpread(_objectSpread({}, info), ext);
    })).catch(() => []).then((values) => {
      const names = values.map(({
        name,
        version
      }) => `${name}/${version}`);
      isWeb3Injected = web3IsInjected();
      console.log(`web3Enable: Enabled ${values.length} extension${values.length !== 1 ? "s" : ""}: ${names.join(", ")}`);
      return values;
    })));
    return web3EnablePromise;
  }

  // src/index.ts
  var main = async () => {
    const ext = await web3Enable("Test REEF DApp");
    console.log("hello dapp111=");
  };
  main();
})();
