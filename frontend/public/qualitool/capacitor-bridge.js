(function(){
  // Tiny runtime helper to detect Capacitor v5/v6 globals safely
  function isNative(){
    try {
      if (!window.Capacitor) return false;
      if (typeof window.Capacitor.getPlatform === 'function') return window.Capacitor.getPlatform() !== 'web';
      if (typeof window.Capacitor.isNativePlatform === 'function') return !!window.Capacitor.isNativePlatform();
      return false;
    } catch(_) { return false; }
  }
  function getPlugin(name){
    try { return window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins[name]; } catch(_) { return undefined; }
  }
  window.__CapHelper = { isNative, getPlugin };
})();