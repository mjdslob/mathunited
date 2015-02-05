//
//  id   :
//  info : beschrijving (korte zin)
//  title:
//  type : bijv HAVO-2
//  year : leerjaar
//  components : [],
//  segments: []


function WM_Thread(spec) {
    this.id = spec.id;
    this.subject = spec.subject;
    this.info = spec.info;
    this.title = spec.title;
    this.type = spec.type;
    this.year = spec.year;
    this.modules = [];
}

WM_Thread.prototype.addModule = function(mod) {
    if(mod){
        this.modules.push(mod);
    }
}
;