#version 400
#define PI 3.14159265359

precision highp float;

out vec4 color;

layout(origin_upper_left) in vec2 gl_FragCoord;

uniform vec2 u_resolution;


int outputSpace = 1; //change this to 0 to see mapping of numbers

vec2 toPolar(vec2 cartesian)
{
    float r = sqrt(cartesian.x*cartesian.x + cartesian.y*cartesian.y);  //radius
    float a = mod(degrees(atan(cartesian.y,cartesian.x)), 360);         //angle
    return vec2(r,a);
}

vec4 hsv2rgb(vec3 hsv) //this one is weird and I don't completely know how does it work, its code from wikipedia edited by me
{
    hsv.y = hsv.y > 1.0 ? 1.0 : hsv.y;              //if its too big, just truncate to 1
    hsv.z = hsv.z > 1.0 ? 1.0 : hsv.z;              //same
    float c = hsv.y * hsv.z;                        //chromatic value(?)        
    c = sqrt(c);                                    //it's just for nicer and smoother transition
    float hp = hsv.x / 60.0;                        //to have h from 0 to 6
    float _x = c * (1.0 - abs(mod(hp,2.0) - 1.0));  //no idea
    
    vec4 rgb;
    rgb.a = 1.0;
    
    if(hp <= 1.0)
    {rgb.r = c; rgb.g = _x;}
    else if(hp <= 2.0)
    {rgb.r = _x; rgb.g = c;}
    else if(hp <= 3.0)
    {rgb.g = c; rgb.b = _x;}
    else if(hp <= 4.0)
    {rgb.g = _x; rgb.b = c;}
    else if(hp <= 5.0)
    {rgb.r = _x; rgb.b = c;}
    else if(hp <= 6.0)
    {rgb.r = c; rgb.b = _x;}
    
    return rgb;
}

float fact(float x)     //just a factorial, pretty self-explainatory 
{
    float res = 1.0;
    float i = 2.0;
    while(i <= x)
    {res *= i; i++;}
    return res;
}

vec2 compPow(vec2 z, float e)       //complex raising to the power, its just like powering absolute value and multiplying the argument
{
    z = toPolar(z);                 //first we take the absolute value (radius) and argument (angle) from z
    z.y = radians(z.y);             // degrees -> radians
    
    float absw = pow(z.x, e);       //powering absolute value to get absolute of result (w)
    
    vec2 w;                         // w = r(cosx + isinx)
    w.x = absw * cos(e * z.y);      
    w.y = absw * sin(e * z.y);
    
    return w;
}

vec2 compSin(vec2 z)                            //yay, complex sine
{
    z.x = mod(z.x, 2 * PI);
    vec2 w = vec2(0.0,0.0);                     //result
    float sign;
    float factorial;
    vec2 t;                                     
    int n = 0; //for(int n = 0; n < 2; n++)     //sum for n=0 -> rep :   (-1)^n * x^(2n+1) / (2n+1)!
    {                                           //i divided it in 3 parts
        sign = pow(-1, n);                      //first part, the sign (1 or -1)
        factorial = fact(2.0*n + 1.0);          //third part, a factorial, the denominator
        
        t = compPow(z, 2.0*n + 1.0);            //and the 2nd, input complex number raised to the 2n+1
        
        w.x += sign * t.x / factorial;          //i had to split actual series in two. this one is for a real part
        w.y += sign * t.y / factorial;          //and this is imaginary
        n++;

        sign = pow(-1, n);                      //apparently GPU doesn't like loops, so I had to unroll them
        factorial = fact(2.0*n + 1.0);          //also, compiler doesn't seem to unroll it automatically
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;          //total 10 repetitions
        w.y += sign * t.y / factorial;          //not that bad as for just an image with colours
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;

        sign = pow(-1, n);
        factorial = fact(2.0*n + 1.0);
        t = compPow(z, 2.0*n + 1.0);
        w.x += sign * t.x / factorial;
        w.y += sign * t.y / factorial;
        n++;
    }
    return w;
}

void main()
{
    vec2 fCoord = vec2((gl_FragCoord.x - u_resolution.x/2) * 2 / u_resolution.y, gl_FragCoord.y * 2 / u_resolution.y - 1.0);

    vec2 z = fCoord * 4.0;
    z += outputSpace * (compSin(z) - z);

    vec2 polar = toPolar(z);
    vec3 hsv = vec3(polar.y, 1.0, polar.x/4.0);

    color = hsv2rgb(hsv);
}

