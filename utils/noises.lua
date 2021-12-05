local dir = (...):gsub('%.[^%.]+$', '')
Audio = {}

Audio.noises = {
    love.audio.newSource(dir .. "/sounds/crackle1.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/crackle2.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/crackle3.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/crackle4.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/crackle5.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/plop_1.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/plop_2.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/plop_4.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/plop_3.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/plop_5.wav", "stream"),
}
Audio.key_noises = {
    love.audio.newSource(dir .. "/sounds/keypress_2.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/keypress_3.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/keypress_4.wav", "stream"),
    love.audio.newSource(dir .. "/sounds/keypress_1.wav", "stream")
}
function Audio.play_random_audio(noise_group)
    love.audio.play(noise_group[math.random(1, #noise_group)])
end
return Audio