#initialize window and gui elements
def setup():
    global h1, h2
    global actual_hues_list
    global selected_hues_list
    actual_hues_list = [] #actual hues used to generate circle colors
    selected_hues_list = [] #user estimated hues
    newHues()
    size(900,600)
    background(0)
    colorMode(HSB,1)
    ellipseMode(RADIUS)
    noStroke()
    global slider1,slider2
    labels = ('red','yellow','green','cyan','blue','magenta','red')
    slider1 = Slider(
                    pos=(4*width/5,height/2),
                    labels = labels
                    )
    slider2 = Slider(
                    pos=(9*width/10,height/2),
                    labels = labels
                    )
    global n_trial
    n_trial = 1
    
    draw_width = 3*width/4
    draw_height = height
    draw_circles(h1,h2,draw_width,draw_height)

#choose a new random pair of hues to interpolate between
def newHues():
    global h1,h2, actual_hues_list
    h1 = random(0,1)
    h2 = h1 + random(0.5-0.2,0.5+0.2)
    h1 = h1%1; h2 = h2%1
    actual_hues_list.append((h1,h2))

def draw():
    draw_width = 3*width/4
    draw_height = height
    
    #draw new circles every frame
    #global h1,h2
    #draw_circles(h1,h2,draw_width,draw_height)
    
    #draw colorbars
    fill(0)
    rect(draw_width,0,width-draw_width,height)
    global slider1, slider2
    for slider in [slider1,slider2]:
        slider.update()
        slider.draw()
        
    #draw trial #
    global n_trial
    fill(1)
    textSize(32)
    text(n_trial,(width+draw_width)/2,height/10)

#record hue estimates and generate a new set of hues
def submit_answer():
    global selected_hues_list
    selected_hues_list.append((slider1.value,slider2.value))
    newHues() #generate new set of hues
    
    #clear screen
    background(0)
    draw_width = 3*width/4
    draw_height = height
    draw_circles(h1,h2,draw_width,draw_height)
    
    #reset sliders
    slider1.value = 0
    slider2.value = 0

    global n_trial
    n_trial += 1

#save results to text file
def print_results():
    global actual_hues_list, selected_hues_list
    output = createWriter("colorspace-results.txt"); 
    output.println('actual hues')
    output.println(list(map(lambda h: h[0],actual_hues_list)))
    output.println(list(map(lambda h: h[1],actual_hues_list)))
    output.println('selected hues')
    output.println(list(map(lambda h: h[0],selected_hues_list)))
    output.println(list(map(lambda h: h[1],selected_hues_list)))
    output.flush()
    output.close()
    #print(actual_hues_list)
    #print(selected_hues_list)
def keyPressed():
    if key == ' ':
        submit_answer()
    #print lists
    if key == 'p':
        print_results()
#interpolates between hues h1 and h2,
#where t is in the unit interval
#returns point in unit disk, with the hue as the angle, and the saturation as the radius
def hue_interpolate(t,h1,h2):
    return (
        t*cos(2*PI*h1)+(1-t)*cos(2*PI*h2),
        t*sin(2*PI*h1)+(1-t)*sin(2*PI*h2)
        )
#takes a point in the unit disk and returns the corresponding hue
def get_hue(p):
    return ((atan2(p[1],p[0])+PI)/(2*PI)+0.5)%1
#returns the corresponding saturation
def get_sat(p):
    return p[0]**2+p[1]**2

#equivalent to numpy linspace
def frange(minv,maxv,n):
    return [minv + (1.*i/n)*(maxv-minv) for i in range(n)]

#drawing methods
def draw_line(p1,p2):
    line(p1[0],p1[1],p2[0],p2[1])
def draw_rect(p,dims):
    rect(p[0],p[1],dims[0],dims[1])
def draw_circle(p,r):
    ellipse(p[0],p[1],r,r)
#draw random circles that interpolate between the two chosen hues
def draw_circles(h1,h2,draw_width,draw_height):
    n = 1000
    r = 10
    #draw background
    fill(0,0.1)
    rect(0,0,draw_width+r,draw_height+r)
    #draw circles
    noStroke()
    for t in frange(0,1,n):
        circ_loc = (random(0,draw_width),random(0,draw_height))
        p = hue_interpolate(t,h1,h2)
        fill(get_hue(p),get_sat(p),1)
        ellipse(circ_loc[0],circ_loc[1],r,r)
#vector methods (cannot seem to import numpy into processing)
def add(p1,p2):
    return (p1[0]+p2[0],p1[1]+p2[1])
def sub(p1,p2):
    return (p1[0]-p2[0],p1[1]-p2[1])
def mul(p1,p2):
    return list(map(lambda x,y : x*y,p1,p2))
def scale(p,c):
    return list(map(lambda x: x*c,p))
#class for interactive slider gui element
class Slider:
    min_value = 0
    max_value = 1
    #axis is (1,0) or (0,1) for horizonal and vertical slider, respectively
    def __init__(self,pos,labels,value=min_value,axis=(0,1),draw_length = 400,draw_width=20,r=15,label_space = 1):
        self.value = value
        self.axis = axis
        self.pos = pos
        self.labels = labels
        self.draw_length = draw_length
        self.draw_width = draw_width
        self.r = r
        self.label_space = label_space
    def get_ddims(self):
        dlen = scale(self.axis,self.draw_length/2)
        dwidth = scale(sub((1,1),self.axis),self.draw_width/2)
        return dlen, dwidth
    def draw(self):
        pos = self.pos
        value = self.value
        #set fill color
        fill(1)
        #highlight on hover
        if self.hoverQ():
            fill(0.5)
        #draw rectangle for slider
        dlen, dwidth = self.get_ddims()
        top_left = sub(pos,add(dwidth,dlen))
        draw_rect(top_left,scale(add(dwidth,dlen),2))
        #draw circle at slider position
        cirpos = add(sub(pos,dlen),scale(dlen,2*value))
        stroke(0)
        draw_circle(cirpos,self.r)
        #draw labels below or to right
        for i,label in enumerate(self.labels):
            text_pos = add(add(top_left,scale(dwidth,2+self.label_space)),scale(dlen,2.*i/(len(self.labels)-1)))
            stroke(1)
            draw_line(text_pos,sub(text_pos,dwidth))
            fill(1.*i/(len(self.labels)-1),1,1)
            label_text_size = 16
            textSize(label_text_size)
            text(label,text_pos[0],text_pos[1]+label_text_size/4)
    #drag slider
    def update(self):
        if self.hoverQ() and mousePressed:
            dlen, dwidth = self.get_ddims()
            mouse_pos = (mouseX,mouseY)
            self.value = (1.+1.*sub(mouse_pos,self.pos)[self.axis[1]]/max(dlen))/2
            #print(self.value)
    #is mouse hovering over slider?
    def hoverQ(self):
        pos = self.pos
        value = self.value
        dlen, dwidth = self.get_ddims()
        top_left = sub(pos,add(dwidth,dlen))
        bottom_right = add(top_left,scale(add(dwidth,dlen),2))
        mouse_pos = (mouseX,mouseY)
        return (
            mouse_pos[0] > top_left[0] and
            mouse_pos[1] > top_left[1] and
            mouse_pos[0] < bottom_right[0] and
            mouse_pos[1] < bottom_right[1]
            )
