import scone;

import std.random;
import core.thread;
import core.time;

bool running = true;

void main()
{
    sconeInit();

    title = "Pong";

    layer = new Layer(0,0);
    ball = new Ball();

    width = layer.width;
    height = layer.height;

    ball.x = width/2;
    ball.y = uniform(0, height);
    ball.up = cast(bool)uniform(0, 2);
    ball.right = cast(bool)uniform(0, 2);

    //p1.length = cast(int)(height/4);
    p1.height = cast(int)((height/2)-2);
    p2 = p1;

    Clock clock = new Clock();
    clock.reset();

    while(running){
        updatePlates();
        tick(clock.reset());
    }

    sconeClose();
}

int width, height;
Layer layer;

Ball ball;
Plate p1, p2;

bool p1mov = true, p2mov = true;
double ticks = 0;
int updateInterval = 100;

void tick(double dt)
{
    ticks += dt;
    int runs = cast(int)(ticks / updateInterval);
    ticks -= (runs * updateInterval);

    foreach (i; 0 .. runs){

        layer.write(ball.x, ball.y, ' ');

        if(ball.up)
        {
            if(ball.y > 0)
                --ball.y;
            else
            {
                ++ball.y;
                ball.up = false;
            }
        }
        else
        {
            if(ball.y < height - 1)
                ++ball.y;
            else
            {
                --ball.y;
                ball.up = true;
            }
        }


        if(ball.right)
        {
            if(ball.x == width - 3 && ball.y >= p2.height && ball.y < p2.height+5){
                --ball.x;
                ball.right = false;
            }
            else if(ball.x < width - 1)
            {
                ++ball.x;
            }
            else
            {
                assert(0, "P1 WINS");
            }
        }
        else
        {
            if(ball.x == 2 && ball.y >= p1.height && ball.y < p1.height+5){
                ++ball.x;
                ball.right = true;
            }
            if(ball.x > 0)
                --ball.x;
            else
            {
                assert(0, "P2 WINS");
            }
        }

        layer.write(ball.x, ball.y, '*');
    }
    layer.print();
}

struct Plate
{
    int height;
}

class Ball
{
    int x;
    int y;
    int speed;

    bool up;
    bool right;
}

void updatePlates(){
    foreach(input; getInputs())
    {
        if(input.key == SK_ESCAPE)
        {
            running = false;
            break;
        }

        if(!input.keyDown)
            continue;

        if(input.key == SK_W && p1.height - 1 >= 0){
            p1.height -= 1;
            p1mov = true;
        }
        if(input.key == SK_S && p1.height + 5 < height){
            p1.height += 1;
            p1mov = true;
        }

        if(input.key == SK_UP && p2.height - 1 >= 0){
            p2.height -= 1;
            p2mov = true;
        }
        if(input.key == SK_DOWN && p2.height + 5 < height){
            p2.height += 1;
            p2mov = true;
        }
    }

    if(p1mov){
        foreach(h; 0 .. height){
            layer.write(1, h, ' ');
        }

        foreach(h; 0 .. 5)
            layer.write(1, p1.height + h, bg.red, '#');

        p1mov = false;
    }

    if(p2mov){
        foreach(h; 0 .. height){
            layer.write(width - 2, h, ' ');
        }

        foreach(h; 0 .. 5)
            layer.write(width - 2, p2.height + h, bg.blue, '#');

        p2mov = false;
    }
}

class Clock
{
    private MonoTime lasttime;

    this(){
        lasttime = MonoTime.currTime();
    }

    double reset()
    {
        /* Kudos to Yepoleb who helped me with this */
        MonoTime newtime = MonoTime.currTime();
        Duration duration = newtime - lasttime;
        double durationmsec = duration.total!"nsecs" / (10.0 ^^ 6);
        lasttime = newtime;

        return durationmsec;
    }
}
