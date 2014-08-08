; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.

; The Two Toned Scaling method does not actually do anything with tones.

(define (script-fu-two-toned-scale-layer image layer interpolation new-width new-height)
    (gimp-undo-push-group-start image) ; Start undo group
    (let*
        (
        (old-width (car (gimp-drawable-width layer)))
        (old-height (car (gimp-drawable-height layer)))
        (horizontal-blur-factor
            (if (= new-width 0) ; If new-width 0 set horz blur to what the vertical would be.
                (/ old-height new-height)
                (/ old-width new-width)
            )
        )
        (vertical-blur-factor
            (if (= new-height 0) ; ...and vise versa for height. Breaks if target size is 0,0!
            (/ old-width new-width)
            (/ old-height new-height)
            )
        )
        )

    (plug-in-gauss ; Perform the gaussian blur!
        RUN-NONINTERACTIVE
        image
        layer
        horizontal-blur-factor
        vertical-blur-factor
        1 ; 1 = RLE, 'RLE' should work but throws undefined for some reason...
    )
    
    (gimp-context-set-interpolation interpolation) ; Sets interpolation method for scaling.
    
    (if (= new-width 0) ; If new width 0 work it out from the blur factor
        (set! new-width (/ old-width horizontal-blur-factor)
        )
    )
    
    (if (= new-height 0) ; Similar for height
        (set! new-height (/ old-height vertical-blur-factor)
        )
    )
    
    (gimp-layer-scale ; Scale the layer
        layer
        new-width
        new-height
        TRUE ; Local-origin true, layer scales from the centre of the layer.
    )
    )
    
    (gimp-undo-push-group-end image) ; End undo group
    (gimp-displays-flush) ; Repaint the now altered image!
)

(script-fu-register
    "script-fu-two-toned-scale-layer" ; function name
    "Two Toned Scale Layer..." ; Menu label
    "Scales a layer with the Two Toned method." ; description
    "Jibodeah" ; Author, not actually Two-Tone-.
    "Copyright 2014, Jibodeah"
    "August 8, 2014"
    "*" ; image type
    ; Variables!
    SF-IMAGE "Image" 0
    SF-DRAWABLE "Layer" 0 ; 'Drawable'? Actually a ref to the active layer!
    SF-ENUM "Interpolation Method" '("InterpolationType" "cubic") ; Scaling interpolation method to use!
    SF-ADJUSTMENT _"New Width" '(150 0 262144 1 100 0 SF-SPINNER) ; 262144 is the max layer dimension
    SF-ADJUSTMENT _"New Height" '(150 0 262144 1 100 0 SF-SPINNER)
)
(script-fu-menu-register
    "script-fu-two-toned-scale-layer"
    "<Image>/Layer/"
)
