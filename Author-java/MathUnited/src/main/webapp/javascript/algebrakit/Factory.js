/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery'], function ($) {
    return {
        generate: function(id, func) {
            $.get('/MathUnited/akit-generate?exercise-id='+id, function(resp){
                if(resp && resp.length>0){
                    func(resp[0]);
                }
            });
        }
        
    };
}
);

