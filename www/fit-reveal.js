
Shiny.addCustomMessageHandler('fit-and-reveal', function(x){
  
  console.log('[fit-and-reveal] payload =', x);

  let w = HTMLWidgets.find('#' + x.id);
  if (!w) return;
  let map = w.getMap();
  if (!map) return;
  
  let mapEl = document.getElementById(x.id);
  if (mapEl) mapEl.classList.add('overlaid');
  
  // build bounds from min/max lat.lng
  let b = L.latLngBounds([[x.south, x.west], [x.north, x.east]]);
  
  // snap instantly
  map.fitBounds(b, {animate: false});
  
  function hideOverlay(){
    
    let ov = document.getElementById(x.overlayId);
    if (!ov) { console.warn('overlay not found:', x.overlayId); return; }
    
    if (ov){
      void ov.offsetHeight;
      ov.classList.add('fade-out');
      ov.addEventListener('transitionend', function(){
        ov.style.display = 'none';
        
      }, {once: true});
      
      setTimeout(function(){ov.style.display= 'none';}, x.fallback || 400);
  }

  if(mapEl) mapEl.classList.remove('overlaid');
    
    }


    let tiles = [];
    map.eachLayer(function(layer){if (layer instanceof L.TileLayer) tiles.push(layer)})
  
    if (tiles.length === 0) {
    // No tiles to wait for; reveal on next paint
    requestAnimationFrame(hideOverlay);
    return;
  }

  let remaining = tiles.length;
  let revealed = false;
  function done(){
    if (!revealed && --remaining <= 0){revealed = true; hideOverlay()}
  }

  // Fallback: if 'load' doesn’t fire (cache), reveal shortly anyway.
  let timeout = setTimeout(function(){ if (!revealed) { revealed = true; hideOverlay(); } }, x.timeout || 800);

  tiles.forEach(function(tl){ tl.once('load', function(){ clearTimeout(timeout); done(); }); });

  
});



Shiny.addCustomMessageHandler('fit-and-reveal-plot', function(x){
  
  let wrap = document.getElementById(x.wrapId);
  let ov = document.getElementById(x.overlayId);
  
  if (!wrap || !ov) return ;
  
  function fade(){
    
    void ov.offsetHeight;
    ov.classList.add('fade-out');
    ov.addEventListener('transitionend', function(){
        ov.style.display = 'none';
        
      }, {once: true});
      setTimeout(function(){ov.style.display= 'none';}, x.fallback || 400);
  }
  
  let imgs = wrap.querySelectorAll('img');
  let pending = 0;
  imgs.forEach(function(img){
    if (img.complete) return;
    pending++;
    img.addEventListener('load', function(){if(--pending <= 0) fade();});
    img.addEventListener('error', function(){if(--pending<= 0) fade()});
  });
  
  if (pending === 0) fade();
  else setTimeout(fade, x.timeout || 1200);

});





