//a module represents one element of learning content (aggregation level 2)
WM_MODULE_STATE_NORMAL = 1;
WM_MODULE_STATE_HOVER  = 2;


//spec = name, href
function WM_Module(spec) {
    if(spec.name) this.name = spec.name; else this.name='<unnamed>';
    if(spec.file) this.file = spec.file; else this.href='<nolink>';
    if(spec.id)   this.id = spec.id; else this.id=-1;
    if(spec.method) this.method = spec.method; else this.method='<no provider>';
    if(spec.subcomponents) this.subcomponents = spec.subcomponents; else this.subcomponents = [];
    if(spec.publishState) this.publishState = spec.publishState;
}
;
