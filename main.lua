local linalg = require"linalg"

local canvas = love.graphics.newCanvas()

--graphical settigns
local fade_strength=10/255 --a value between 0 and 1

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

  blues = {
    --{1-17/255, 1-124/255, 1-217/255},
    --{1-30/255, 1-164/255, 1-217/255}
    {1-75/255, 1-75/255, 1-250/255},
    {1-145/255, 1-145/255, 1-250/255}
  },

  metropolis_inv = {
    {1-33/255, 1-122/255, 1-255/255},--{1-73/255, 1-114/255, 1-122/255}
    {1-12/255, 1-79/255, 1-179/255}--{1-34/255, 1-99/255, 1-112/255}
  }
}

local colors = palette.blues--metropolis_inv

for k=1,2 do
  colors[k][1]=1-colors[k][1]
  colors[k][2]=1-colors[k][2]
  colors[k][3]=1-colors[k][3]
end

--parameters
local unit=200
local scale_factor=1
local original_unit=unit

local tangent_length = 25
local arrow_size=tangent_length/3
local arrow_angle=math.rad(45)

local origin_x = love.graphics.getWidth()/2---100
local origin_y = love.graphics.getHeight()/2--+100
local displacement_velocity = 10

local PARAMETER=0.1
local PARAMETER_STEP=1.001

local width, height = love.graphics.getDimensions()

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

local function F(x, y) -- the 2d differential equation
  local mat={
    {1, 0},
    {0, 2}
  }

  local function case_1a(x,y)
    local mat={
      {-1, 0},
      {0, -2}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_1b(x,y)
    local mat={
      {1, 0},
      {0, 2}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_1c(x,y)
    local mat={
      {-1, 0},
      {0, 1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_1d(x,y)
    local mat={
      {-1, 0},
      {0, 0}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_1e(x,y)
    local mat={
      {0, 0},
      {0, 1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  ------------------------------------------------------------------

  local function case_2a(x,y)
    local mat={
      {-1, 0},
      {0, -1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_2b(x,y)
    local mat={
      {1, 0},
      {0, 1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_2c(x,y)
    local mat={
      {0, 0},
      {0, 0}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_2d(x,y)
    local mat={
      {-1, 0},
      {1, -1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_2e(x,y)
    local mat={
      {1, 0},
      {1, 1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_2f(x,y)
    local mat={
      {0, 0},
      {1, 0}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  ------------------------------------------------------------------

  local function case_3a(x,y)
    local mat={
      {-1, 1},
      {-1, -1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_3b(x,y)
    local mat={
      {1, 1},
      {-1, 1}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  local function case_3c(x,y)
    local mat={
      {0, 1},
      {-1, 0}
    }

    return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  end

  --return case_3a(x,y)

  --local dp_x = 22
  --local dp_y = 27

  --[[local mat={
    {.1, .8},
    {-1, .1}
  }]]


  --return 1, y^3-2*(x^2)+x
  --return 1, y^3-2*y^2+y
  return y, -y-math.sin(x)*2
  --return math.cos(math.cos(math.sqrt(x^2+y^2))*math.max(x,y)), math.sin(math.max((y+x), math.sqrt(x^2+y^2)+x))


--  return -x, -y*(x+(y^2)*(9-y^2))

  --local a=0.08
  --local b=0.6
  --return -x+a*y+x^2*y,	b-a*y-(x^2)*y

  --return math.sin(x+y), math.cos(x-y)

  --return mat[1][1]*x + mat[1][2]*y, mat[2][1]*x + mat[2][2]*y
  --return math.sin(x^2+y^2), -1
  --local mu=1
  --return y, mu*(1-x^2)*y-x
  --return y-y^3, -x-y^2


  --figure eight
  --[[x,y=y,-x
  x=4*x
  local k = PARAMETER--0.5
  return -(2*x - k*(x^2 - 4*y^2*(1-y^2))*(16*y^3-8*y)),8*y - 16*y^3 - k*(x^2 - 4*y^2*(1-y^2))*2*x]]
end

-- particles
local particles={}
local num_particles=10^5/4
particles.integration_timestep=0.01
particles.derezz_prob=0.01 --probability of removing the particle at each frame
particles.min_lifespan=.01 --in seconds

local function spawn_particle(u, v)
  local h=100 --offscreen displacement

  local u = u or love.math.random(0-h, width+h)
  local v = v or love.math.random(0-h, height+h)

  local x,y = pixels_to_units(u,v)

  local p = {}
  p.x = x
  p.y = y
  p.life=0
  table.insert(particles, p)
end



local function draw_particles()
  for n=1, #particles do
    local u,v = units_to_pixels(particles[n].x, particles[n].y)
    local dx, dy = F(particles[n].x, particles[n].y)
    local vel = math.sqrt(dx^2+dy^2)/4

    vel = math.max(0, vel)
    vel = math.min(vel, 1)
    --love.graphics.setColor(0,90/255,126/255, 1)


    local red = (1-vel)*colors[1][1] + vel*colors[2][1]
    local green = (1-vel)*colors[1][2] + vel*colors[2][2]
    local blue = (1-vel)*colors[1][3] + vel*colors[2][3]

    love.graphics.setColor(red, green, blue, 1)
    love.graphics.points(u,v)
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
  spawn_particle()
end



id=linalg.identity(3)
print(linalg.tostring(id))



local function draw_axis()
  local w,h = love.graphics.getDimensions()
  love.graphics.line(0, origin_y, w, origin_y)
  love.graphics.line(origin_x, 0, origin_x, h)
end

local function draw_field(h_sampling_points, v_sampling_points, fade, opacity) -- horizontal and vertical
  local w,h = love.graphics.getDimensions()
  local hspace = w/h_sampling_points
  local vspace = h/v_sampling_points

  for x_i=1, h_sampling_points do
    for y_i=1, v_sampling_points do
      local x=hspace*(x_i-1)+hspace/2
      local y=vspace*(y_i-1)+vspace/2
      local fx,fy = F((x-origin_x)/unit,-(y-origin_y)/unit)

      local vel = math.sqrt(fx^2+fy^2)/6
      vel = math.max(.5, vel)
      vel = math.min(vel, 1)

      if fade then
        love.graphics.setColor(1,1,1,vel)
      else
        love.graphics.setColor(1-52/255,1-84/255,1-131/255,opacity or 1)
      end


      love.graphics.push()
      love.graphics.translate(x, y)
      love.graphics.rotate(-math.atan2(fy,fx))
      love.graphics.line(-tangent_length/2, 0, tangent_length/2, 0)
      love.graphics.translate(tangent_length/2, 0)

      love.graphics.push()
      love.graphics.rotate(arrow_angle)
      love.graphics.line(0, 0, -arrow_size, 0)
      love.graphics.pop()
      love.graphics.rotate(-arrow_angle)
      love.graphics.line(0, 0, -arrow_size, 0)
      love.graphics.pop()
    end
  end
end

local function integrate_and_draw_field(f, x0, y0, steps, dt, mode)
  local u0, v0 = units_to_pixels(x0, y0)
  local points={u0, v0}

  local x, y = x0, y0
  if mode=="center" then
    steps=steps/2

    for i=1,steps do
      local dx, dy = F(x, y)

      x = x-dx*dt
      y = y-dy*dt

      local sx, sy = units_to_pixels(x, y)

      table.insert(points, 1, sy)
      table.insert(points, 1, sx)
    end
  end

  x, y = x0, y0

  for i=1,steps do
    local dx, dy = F(x, y)

    x = x+dx*dt
    y = y+dy*dt

    local sx, sy = units_to_pixels(x, y)

    table.insert(points, sx)
    table.insert(points, sy)
  end

  love.graphics.line(points)
end

function love.load()
  shader = love.graphics.newShader("shader.fs")
end

function love.keypressed(key)
  if key=="escape" then
    love.event.quit()
  end

  if key=="r" then
    origin_x = width/2
    origin_y = height/2

    unit=original_unit
    reset_particles()
  end

  if key=="kp+" then
    unit=unit*scale_factor

    reset_particles()
  elseif key=="kp-" then
    unit=unit/scale_factor

    reset_particles()
  end
end

function love.update(dt)
  PARAMETER = PARAMETER / PARAMETER_STEP
  for n=#particles,1,-1 do
    particles[n].life = particles[n].life + dt
    if particles[n].life > particles.min_lifespan and love.math.random()<particles.derezz_prob then
      table.remove(particles, n)
    else
      local x=particles[n].x
      local y=particles[n].y

      local dx, dy = F(particles[n].x, particles[n].y)

      dt = particles.integration_timestep

      particles[n].x = x+dx*dt
      particles[n].y = y+dy*dt

    end
  end

  while #particles < num_particles do
    spawn_particle()
  end



  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
    origin_y = origin_y + displacement_velocity
  end

  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
    origin_x = origin_x + displacement_velocity
  end

  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
    origin_y = origin_y - displacement_velocity
  end

  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
    origin_x = origin_x - displacement_velocity
  end
end

function love.draw()
  --love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setCanvas(canvas)

  love.graphics.setColor(0,0,0,fade_strength)
  love.graphics.rectangle("fill",0,0,width,height)


  draw_particles()
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1, 1)

  --love.graphics.setShader(shader)
  love.graphics.draw(canvas)
  love.graphics.setCanvas()

  -----------------------------------------------
  love.graphics.setBlendMode("alpha", "alphamultiply")
  love.graphics.setColor(1,1,1,1)
  love.graphics.setLineWidth(1.5)
  --draw_axis()
  --love.graphics.setColor(0,1,1)--(1,1,1,1)
  love.graphics.setLineWidth(1)
  --draw_field(15, 15, false, 1)


  love.graphics.setColor(1-112/255, 1-30/255, 1-72/255)--1-12/255, 1-79/255, 1-179/255)--1-255/255,1-181/255,1-33/255)
  love.graphics.setLineWidth(3)
  local mx, my = love.mouse.getPosition()
  mx, my = pixels_to_units(mx, my)
  --integrate_and_draw_field(F, mx, my, 10000, particles.integration_timestep)
  local num_of_sol = 16
  local dist = 2
  --spherical
  --[[for k=0,num_of_sol-1 do
    local sx = dist*math.cos((2*math.pi*k)/num_of_sol)
    local sy = dist*math.sin((2*math.pi*k)/num_of_sol)

    integrate_and_draw_field(F, sx, sy, 1500, particles.integration_timestep, "center")
  end]]

  --[[local lines_per_quadrant=8
  for i=-1,1,2 do
    for j=-1,1,2 do
      for n=1, lines_per_quadrant do
        local sx = n*(love.graphics.getWidth()/2)/(lines_per_quadrant+1)
        local sy = n*(love.graphics.getHeight()/2)/(lines_per_quadrant+1)
        sx,sy=pixels_to_units(sx,sy)
        integrate_and_draw_field(F, i*sx, j*sy, 2100, particles.integration_timestep/10, "center")
      end
    end
  end]]



  love.graphics.setColor(1,1,1,1)
  --love.graphics.print("("..mx .. ", ".. my .. ")\n"..PARAMETER, 10, 10)
end
