local vec = require"matrix"
local canvas = love.graphics.newCanvas()

--global variables
local paused=true

--graphical settigns
local fade_strength=20/255 --a value bewteen 0 and 1

local palette={
  orange_blue = {
    {242/255, 70/255, 7/255}, --orange
    {141/255, 232/255, 242/255} --blue
  },

  matrix = {
    {60/255, 108/255, 64/255},
    {187/255, 246/255, 192/255}
  },

  tron = {
    {30/255, 80/255, 107/255},
    {210/255, 255/255, 252/255},
  },

  black_red = {
    {1, 0, 0},
    {.4, 0, 0}--{.1, .1, .1}
  },

  galaxy={
    {242/255, 181/255, 167/255},
    {7/255, 35/255, 89/255}
  }
}

local colors = palette.galaxy

-------------------------------------------------------
-- 3d stuff

function rotx(a) -- rotation matrix around x
  return vec({1, 0, 0, 0}, {0, math.cos(a), math.sin(a), 0}, {0, -math.sin(a), math.cos(a), 0}, {0, 0, 0, 1})
end

function roty(a) -- rotation matrix around y
  return vec({math.cos(a), 0, -math.sin(a), 0}, {0, 1, 0, 0}, {math.sin(a), 0, math.cos(a), 0}, {0, 0, 0, 1})
end

function rotz(a) -- rotation matrix around z
  return vec({math.cos(a), math.sin(a), 0, 0}, {-math.sin(a), math.cos(a), 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1})
end

local isometric_proj = vec({1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 1})*rotx(math.rad(35.264))*roty(math.rad(-45))
local angle=0


-------------------------------------------------------
-- parameters
local unit=100
local spawn_box=1/10--unit/10
local scale_factor=2
local original_unit=unit

local tangent_length = 20
local arrow_size=3
local arrow_angle=math.rad(45)

local color_scaler=1/50

local origin_x = love.graphics.getWidth()/2
local origin_y = love.graphics.getHeight()/2
local displacement_velocity = 10

local width, height = love.graphics.getDimensions()

local time_slider=0
local max_time = 10 --in seconds

-------------------------------------------------------
--functions
local function linear_map(value, x0, x1, y1, y2)
  return (value-x0)/(x1-x0)*(y2-y1) + y1
end

local function pixels_to_units(u,v)
  return (u-origin_x)/unit, -(v-origin_y)/unit
end

local function units_to_pixels(x,y)
  return x*unit+origin_x, -y*unit+origin_y
end


local function lorenz(x, sigma, beta, rho)
  return vec(
    sigma*(x[2]-x[1]),
    x[1]*(rho-x[3])-x[2],
    x[1]*x[2]-beta*x[3],
    0
  )
end

local function F(x) -- the 2d differential equation
  local mat={
    {-1, 1},
    {1, 2}
  }

  --[[local mat={
    {.1, .8},
    {-1, .1}
  }]]
  local t = time_slider/max_time--linear_map(time_slider, 0, max_time, 0, 1)
  t=1--math.min(t, 1)

  local sigma = (1-t)*10 + t*10
  local beta = (1-t)*8/3 + t*(8/3)
  local rho = (1-t)*13 + t*(28)


  return lorenz(x, sigma, beta, rho)
end

-- particles
local particles={}
local num_particles=4*10^3
particles.integration_timestep=0.01
particles.derezz_prob=0--0.01 --probability of removing the particle at each frame
particles.min_lifespan=0 --in seconds

local function spawn_particle(n)
  --[[local u = u or love.math.random(0, width)
  local v = v or love.math.random(0, height)]]

  local coord = {}
  for i=1,n do
    table.insert(coord, love.math.random()*2*spawn_box-spawn_box)
  end

  local p = {}
  p.x = vec(coord)
  p.life=0
  table.insert(particles, p)
end



local function draw_particles(screen)
  local k=15
  local y_offset=100
  for n=1, #particles do
    local x_screen = k*screen*particles[n].x


    local dx = F(particles[n].x)
    local vel = dx:norm()*color_scaler

    vel = math.max(0, vel)
    vel = math.min(vel, 1)
    --love.graphics.setColor(0,90/255,126/255, 1)


    local red = (1-vel)*colors[1][1] + vel*colors[2][1]
    local green = (1-vel)*colors[1][2] + vel*colors[2][2]
    local blue = (1-vel)*colors[1][3] + vel*colors[2][3]

    love.graphics.setColor(red, green, blue, 1)
    love.graphics.points(x_screen[1]-200, x_screen[2]-y_offset)
  end
end

local function reset_particles()
  for n=#particles,1,-1 do
    table.remove(particles, n)
  end
  while #particles < num_particles do
    spawn_particle()
  end
end

for n=1,num_particles do
  spawn_particle(4)
end

function love.load()
end

function love.keypressed(key)
  if key=="p" then paused = not paused end
  if key=="escape" then love.event.quit() end
end

function love.update(dt)
  if paused then return end
  time_slider=time_slider+dt


  for n=#particles,1,-1 do
    if particles[n].life > particles.min_lifespan and love.math.random()<particles.derezz_prob then
      table.remove(particles, n)
    else
      local x=particles[n].x

      local dx = F(particles[n].x, particles[n].y)

      dt = particles.integration_timestep

      particles[n].x = x+dx*dt
      particles[n].life = particles[n].life + dt
    end
  end

  while #particles < num_particles do
    spawn_particle(4)
  end

  angle = angle + math.rad(.2)
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setCanvas(canvas)

  love.graphics.push()

  love.graphics.translate(width/2, height/2)
  love.graphics.scale(1, -1)

  love.graphics.setColor(0,0,0,fade_strength)
  love.graphics.rectangle("fill",-width/2,-height/2,width,height)

  love.graphics.setColor(.9,.9,.9,1)
  love.graphics.setLineWidth(1)



  local screen=isometric_proj*rotx(math.pi)*rotz(math.pi)--angle)
  draw_particles(screen)
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1, 1)





  love.graphics.pop()
  --love.graphics.setShader(shader)
  love.graphics.draw(canvas)

love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill", 0, 0, 100, 100)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(love.timer.getFPS(), 10, 10)
end
