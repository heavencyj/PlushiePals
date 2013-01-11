//
//  Shader.fsh
//  PlushiePals
//
//  Created by Heaven Chen on 1/11/13.
//  Copyright (c) 2013 Heaven Chen. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
