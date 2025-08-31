(function(){
  // Tiny runtime helper to detect Capacitor v5/v6 globals safely
  function isNative(){
    try { return !!(window.Capacitor &amp;&amp; typeof window.Capacitor.isNativePlatform === 'function' &amp;&amp; window.Capacitor.isNativePlatform()); } catch(_) { return false; }
  }
  function getPlugin(name){
    try { return window.Capacitor &amp;&amp; window.Capacitor.Plugins &amp;&amp; window.Capacitor.Plugins[name]; } catch(_) { return undefined; }
  }
  window.__CapHelper = { isNative, getPlugin };
})();