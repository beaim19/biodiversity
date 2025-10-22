
(function(){
  
  // cache of pending fits keyed by element id
  window.__pendingFits = window.__pendingFits || {};
  
  function applyFit(x){
    
    if (!x || !x.id) return false;
    
    let w = (window.HTMLWidgets && HTMLWidgets.find) ? HTMLWidgets.find('#' + x.id) : null;
    if (!w) return false;
    
    let map = w.getMap();
    if (!map) return;
    
   
      // Wait one tick so the tab layout has finished. Run after layout settles
    setTimeout(function(){
      try{
        
        map.invalidateSize();
        if (x.west !== undefined){
          let b = L.latLngBounds([[x.south, x.west], [x.north, x.east]]);
          map.fitBounds(b, {animate:false});
        }
      } catch(e){
        console.warn('applyFit error: ', e)
      }

    }, x.delay || 0);
    return true;
  }
  
  

  Shiny.addCustomMessageHandler('leaflet-invalidate-and-fit', function(x){
    
    // try now; if widget not ready, queue and retry a few frames
    if(!applyFit(x)){
      
      if (x && x.id) window.__pendingFits[x.id] = x;
      let tries = 0;
      
      (function retry(){
        
        let p = x && x.id ? window.__pendingFits[x.id] : null;
        if(!p) return;
        
        if (applyFit(p)){ delete window.__pendingFits[x.id]; return;}
        if (++tries < 60) requestAnimationFrame(retry);
        
      })();
      
    }
    
  });
  
  // attach a post-render hook once HTMLWidgets is available;
  function attachPostRender(){
    
    if (!window.HTMLWidgets || !HTMLWidgets.addPostRenderHandler) return false;
    HTMLWidgets.addPostRenderHandler(function (el){
      if (!el || !el.id) return;
      let p = window.__pendingFits(el.id);
      if(p){
        //run next tick so the widget binding finishes
        setTimeout(function(){
          if (applyFit(p)) delete window.__pendingFits[el.id];
        }, 0);
      }
    });
    return true;
  }
  
  // try now; if HTMLWidgets not ready yet, wait for DOMContentLoaded
  if (!attachPostRender()){
    if (document.readyState === 'loading'){
      document.addEventListener('DOMContentLoaded', attachPostRender, {once:true});
    } else {
      // give it another tick after other sricpts load
      setTimeout(attachPostRender, 0);
    }
  }
  
/*  if(HTMLWidgets && HTMLWidgets.addPostRenderHandler){
    
    HTMLWidgets.addPostRenderHandler(function(el){
      
      
      let id = el.id, p = window.__pendingFits[id];
      if (p) {setTimeout(function(){applyFit(p); delete window.__pendingFits[id];}, 0);}
      
    });
    
  }*/
  
  
})();

//console.log('leaflet-invalidate-and-fit', x.id, x)
