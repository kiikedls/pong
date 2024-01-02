-- push es una libreria que nos permitirá dibujar nuestro juego en un formato resolucion
-- virtual, en lugar de cuán grande sea nuestra ventana; utilizado para proporcionar
-- una estética más retro
--
-- https://github.com/Ulydev/push
push=require 'push'

--la libreria "Class" que estamos utilizando nos permitirá representar cualquier cosa en
--nuestro juego como código, en lugar de hacer un seguimiento de muchas variables dispares y
--métodos
--https://github.com/vrld/hump/blob/master/class.lua
Class=require 'class'

--incluir la clase de las raquetas
require 'Paddle'

--incluir la clase de la bola
require 'Ball'

--definiendo las dimensiones iniciales de la ventana del juego
_WINDOWIDTH=1280
_WINDOWHEIGHT=720

--Definiendo las dimensiones del tamaño virtual en la ventaba
_VWIDTH=432
_VHEIGHT=243

--velocidad de las raquetas
_PADDLE_SPEED=200

--Funcion para inicializar el juego, se utiliza comunmente al inicio de los programas
function love.load()
    --determina el filtro de textura al reducir y aumnetar la escala de la ventana, 
    --el filtro por defecto puede causar qe las letras se vean borrosas
    --el filtro como 'nearest' le da un toque pixelado al rescalar la imagen
    love.graphics.setDefaultFilter('nearest','nearest')

    --asi se le puede poner un titulo a la ventana del juego
    love.window.setTitle('Kiike Pong')

    --generador de numeros aleatorios para math.random
    --recibe como paramentro el tiempo de la maquina por lo que siempre sera distinto
    math.randomseed(os.time())

    --nueva fuente pixelada para darle una vista mas retro, parametros: la ubicacion de 
    --la funete .ttf y el tamaño
    smallFont=love.graphics.newFont('font.ttf', 8)

    --fuente mas grande para el puntaje
    scoreFont=love.graphics.newFont('font.ttf', 32)

    --fuente para victoria
    largeFont=love.graphics.newFont('font.ttf', 16)

    --activar la fuente
    love.graphics.setFont(smallFont)

    --establecer la mesa de sonidos en Love2D
    sounds = {
        ['paddleHit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wallHit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['background'] = love.audio.newSource('sounds/Spider-Dance.wav', 'static'),
    }
    --pone el efecto de sonido en loop
    sounds.background:setLooping(true)
    --sounds.background:play()
    push:setupScreen(_VWIDTH, _VHEIGHT, _WINDOWIDTH, _WINDOWHEIGHT,{
        --con estos parametros el juego NO sera pantalla completa ni pondran cambiar el tamaño de esta
        fullscreen=false,
        resizable=true,
        vsync=true
    })

    --contadores para los puntajes
    p1Score=0
    p2Score=0

    --esta variable cambia dependiendo de quien sera el jugador a servir 
    --en base al jugador que haya anotado el ultimo punto
    servingPlayer=1

    --inicializar las raquetas, estan globales por lo que puedens 
    --ser utilizadas por otras funciones y modulos
    p1 = Paddle(10, 30, 5, 20)
    p2 = Paddle(_VWIDTH-10, _VHEIGHT-30, 5, 20)

    --posicionar la bola en el centro de la pantalla
    ball = Ball(_VWIDTH/2-2, _VHEIGHT/2-2, 4, 4)

    --estado de juego para transitar entre varios de estos
    --(se usa para inicios, menus, juego principal, hig scores, etc.)
    --lo utilizaremos para determinar el comportamiento durante el 
    --renderizado y la actualización
    gameState='start'
    
end

--funcion de LOVE2D para reescalar el tamaño de la ventana
function love.resize(w, h)
    push:resize(w, h)
end

--Ejecuta cada fotograma, con "dt" introducido, nuestro "delta in seconds" 
--desde el último fotograma, que LÖVE2D nos proporciona
function love.update(dt)
    if gameState == 'serve' then
        --antes de iniciar el estado 'play' inicializamos la direccion 
        --de la bola en base al ultimo jugador que anoto un punto
        ball.DY = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.DX = math.random(140, 200)
        else
            ball.DX = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        --comienza la musica cuando inicia el juego
        sounds.background:play()
       --detectar la colision con el jugador 1 invirtiendo la velocidad dx 
        --pero en la direccion contraria mas un incremento del 3%
        --y alterando el angulo dy basado en la posicion de la colicion
        if ball:collides(p1) then
            ball.DX = -ball.DX * 1.03
            ball.X = p1.X + 5

            --conservar la velocidad en la misma direccion, pero aleatoriamente
            if ball.DY < 0 then
                ball.DY = -math.random(10, 150)
            else
                ball.DY = math.random(10, 150)
            end

            --reproduccion del sonido
            sounds['paddleHit']:play()
        end

        if ball:collides(p2) then
            ball.DX = -ball.DX * 1.03
            ball.X = p2.X - 4

            --conservar la velocidad en la misma direccion, pero aleatoriamente
            if ball.DY < 0 then
                ball.DY = -math.random(10, 150)
            else
                ball.DY = math.random(10, 150)
            end
            --reproduccion del sonido
            sounds.paddleHit:play()
        end

        --detectar la colicion con la parte superior e inferior de la pantalla
        if ball.Y <= 0 then
            ball.Y = 0
            ball.DY = -ball.DY
            sounds.wallHit:play()
        end

        -- -4 para contar con el tamaño de la bola
        if ball.Y >= _VHEIGHT - 4 then
            ball.Y = _VHEIGHT - 4
            ball.DY = -ball.DY
            sounds.wallHit:play()
        end

        -- si llegamos al borde izquierdo o derecho de la pantalla, 
        -- volvemos al inicio y actualizamos la puntuación
        if ball.X < 0 then
            servingPlayer = 1
            p2Score = p2Score + 1
            sounds.score:play()

            --si el jugador consigue un puntaje X, el juego acaba; se pone el estado 
            --de juego 'done' y mostraremos el mensaje de victoria
            if p2Score == 5 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        
        end

        if ball.X > _VWIDTH then
            servingPlayer = 2
            p1Score = p1Score + 1
            sounds.score:play()
        
            if p1Score == 5 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    elseif gameState == 'done' then
        --si es tado de la maquina es 'done' la musica se detiene
        sounds.background:stop()
    end

    

    --movimiento de p1
    --se usa la funcion isDown para cuando se requiere mantener una tacla presionada
    if love.keyboard.isDown('w')then
        --se agrega negativo a la posicion en Y de la raqueta con valor negativo para subir
        --ahora nos aseguraremos que las raquetas delimiten su movimiento en la pantalla
        --la funcion math.max se asegurara de eso
        --p1Y=math.max(0, p1Y + -_PADDLE_SPEED * dt)
        p1.DY= -_PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        --se agrega la velocidad a la posicion para bajar
        --ahora nos aseguraremos que las raquetas delimiten su movimiento en la pantalla
        --la funcion math.min se asegurara de eso
        --p1Y=math.min(_VHEIGHT-20, p1Y + _PADDLE_SPEED * dt)
        p1.DY=_PADDLE_SPEED
    else
        p1.DY=0
    end

    --movimiento de p2
    if love.keyboard.isDown('up')then
        --p2Y=math.max(0, p2Y + -_PADDLE_SPEED * dt)
        p2.DY=-_PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        --p2Y=math.min(_VHEIGHT-20, p2Y + _PADDLE_SPEED * dt)
        p2.DY=_PADDLE_SPEED
    else
        p2.DY=0
    end

    --actualizar el movimiento de la bola basados en ballDX y ballDY 
    --unicamente si el estado del juego es 'play'
    --movimiento de la bola
    if gameState=='play' then
        --ballX=ballX+ballDX*dt
        --ballY=ballY+ballDY*dt
        ball:update(dt)
    end

    p1:update(dt)
    p2:update(dt)
end

--funcion que hace determinada accion cuando se presiona alguna tecla del teclado
function love.keypressed(key)
    --la tecla puede ser indicada por un string con el nombre
    if key == 'escape' then
        --funcion de love para terminar con la aplicacion
        love.event.quit()

    --condicion else para cuando se presione enter para iniciar o reiniciar el estado del juego
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            --este estado solo es para reiniciar las condiciones del juego
            --pero se define al jugador que sirve el siguiente juego en 
            --base al ganador de la partida anterior
            gameState = 'serve'
            ball:reset()
            --reiniciar los puntajes
            p1Score = 0
            p2Score = 0

            --condicion para servir
            if winningPlayer == 1 then
                servingPlayer = 1
            else
                servingPlayer = 2
            end
        end
    end
    
end

--Funcion que sirve para dibujar lo qe qieras en la pantalla
function love.draw()
    --comienza a renderizar en el tamaño virtual
    push:apply('start')

    -- limpiar la pantalla con un color específico; se le pasa parametros en solores r-g-b-a de 0 a255 
    -- en este caso, un color similar a algunas versiones del Pong original
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)

    --funcion que imprime los puntajes en los lados de la pantalla
    displayScore()

    --cambia el mensaje de la pantalla para indicar el cambio entre estados del juego
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Bienvenido al pong!', 0, 10, _VWIDTH, 'center')
        love.graphics.printf('Presiona Enter para iniciar!', 0, 20, _VWIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('El jugador ' .. tostring(servingPlayer) .. ' sirve!', 
        0, 10, _VWIDTH, 'center')
        love.graphics.printf('Presiona Enter para servir!', 0, 20, _VWIDTH, 'center')
    elseif gameState == 'play' then
        --sin mensaje por mostrar en el estado play
    elseif gameState == 'done' then
        --mensaje de victoria
        love.graphics.setFont(largeFont)
        love.graphics.printf('Jugador ' .. tostring(winningPlayer) .. ' gana!!', 0, 10, _VWIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Presiona Enter para reiniciar!', 0, 30, _VWIDTH, 'center')
    end

    --renderizar las raquetas, ahora usamos las clases
    p1:render()
    p2:render()

    --renderizar la bola con su clase
    ball:render()

    --nueva funcion que sirve para mostrar los FPS en LOVE2D
    displayFPS()

    --terminar de renderizar en la resolucion virtual
    push:apply('end')
end

--renderizar los FPS
function displayFPS()
    --un simple contadoir de fps para demostrarlos entre estados
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

--renderizar el puntaje en la pantalla
function displayScore()
    -- dibujar la puntuación en el centro izquierdo y derecho de la pantalla
    -- necesidad de cambiar la fuente para dibujar antes de imprimir realmente
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(p1Score), _VWIDTH / 2 - 50, _VHEIGHT / 3)
    love.graphics.print(tostring(p2Score), _VWIDTH / 2 + 30, _VHEIGHT / 3)
end
