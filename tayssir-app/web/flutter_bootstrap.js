{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Smoothly remove the custom loader ensuring it happens right before the app runs
    const loader = document.getElementById('loader');
    if (loader) {
      loader.remove();
    }
    
    await appRunner.runApp();
  }
});
