function cx(w)
    return math.floor((width - w)/2)
end
 
function cy(h)
    return math.floor((height - h)/2)
end
 
function print_centered(y, font, text)
    love.graphics.setFont(font)
    love.graphics.print(text, cx(font:getWidth(text)), y)
end