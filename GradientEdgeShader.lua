local GradientEdgeShader = {}
function GradientEdgeShader.setTarget(target, from, to, m_color, m_radius)
    local vertex =
        [[  
        attribute vec4 a_position;   
        attribute vec2 a_texCoord;   
        attribute vec4 a_color;   
        #ifdef GL_ES    
        varying lowp vec4 v_fragmentColor;  
        varying mediump vec2 v_texCoord;  
        #else                        
        varying vec4 v_fragmentColor;   
        varying vec2 v_texCoord;    
        #endif      
        void main()   
        {  
            gl_Position = CC_PMatrix * a_position;   
            v_fragmentColor = a_color;  
            v_texCoord = a_texCoord;  
        }  
    ]]

    -- 片段shader
    local fragment =
        [[  
        #ifdef GL_ES   
        precision mediump float;  // shader默认精度为double，openGL为了提升渲染效率将精度设为float  
        #endif   
        // varying变量为顶点shader经过光栅化阶段的线性插值后传给片段着色器  
        varying vec4 v_fragmentColor;  // 颜色  
        varying vec2 v_texCoord;       // 坐标  

        vec3 verify(vec2 td, vec3 from, vec3 to)
        {
            vec3 temp = vec3(0.0);
            float offset = td.y <= 0.7 ? td.y * 4.0 : 3.0;
            float temp_offset = 1.0 - td.y * offset < 0.0 ? 0.0 : 1.0 - td.y * offset;
            temp.r = (to.r - (to.r - from.r ) * temp_offset) / 255.0;
            temp.g = (to.g - (to.g - from.g ) * temp_offset) / 255.0;
            temp.b = (to.b - (to.b - from.b ) * temp_offset) / 255.0;
            return temp;
        }

        void main(void)   
        {   
            vec4 c = texture2D(CC_Texture0, v_texCoord);
            vec3 t_from = vec3(%f, %f, %f);
            vec3 t_to = vec3(%f, %f, %f);
            c.rgb = verify(v_texCoord, t_from, t_to);
            float m_radius_ = %f;
            float m_radius_x = 0.003;
            float m_radius_y = 0.002;
            if(m_radius_ > 0.0){
                vec4 accum = vec4(1.0);
                accum.rgb = vec3(%f, %f, %f) / 255.0;

                float alpha = clamp(c.a, 0.0, 0.5) * 2.0;//将差异放大
                float color = (clamp(c.a, 0.5, 1.0) - 0.5) * 2.0;
                c.xyz = (c.xyz) * color + accum.rgb * (1.0 - color) ;
            }
            gl_FragColor = c;
        }
    ]]
    local m_r = m_color and (m_radius and m_radius or 0.003) or 0
    local temp_m_color = m_color or cc.c3b(0, 0, 0)
    fragment =
        string.format(
        fragment,
        from.r,
        from.g,
        from.b,
        to.r,
        to.g,
        to.b,
        m_r,
        temp_m_color.r,
        temp_m_color.g,
        temp_m_color.b
    )
    local pProgram = cc.GLProgram:createWithByteArrays(vertex, fragment)
    target:setGLProgram(pProgram)
end

return GradientEdgeShader
