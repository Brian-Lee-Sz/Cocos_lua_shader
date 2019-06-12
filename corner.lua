
--[[    圆角着色器
    cornerRadius - 圆角参数一个字符串类型
    '0'          正方形
    '0.5'        圆形
    '0.0'~'0.5'  圆角
--]]
local CornerShader = {}
function CornerShader.setTarget(target, cornerRadius)
	cornerRadius = cornerRadius or '0.5'
	local vertex = [[  
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
	local fragment = [[  
        #ifdef GL_ES   
        precision mediump float;  // shader默认精度为double，openGL为了提升渲染效率将精度设为float  
        #endif   
        // varying变量为顶点shader经过光栅化阶段的线性插值后传给片段着色器  
        varying vec4 v_fragmentColor;  // 颜色  
        varying vec2 v_texCoord;       // 坐标  
        void main(void)   
        {   
            vec4 c = texture2D(CC_Texture0, v_texCoord);
            float offset_min=%s;
            float offset_max=1.0-offset_min;
            float x=0.0;
            float y=0.0;
            if (v_texCoord.x < offset_min) {
                if (v_texCoord.y < offset_min) {
                    // 左下
                    x = abs(v_texCoord.x - offset_min);
                    y = abs(v_texCoord.y - offset_min);
                }else if(v_texCoord.y > offset_max){
                    //左上
                    x = abs(v_texCoord.x - offset_min);
                    y = abs(v_texCoord.y - offset_max);
                }else{
                    //中右
                    x = abs(v_texCoord.x - offset_min);
                }
            }else if(v_texCoord.x > offset_max){
                if (v_texCoord.y < offset_min) {
                    //右下
                    x = abs(v_texCoord.x - offset_max);
                    y = abs(v_texCoord.y - offset_min);
                }else if(v_texCoord.y > offset_max){
                    //右上
                    x = abs(v_texCoord.x - offset_max);
                    y = abs(v_texCoord.y - offset_max);
                }else{
                    //中左
                    x = abs(v_texCoord.x - offset_max);
                }
            }else{
                if(v_texCoord.y < offset_min){
                    //中上
                    y = abs(v_texCoord.y - offset_min);
                }else if (v_texCoord.y > offset_max){
                    //中下
                    y = abs(v_texCoord.y - offset_max);
                }
            }
            float distanceValue = sqrt(pow(x, 2.0) + pow(y, 2.0));
            float boundary = offset_min - sqrt(pow(0.02, 2.0) + pow(0.02, 2.0));
            if (distanceValue > offset_min) {
                c = vec4(vec3(0,0,0), 0.0);
            }else if (distanceValue >= boundary){
                //边缘虚化
                c = c * (1.0 - (distanceValue - boundary) * 50.0);
            }
            gl_FragColor=c;
        }  
    ]]
	local program = cc.GLProgramCache:getInstance():getGLProgram(string.format("cornerRadius_%f", cornerRadius))
    	if not program then
        	fragment = string.format(fragment, cornerRadius)
        	program = cc.GLProgram:createWithByteArrays(vertex, fragment)
        	cc.GLProgramCache:getInstance():addGLProgram(program, string.format("cornerRadius_%f", cornerRadius))
    	end
    	target:setGLProgram(program)
end

return CornerShader 
