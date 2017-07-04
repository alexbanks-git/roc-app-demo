control = {
    camera = {
        position = { x =0.0, y = 5.0, z = 20.0 },
        angle = { 0.0, 0.0 },
        direction = { x = 0.0, y = 0.0, z = 1.0 },
        up = { x = 0.0, y = 1.0, z = 0.0 },
        fov = math.pi/4
    },
    state = {
        forward = false,
        backward = false,
        left = false,
        right = false
    },
    cursor = {
        lock = true
    },
    console = {
        text = "",
        previous = "",
        visible = false,
        fix = false
    },
    hit = {
        endX = false, endY = false, endZ = false,
        normalX = false, normalY = false, normalZ = false,
        element = false
    },
    grab = {
        state = false,
        element = false,
        distance = 0.0
    }
}

function control.getCameraPosition()
    return control.camera.position.x,control.camera.position.y,control.camera.position.z
end
function control.getCameraDirection()
    return control.camera.direction.x,control.camera.direction.y,control.camera.direction.z
end
function control.getCameraUp()
    return control.camera.up.x,control.camera.up.y,control.camera.up.z
end

function control.isCursorLocked()
    return control.cursor.lock
end

function control.isHitDetected()
    return control.hit.endX
end
function control.getHitElement()
    return control.hit.element
end
function control.getHitPosition()
    return control.hit.endX,control.hit.endY,control.hit.endZ
end
function control.getHitNormal()
    return control.hit.normalX,control.hit.normalY,control.hit.normalZ
end

function control.isConsoleVisible()
    return control.console.visible
end
function control.getConsoleText()
    return control.console.text
end

function control.resetControls()
    for k,_ in pairs(control.state) do
        control.state[k] = false
    end
end
----

player = {
    position = {
        x = 0,
        y = 0,
        z = 0
    },
    movement = {
        rotation = 0,
        targetRotation = 0,
        animation = "none",
        cameraDepth = 8.0,
        cameraDepthEnd = 8.0
    },
    model = false,
    controller = false,
    collision = false,
    animation = false
}
function player.getPosition()
    return player.position.x,player.position.y,player.position.z
end
function player.getYRotation()
    return player.movement.rotation
end
function player.getAnimationName()
    return player.movement.animation
end
----
control.func = {}

function control.func.forward(state)
    control.state.forward = (state == 1)
end
function control.func.backward(state)
    control.state.backward = (state == 1)
end
function control.func.right(state)
    control.state.right = (state == 1)
end
function control.func.left(state)
    control.state.left = (state == 1)
end
function control.func.jump(state)
    if(state == 1) then
        local l_vx,l_vy,l_vz = player.collision:getVelocity()
        l_vy = l_vy+9.8
        player.collision:setVelocity(l_vx,l_vy,l_vz)
    end
end

function control.func.lock(state)
    if(state == 1) then
        control.cursor.lock = not control.cursor.lock
        if(control.cursor.lock) then
            setCursorMode("hl")
        else
            setCursorMode("vu")
        end
    end
end

function control.func.physicsState(state)
    if(state == 1) then
        physics.flip()
    end
end
function control.func.physicsJump(state)
    if(state == 1) then
        physics.chaos()
    end
end

function control.func.console(state)
    if(state == 1) then
        removeEventHandler("onKeyPress",control.onKeyPress)
        control.resetControls()
        
        control.console.visible = true
        addEventHandler("onKeyPress",control.console.onKeyPress)
        addEventHandler("onTextInput",control.console.onTextInput_S1)
    end
end

function control.func.close(state)
    if(state == 1) then
        render.fade.close()
    end
end
----

function control.onKeyPress(key,action)
    if(control.keyFunc[key]) then
        control.keyFunc[key](action)
    end
end

function control.onMouseKeyPress(key,action)
    if(control.cursor.lock) then
        if(key == "left" and action ~= 0) then
            if(control.hit.endX and control.hit.element) then
                if(control.hit.element:getType() == "Model") then
                    local l_col = control.hit.element:getCollision()
                    if(l_col) then
                        local l_mass = l_col:getMass()*20.0
                        local l_px,l_py,l_pz = l_col:getPosition()
                        l_col:applyImpulse(
                            control.camera.direction.x*l_mass,control.camera.direction.y*l_mass,control.camera.direction.z*l_mass,
                            control.hit.endX-l_px,control.hit.endY-l_py,control.hit.endZ-l_pz
                        )
                    end
                end
            end
        end
    end
end

function control.grab.onMouseKeyPress(key,action)
    if(control.cursor.lock) then
        if(key == "right" and action ~= 0) then
            if(not control.grab.state and control.hit.element) then
                if(control.hit.element:getType() == "Model" and control.hit.element ~= player.model and control.hit.element ~= player.controller) then
                    control.grab.state = true
                    control.grab.element = control.hit.element
                    local l_px,l_py,l_pz = control.hit.element:getPosition(true)
                    l_px,l_py,l_pz = l_px-control.camera.position.x,l_py-control.camera.position.y,l_pz-control.camera.position.z
                    control.grab.distance = math.sqrt(l_px*l_px+l_py*l_py+l_pz*l_pz)
                    local l_collision = control.grab.element:getCollision()
                    if(l_collision) then
                        l_collision:setMotionType("kinematic")
                    end
                end
            else
                control.grab.state = false
                if(control.grab.element) then
                    local l_collision = control.grab.element:getCollision()
                    if(l_collision) then
                        l_collision:setMotionType("default")
                    end
                end
                control.grab.element = false
                control.grab.distance = 0.0
            end
        end
    end
end

function control.console.onTextInput_S1() -- skip of tilde
    removeEventHandler("onTextInput",control.console.onTextInput_S1)
    addEventHandler("onTextInput",control.console.onTextInput_S2)
end
function control.console.onTextInput_S2(str1)
    control.console.text = control.console.text..str1
end
function control.console.onKeyPress(key,action)
    if(action == 1) then
        if(key == "esc") then
            control.console.visible = false
            control.console.text = ""
            removeEventHandler("onKeyPress",control.console.onKeyPress)
            removeEventHandler("onTextInput",control.console.onTextInput_S2)
            addEventHandler("onKeyPress",control.onKeyPress)
        elseif(key == "return") then
            if(control.console.text:len() == 0) then return end
            load(control.console.text)()
            control.console.previous = control.console.text
            control.console.text = ""
        elseif(key == "arrow_u") then
            control.console.text = control.console.previous
        elseif(key == "backspace") then
            local l_textLen = utf8.len(control.console.text)
            if(l_textLen > 0) then
                control.console.text = utf8.sub(control.console.text,0,l_textLen-1)
            end
        end
    end
end

local g_cameraMoveFraction = math.pi*128.0
local g_cameraUpDirectionLimit = math.pi/2.0-0.005
local g_cameraDownDirectionLimit = -math.pi/2.0+0.005
function control.onCursorMove(xpos,ypos)
    if(control.cursor.lock) then
        local l_ww,l_wh = window.getSize()
        local l_difx,l_dify = xpos-math.floor(l_ww/2),ypos-math.floor(l_wh/2)
        if(l_difx ~= 0) then control.camera.angle[1] = fixAngle(control.camera.angle[1]-l_difx/g_cameraMoveFraction) end
        if(l_dify ~= 0) then control.camera.angle[2] = math.clamp(control.camera.angle[2]-l_dify/g_cameraMoveFraction,g_cameraDownDirectionLimit,g_cameraUpDirectionLimit) end
        local l_radius = math.cos(control.camera.angle[2])
        control.camera.direction.x,control.camera.direction.y,control.camera.direction.z = l_radius*math.sin(control.camera.angle[1]),math.sin(control.camera.angle[2]),l_radius*math.cos(control.camera.angle[1])
        
        l_radius = math.cos(control.camera.angle[2]+math.pi/2.0)
        control.camera.up.x,control.camera.up.y,control.camera.up.z = l_radius*math.sin(control.camera.angle[1]),math.cos(control.camera.angle[2]),l_radius*math.cos(control.camera.angle[1])
        
        setCursorPosition(math.floor(l_ww/2),math.floor(l_wh/2))
    end
end

local g_cameraUpLimitFOV = math.pi-0.05
local g_cameraDownLimitFOV = 0.005
function control.onMouseScroll(f_wheel,f_delta)
    if(f_wheel == 0) then
        if(isKeyPressed("lctrl")) then
            if(control.grab.element) then
                control.grab.distance = math.max(0,control.grab.distance+f_delta/2.0)
            end
        elseif(isKeyPressed("ralt")) then
            control.camera.fov = math.clamp(control.camera.fov-math.pi/128*f_delta,g_cameraDownLimitFOV,g_cameraUpLimitFOV)
            scene.getMainCamera():setFOV(control.camera.fov)
        else
            player.movement.cameraDepthEnd = math.clamp(player.movement.cameraDepthEnd-f_delta/2.0,0,32)
        end
    end
end

-- Axis X - sin, axis Z - cos, axis Y - depends on algorithm
function control.onPreRender()
    -- Update player position, rotation and animation
    local l_newAnimation = "idle"
    local l_state = (control.state.forward or control.state.backward or control.state.left or control.state.right)
    if(l_state == true) then
        l_newAnimation = "walk"
        
        local l_resultRot = 0.0
        if(control.state.forward) then
            if(control.state.right) then l_resultRot = -0.25*math.pi
            elseif(control.state.left) then l_resultRot = 0.25*math.pi end
        elseif(control.state.backward) then
            if(control.state.right) then l_resultRot = -0.75*math.pi
            elseif(control.state.left) then l_resultRot = 0.75*math.pi
            else l_resultRot = -math.pi end
        else
            if(control.state.right) then l_resultRot = -0.5*math.pi
            elseif(control.state.left) then l_resultRot = 0.5*math.pi end
        end
        player.movement.targetRotation = fixAngle(control.camera.angle[1]+l_resultRot)
    end
    if(player.movement.rotation ~= player.movement.targetRotation) then
        player.movement.rotation = interpolateAngles(player.movement.targetRotation,player.movement.rotation,1.0-0.075*(60.0/render.getFPS()))
        player.model:setRotation(0,player.movement.rotation,0)
    end
    
    player.position.x,player.position.y,player.position.z = player.controller:getPosition()
    if(physicsGetEnabled()) then
        local l_vx,l_vy,l_vz = player.collision:getVelocity()
        l_vx = l_state and 5.625*math.sin(player.movement.rotation) or 0.0
        l_vz = l_state and 5.625*math.cos(player.movement.rotation) or 0.0
        player.collision:setVelocity(l_vx,l_vy,l_vz)
    else
        if(l_state) then
            local l_moveSpeed = (60.0/render.getFPS())*0.09375
            player.position.x,player.position.z = player.position.x+l_moveSpeed*math.sin(player.movement.rotation),player.position.z+l_moveSpeed*math.cos(player.movement.rotation)
            player.controller:setPosition(player.position.x,player.position.y,player.position.z)
            --player.position.y = player.position.y-10.0001583/2.0
        end
    end
    if(player.movement.animation ~= l_newAnimation) then
        player.model:setAnimation(player.animation[l_newAnimation])
        player.model:playAnimation()
        player.movement.animation = l_newAnimation
    end
    
    --Update player's camera
    if(player.movement.cameraDepth ~= player.movement.cameraDepthEnd) then
        player.movement.cameraDepth = math.lerp(player.movement.cameraDepthEnd,player.movement.cameraDepth,1.0-0.1*(60.0/render.getFPS()))
    end
    
    local l_px,l_py,l_pz = player.model:getPosition(true)
    control.camera.position.x,control.camera.position.y,control.camera.position.z =
        l_px-player.movement.cameraDepth*control.camera.direction.x+1.5*math.sin(control.camera.angle[1]-math.pi/2),
        l_py+8.5-player.movement.cameraDepth*control.camera.direction.y,
        l_pz-player.movement.cameraDepth*control.camera.direction.z+1.5*math.cos(control.camera.angle[1]-math.pi/2)
        
    scene.getMainCamera():setPosition(control.camera.position.x,control.camera.position.y,control.camera.position.z)
    scene.getMainCamera():setDirection(control.camera.direction.x,control.camera.direction.y,control.camera.direction.z)
    
    --Update hit detection
    control.hit.endX,control.hit.endY,control.hit.endZ,
    control.hit.normalX,control.hit.normalY,control.hit.normalZ,
    control.hit.element = physicsRayCast(
        control.camera.position.x,control.camera.position.y,control.camera.position.z,
        control.camera.position.x+control.camera.direction.x*20.0,
        control.camera.position.y+control.camera.direction.y*20.0,
        control.camera.position.z+control.camera.direction.z*20.0
    )
    
    --Update grabbing
    if(control.grab.element) then
        control.grab.element:setPosition(
            control.camera.position.x+control.camera.direction.x*control.grab.distance,
            control.camera.position.y+control.camera.direction.y*control.grab.distance,
            control.camera.position.z+control.camera.direction.z*control.grab.distance
        )
        local l_col = control.grab.element:getCollision()
        if(l_col) then
            l_col:setVelocity(0.0,0.0,0.0)
        end
    end
end

control.joypad = {}

function control.joypad.onJoypadStateChange(jid,state)
    if(jid == 0) then
        if(state == 1) then
            addEventHandler("onJoypadButton",control.joypad.onJoypadButton)
        else
            removeEventHandler("onJoypadButton",control.joypad.onJoypadButton)
        end
    end
end

function control.joypad.onJoypadButton(jid,jbutton,jstate)
    if(jid == 0 and jbutton == 0 and jstate == 1) then
        local l_col = model.rigid_body[#model.rigid_body]:getCollision()
        if(l_col) then
            local l_x,l_y,l_z = l_col:getVelocity()
            l_y = l_y+9.8
            l_col:setVelocity(l_x,l_y,l_z)
        end
    end
end

function control.onWindowFocus(focus)
    if(focus == 0) then
        control.resetControls()
    end
end

function control.init()
    control.keyFunc = {
        ["w"] = control.func.forward,
        ["s"] = control.func.backward,
        ["d"] = control.func.right,
        ["a"] = control.func.left,
        ["space"] = control.func.jump,
        ["lalt"] = control.func.lock,
        ["n"] = control.func.physicsState,
        ["q"] = control.func.physicsJump,
        ["esc"] = control.func.close,
        ["tilde"] = control.func.console
    }
    
    setCursorMode("hl")
    
    player.model = model.dummy
    player.controller = Model()
    player.controller:setPosition(0.0,10.0001583/2.0,0.0)
    player.collision = Collision("cylinder",100.0, 0.1,10.0001583/2.0)
    player.collision:setAngularFactor(0.0,0.0,0.0)
    player.collision:attach(player.controller)
    player.controller:setCollidable(player.model,false)
    player.model:attach(player.controller)
    player.model:setPosition(0.0,-10.0001583/2.0,0.0) -- offset from cylinder center
    player.animation = animation.dummy
    
    addEventHandler("onKeyPress",control.onKeyPress)
    addEventHandler("onMouseKeyPress",control.onMouseKeyPress)
    addEventHandler("onMouseKeyPress",control.grab.onMouseKeyPress)
    addEventHandler("onMouseScroll",control.onMouseScroll)
    addEventHandler("onCursorMove",control.onCursorMove)
    addEventHandler("onWindowFocus",control.onWindowFocus)
    
    if(isJoypadConnected(0)) then
        addEventHandler("onJoypadButton",control.joypad.onJoypadButton)
    end
    addEventHandler("onJoypadStateChange",control.joypad.onJoypadStateChange)
    
    addEventHandler("onPreRender",control.onPreRender)
end
addEventHandler("onEngineStart",control.init)

math.pi2 = math.pi*2.0
function interpolateAngles(a,b,blend)
    -- 'a' and 'b' - [-2*PI,2*PI], 'blend' - [0.0,1.0]
    a = math.fmod(a+math.pi2,math.pi2)
    b = math.fmod(b+math.pi2,math.pi2)
    if(b-a > math.pi) then a = a+math.pi2
    elseif(a-b > math.pi) then b = b+math.pi2 end
    return math.fmod(a-(a-b)*blend,math.pi2)
end
function math.lerp(a,b,blend)
    return (a-(a-b)*blend)
end
function math.clamp(n,low,high) return math.min(math.max(n,low),high) end
function fixAngle(f_angle)
    -- 'f_angle' - [-2*PI,2*PI]
    return math.fmod(f_angle+math.pi2,math.pi2)
end

-- ^(?([^\r\n])\s)*[^\s+?/]+[^\n]*$