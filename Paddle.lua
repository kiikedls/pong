--[[
    esta clase representa las raquetas y sus caracteristicas 
    como su tamaño, movimiento e interacciones con las raquetas
]]

Paddle = Class{}

--[[
    La función `init` en nuestra clase se llama sólo una vez, cuando el objeto
    se crea por primera vez. Se utiliza para configurar todas las variables de la clase y conseguir que
    lista para su uso.

    Nuestra paleta debe tomar un X y un Y, para el posicionamiento, así como una anchura
    y altura para sus dimensiones.

    Nótese que `self` es una referencia a *este* objeto, sea cual sea el objeto
    instanciado en el momento de llamar a esta función. Diferentes objetos pueden
    tener sus propios valores de x, y, anchura y altura, sirviendo así como contenedores
    de datos. En este sentido, son muy similares a los structs en C.
]]
function Paddle:init(x, y, width, height)
    self.X=x
    self.Y=y
    self.width=width
    self.height=height
    self.DY=0
end

function Paddle:update(dt)
    --math.max delimita el tope hasta donde las raquetas pueden subir
    if self.DY < 0 then
        self.Y = math.max(0, self.Y + self.DY * dt)
    else
        --math.min delimita el punto mas bajo que puede bajar la raqueta
        self.Y = math.min(_VHEIGHT - self.height, self.Y + self.DY * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.X, self.Y, self.width, self.height)
end
