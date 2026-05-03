{{flutter_js}}
{{flutter_build_config}}

// نظام تتبع الأخطاء المتقدم
window.addEventListener('error', function(e) {
  alert("Global Error:\n" + e.message + "\nFile: " + e.filename + "\nLine: " + e.lineno);
  console.error("Global Error Caught:", e);
});

window.addEventListener('unhandledrejection', function(e) {
  alert("Unhandled Promise Rejection:\n" + (e.reason && e.reason.stack ? e.reason.stack : e.reason));
  console.error("Unhandled Promise Rejection:", e.reason);
});

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      
      const loader = document.getElementById('loader');
      if (loader) {
        loader.remove();
      }
      
      await appRunner.runApp();
    } catch (e) {
      alert("Flutter Engine Error:\n" + e.message);
      document.body.innerHTML += '<div style="color:red; background:white; padding:20px; z-index:999999; position:absolute; top:0; left:0; width:100%; direction:ltr; text-align:left; overflow:auto;"><h2>App Crashed!</h2><pre>' + e.stack + '</pre></div>';
      console.error("Flutter Init Error:", e);
    }
  }
});
