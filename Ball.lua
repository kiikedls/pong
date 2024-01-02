--[[
    esta clase representa la bola y sus caracteristicas 
    como su tamaño, movimiento e interacciones con las raquetas
]]
Ball=Class{}

function Ball:init(x, y, width, height)
    self.X = x
    self.Y = y
    self.width = width
    self.height = height

    --estas variables definen la direccion y velocidad de la bola en los ejes X y Y
    self.DY=math.random(2)==1 and 100 or -100
    self.DX=math.random(-50,50)
end

function Ball:collides(paddle)
    --primero, comprueba si el borde izquierdo de cualquiera de los dos está más a la derecha
    --que el borde derecho del otro
    if self.X > paddle.X+paddle.width or paddle.X > self.X+self.width then
        return false
    end

    --a continuación, compruebe si el borde inferior de cualquiera de ellos es más alto que el borde superior
    --superior del otro.
    if self.Y > paddle.Y+paddle.height or paddle.Y > self.Y+self.height then
        return false
    end

    --si ninguna de las condiciones anteriores es cumplida entonces se estan sobreponiendo
    return true
    
end

-- esta funcion reinicia la posicion de la bola al centro de la pantalla 
-- y le da una direccion y velocidad aleatoria
function Ball:reset()
    self.X = _VWIDTH / 2 - 2
    self.Y= _VHEIGHT / 2 - 2
    self.DX=math.random(2)==1 and 100 or -100
    self.DY=math.random(-50,50)
end

--aplica la velocidad y direccion a la bola escalado por el deltaTime
function Ball:update(dt)
    self.X=self.X + self.DX * dt
    self.Y=self.Y + self.DY * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.X, self.Y, self.width, self.height)
end
