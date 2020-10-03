os.pullEvent = os.pullEventRaw

PASSWORD = 'sweetroll'
SIDE = 'right'

local attempts = 3

while attempts > 0 do

	term.clear()
	term.setCursorPos(1, 1)

	print('You are entering the EnderCorp Cave')
	write('Password: ')
	local answer = read('*')
	print()

	attempts = attempts - 1

	if answer == PASSWORD then
		print('Access granted. Welcome, The_Enderpenguin.')
		redstone.setAnalogOutput(SIDE, 15)
		sleep(1)
		redstone.setAnalogOutput(SIDE, 0)
		os.shutdown()
	else
		if attempts > 0 then
			print('Access denied. ' .. attempts .. '/3 attempts remaining.')
		else
			print("You are out of attempts. Scram.")
		end
		sleep(1)
	end

end

os.shutdown()
